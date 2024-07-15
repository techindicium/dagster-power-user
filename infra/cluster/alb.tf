module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "${local.project_name}-alb"
  vpc_id  = data.aws_vpc.dagster.id
  subnets = data.aws_subnets.public.ids

  # Security Group
  security_group_name            = "${local.project_name}-alb-sg"
  security_group_use_name_prefix = false
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    http-redirect = {
      port     = 80
      protocol = "HTTP"

      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.acm.acm_certificate_arn

      forward = {
        target_group_key = "dagster"
      }
    }
  }

  target_groups = {
    dagster = {
      name              = "dagster"
      protocol          = "HTTP"
      port              = 80
      target_type       = "ip"
      create_attachment = false
      health_check = {
        enabled             = true
        path                = "/server_info"
        healthy_threshold   = 2
        unhealthy_threshold = 10
        protocol            = "HTTP"
      }
    }
  }

  enable_deletion_protection = false
}
