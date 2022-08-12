# ----------------------------------------------------------------------------------------------------------------------
# Create the Apigee Instance
# ----------------------------------------------------------------------------------------------------------------------
resource "google_apigee_instance" "apigee_instance" {
  name          = "eval-instance"
  location      = var.primary-region
  description   = "Terraform-provisioned Apigee Runtime Instance"
  org_id        = google_apigee_organization.apigee_org.id
  disk_encryption_key_name = google_kms_crypto_key.apigeekey.id

  depends_on = [
    google_apigee_organization.apigee_org,
    google_kms_crypto_key.apigeekey
  ]
}


# ----------------------------------------------------------------------------------------------------------------------
# Attach the Apigee Environment to the Instance
# ----------------------------------------------------------------------------------------------------------------------
resource "google_apigee_instance_attachment" "env_to_instance_attachment" {
  instance_id = google_apigee_instance.apigee_instance.id
  environment = google_apigee_environment.apigee_env.name

  depends_on = [
    google_apigee_environment.apigee_env,
    google_apigee_instance.apigee_instance
  ]
}