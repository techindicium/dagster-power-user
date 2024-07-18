resource "docker_registry_image" "locations" {
  for_each = docker_image.locations
  name     = each.value.name
  triggers = {
    img_digest = each.value.repo_digest
  }
  keep_remotely = true
}

resource "docker_image" "locations" {
  for_each = module.ecr
  name     = "${each.value.repository_url}:${var.location_image_tags[each.key]}"
  build {
    context = "../../${each.key}_code_location"
  }
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset("${path.module}/../../${each.key}_code_location", "**") : filesha1("${path.module}/../../${each.key}_code_location/${f}")]))
  }
  keep_locally = true
}
