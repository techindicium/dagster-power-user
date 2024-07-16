module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name  = var.domain_name
  zone_id      = var.root_zone_id

  validation_method = "DNS"

  subject_alternative_names = [
    "dagster.${var.domain_name}",
  ]

  wait_for_validation = false

}