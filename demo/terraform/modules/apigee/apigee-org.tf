# ----------------------------------------------------------------------------------------------------------------------
# Create Apigee Org
# ----------------------------------------------------------------------------------------------------------------------
resource "google_apigee_organization" "apigee_org" {
  project_id                           = var.project_id
  analytics_region                     = var.primary-region

  description                          = "Terraform-provisioned Apigee Org"
  authorized_network                   = var.vpc_id
  
  runtime_database_encryption_key_name = google_kms_crypto_key.apigeekey.id
  
  depends_on = [
    google_service_networking_connection.apigee_vpc_connection,
    google_kms_crypto_key_iam_binding.apigee_sa_keyuser,
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Create Apigee Environment
# ----------------------------------------------------------------------------------------------------------------------
resource "google_apigee_environment" "apigee_env" {
  org_id = google_apigee_organization.apigee_org.id
  name   = "eval"
  depends_on = [
    google_apigee_organization.apigee_org
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Create Apigee Environment Group
# ----------------------------------------------------------------------------------------------------------------------
resource "google_apigee_envgroup" "apigee_envgroup" {
  org_id    = google_apigee_organization.apigee_org.id
  name      = "eval-group"
  hostnames = [local.apigee_hostname]

  depends_on = [
    google_apigee_environment.apigee_env
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Attach the Apigee Environment to the Environment Group
# ----------------------------------------------------------------------------------------------------------------------
resource "google_apigee_envgroup_attachment" "env_to_envgroup_attachment" {
  envgroup_id = google_apigee_envgroup.apigee_envgroup.id
  environment = google_apigee_environment.apigee_env.name

  depends_on = [
    google_apigee_envgroup.apigee_envgroup,
    google_apigee_environment.apigee_env
  ]
}