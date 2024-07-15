module "postgres_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name            = "${local.project_name}-postgres-sg"
  use_name_prefix = false
  description     = "Security group for ${local.project_name}-dagster-db."
  vpc_id          = module.vpc.vpc_id

  ingress_rules       = ["postgresql-tcp"]
  ingress_cidr_blocks = ["10.0.64.0/18", "10.0.128.0/18"] # private subnets
}
