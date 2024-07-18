variable "location_image_tags" {
  type        = map(string)
  description = "A map from each code location to its image tag to deploy."
  default = {
    el  = "v0.0.1"
    dbt = "v0.0.1"
  }

}

variable "region" {
  type        = string
  description = "The AWS region to deploy resources."
  default     = "us-east-1"
}

variable "el_env" {
  type        = map(string)
  description = "Env vars for configuring dagster el code location."
}

variable "dbt_env" {
  type        = map(string)
  description = "Env vars for configuring dagster dbt code location."
}
