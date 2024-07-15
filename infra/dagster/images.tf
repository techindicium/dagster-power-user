resource "docker_registry_image" "dagster" {
  for_each = docker_image.dagster
  name     = each.value.name
  triggers = {
    img_digest = each.value.repo_digest
  }
  keep_remotely = true
}

resource "docker_image" "dagster" {
  for_each = module.ecr
  name     = "${each.value.repository_url}:${var.image_tags[each.key]}"
  build {
    context = "./docker/"
    target  = each.key == "daemon" ? "dagster" : each.key
  }
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "docker/*") : filesha1(f)]))
  }
  keep_locally = true
}
