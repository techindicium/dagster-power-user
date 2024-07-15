module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  for_each = docker_registry_image.dagster

  name        = "dagster-${each.key}"
  cluster_arn = data.aws_ecs_cluster.dagster.arn

  cpu    = 1024
  memory = 4096

  # Container definition(s)
  container_definitions = {
    # needed due to the design of the output of container definitions submodule
    "${each.key}" = merge(
      {
        name      = each.key
        cpu       = 512
        memory    = 1024
        essential = true
        image     = each.value.name

        memory_reservation = 100

        cloudwatch_log_group_name = "/aws/ecs/dagster-${each.key}"


        command = each.key == "webserver" ? split(" ", "dagster-webserver -h 0.0.0.0 -p 3000 -w workspace.yaml") : ["dagster-daemon", "run"]

        secrets = [
          for var in local.dagster_env_vars :
          {
            "name" : var,
            "valueFrom" : data.aws_secretsmanager_secret.postgres[var].arn
          }
        ]

        environment = [
          {
            "name" : "DAGSTER_GRPC_TIMEOUT_SECONDS",
            "value" : "60"
          },
          {
            "name" : "DAGSTER_COMPUTE_LOGS_BUCKET",
            "value" : data.aws_s3_bucket.dagster.id
          }
        ]

      },
      {
        log_configuration = {
          options = {
            awslogs-region        = var.region
            awslogs-group         = "/aws/ecs/dagster-${each.key}"
            awslogs-create-group  = "true"
            awslogs-stream-prefix = "ecs"
          }
        },
        port_mappings = [
          {
            name          = each.key
            containerPort = 3000
            protocol      = "tcp"
          }
        ],
        # images used require access to write to root filesystem
        readonly_root_filesystem = false

        service = "dagster-${each.key}"


      }
    )
  }

  service_connect_configuration = {
    service = {
      client_alias = {
        port     = 3000
        dns_name = "dagster-${each.key}"
      }
      port_name      = each.key
      discovery_name = "dagster-${each.key}"
    }
  }

  load_balancer = each.key == "webserver" ? {
    service = {
      target_group_arn = data.aws_lb_target_group.dagster.arn
      container_name   = each.key
      container_port   = 3000
    }
  } : {}

  subnet_ids = data.aws_subnets.private.ids

  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = 3000
      to_port                  = 3000
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = data.aws_security_group.alb.id
    }

    dagster_core_3000 = {
      type        = "ingress"
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      description = "Webserver-daemon connection"
      cidr_blocks = local.private_subnets_cidr_blocks
    }

    code_locations_4000 = {
      type        = "ingress"
      from_port   = 4000
      to_port     = 4000
      protocol    = "tcp"
      description = "Code locations connection"
      cidr_blocks = local.private_subnets_cidr_blocks
    }
    postgres_5432 = {
      type                     = "ingress"
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "Dagster db connection."
      source_security_group_id = data.aws_security_group.postgres.id

    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  create_task_exec_iam_role = false
  task_exec_iam_role_arn    = data.aws_iam_role.task_exec.arn

  desired_count = each.key == "webserver" ? 2 : 1 # HA webserver

  tasks_iam_role_name            = "dagster-${each.key}-task-role"
  tasks_iam_role_use_name_prefix = false
  tasks_iam_role_description     = "Allows ECS tasks management in dagster context."
  tasks_iam_role_statements = concat(
    local.base_dagster_tasks_role_statements, [local.specific_dagster_task_role_statement[each.key]]
  )
}
