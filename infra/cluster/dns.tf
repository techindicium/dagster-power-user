resource "aws_route53_record" "dagster" {
  zone_id = var.root_zone_id
  name    = "dagster"
  type    = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}