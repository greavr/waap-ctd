# ----------------------------------------------------------------------------------------------------------------------
# Create Artifact Repository
# ----------------------------------------------------------------------------------------------------------------------
resource "google_artifact_registry_repository" "waap_apigee_repo" {
  format        = "DOCKER"
  location      = var.primary-region
  project       = var.project_id
  repository_id = "waap-apigee-repo"
}