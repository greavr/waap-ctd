# ----------------------------------------------------------------------------------------------------------------------
# Create Docker Image and Push to Repo
# ----------------------------------------------------------------------------------------------------------------------
### Clone Git Repo
resource "null_resource" "git_clone_source" {
  provisioner "local-exec" {
    command = "git clone ${var.source-repo} ${path.module}/docker"
  }
}

resource "time_sleep" "wait_for_git_seconds" {
    depends_on = [
        null_resource.git_clone_source
        ]

    create_duration = "60s"
}

### Build Docker Image
resource "null_resource" "build_submit" {
  provisioner "local-exec" {
    command = "cd ${path.module}/docker && gcloud builds submit --config=cloudbuild.yaml --substitutions=_API_ENDPOINT=${var.api_endpoint},_BASEPATH=${var.basepath},_APIKEY=${var.api_key},_RECAPTCHA_KEY=${var.recaptcha_key},_IMAGETAG=${var.docker_image_name}"
  }

  depends_on = [
    time_sleep.wait_for_git_seconds
  ]
}