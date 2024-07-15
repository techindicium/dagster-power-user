module "postgres" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${local.project_name}-db"

  engine                = "postgres"
  engine_version        = "15.5"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = "dagster"
  username = "dagster"
  port     = "5432"

  vpc_security_group_ids = [module.postgres_sg.security_group_id]

  backup_retention_period = 1
  copy_tags_to_snapshot   = true

  monitoring_interval = 0


  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets

  # Database Deletion Protection
  deletion_protection = false

  create_db_option_group    = false
  create_db_parameter_group = false

}
