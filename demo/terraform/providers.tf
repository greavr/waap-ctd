# ----------------------------------------------------------------------------------------------------------------------
# Configure Providers
# ----------------------------------------------------------------------------------------------------------------------
provider "google" {
  project       = var.project_id
}

provider "google-beta" {
  project       = var.project_id
}

provider "apigee" {
  alias = "custom"
  access_token = var.access_token
  organization = module.apigee.apigee_org
}

# ----------------------------------------------------------------------------------------------------------------------
# DATA
# ----------------------------------------------------------------------------------------------------------------------
data "google_project" "project" {}
data "google_client_config" "current" {}

