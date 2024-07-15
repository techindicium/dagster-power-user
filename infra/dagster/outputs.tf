output "dagster_webserver_url" {
  description = "URL for accessing dagster webserver."
  value       = "https://dagster.${var.domain_name}"
}
