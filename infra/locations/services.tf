module "ecs_service" {
  source   = "terraform-aws-modules/ecs/aws//modules/service"
  for_each = docker_registry_image.locations

  name        = "${each.key}-code-location"
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

        cloudwatch_log_group_name = "/aws/ecs/${each.key}-code-location"


        command = split(" ", "dagster code-server start -h 0.0.0.0 -p 4000 -m definitons")

        secrets = each.key == "el" ? concat(
          [
            for key, _ in var.el_env :
            {
              "name" : "${key}",
              "valueFrom" : module.el_secrets[key].secret_arn
            }
          ],
          [
            for var in local.dagster_env_vars :
            {
              "name" : "${var}",
              "valueFrom" : data.aws_secretsmanager_secret.postgres[var].arn
            }
          ]
          ) : concat(
          [
            for key, _ in var.dbt_env :
            {
              "name" : "${key}",
              "valueFrom" : module.dbt_secrets[key].secret_arn
            }
          ],
          [
            for var in local.dagster_env_vars :
            {
              "name" : "${var}",
              "valueFrom" : data.aws_secretsmanager_secret.postgres[var].arn
            }
          ]
        )

        environment = [
          {
            name  = "DAGSTER_CURRENT_IMAGE"
            value = each.value.name
          }
        ]

        service = "${each.key}-code-location"

        # images used require access to write to root filesystem
        readonly_root_filesystem = false
      },
      {
        log_configuration = {
          options = {
            awslogs-region        = var.region
            awslogs-group         = "/aws/ecs/${each.key}-code-location"
            awslogs-create-group  = "true"
            awslogs-stream-prefix = "ecs"
          }
        },
        port_mappings = [
          {
            name          = each.key
            containerPort = 4000
            protocol      = "tcp"
          }
        ]

      }
    )
  }

  service_connect_configuration = {
    service = {
      client_alias = {
        port     = 4000
        dns_name = "${each.key}-code-location"
      }
      port_name      = each.key
      discovery_name = "${each.key}-code-location"
    }
  }

  subnet_ids = data.aws_subnets.private.ids

  security_group_rules = {
    dagster_instance_4000 = {
      type        = "ingress"
      from_port   = 4000
      to_port     = 4000
      protocol    = "tcp"
      description = "Talk to dagster instance."
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

}
