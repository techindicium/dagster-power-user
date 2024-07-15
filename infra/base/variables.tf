variable "region" {
  type        = string
  description = "The AWS region to deploy resources."
  default     = "us-east-1"
}

variable "image_tags" {
  type        = map(string)
  description = "A map for each component of a dagster instance (webserver, daemon) to its image tag to deploy."
  default = {
    webserver = "v0.0.1"
    daemon    = "v0.0.1"
  }

}

variable "domain_name" {
  type        = string
  description = "The route53 domain for DNS."
  default     = "training-indicium.com"

}

variable "root_zone_id" {
  type        = string
  description = "The id of the route53 domain root hosted zone (i.e. the zone that contains the domain registered name servers)"

}
