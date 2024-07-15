module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.project_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["10.0.64.0/18", "10.0.128.0/18"]
  public_subnets  = ["10.0.0.0/19", "10.0.32.0/19"]
  
  private_subnet_tags = {
    Tier = "Private"
  }

  public_subnet_tags = {
    Tier = "Public"
  }

  enable_nat_gateway     = true
  one_nat_gateway_per_az = true

}

