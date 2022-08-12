# ----------------------------------------------------------------------------------------------------------------------
# Create Apigee SA
# ----------------------------------------------------------------------------------------------------------------------
resource "google_project_service_identity" "apigee_sa" {
  provider = google-beta
  project  = var.project_id
  service  = "apigee.googleapis.com"
}

resource "google_kms_crypto_key_iam_binding" "apigee_sa_keyuser" {
  provider      = google
  crypto_key_id = google_kms_crypto_key.apigeekey.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = [
    "serviceAccount:${google_project_service_identity.apigee_sa.email}",
  ]
}