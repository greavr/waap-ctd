# ----------------------------------------------------------------------------------------------------------------------
# Create KMS
# ----------------------------------------------------------------------------------------------------------------------
## Create Key Ring
resource "google_kms_key_ring" "apigeering" {
  provider   = google
  location   = var.primary-region
  name       = "apigee_ring"
  project    = var.project_id

}
## Create Key 
resource "google_kms_crypto_key" "apigeekey" {
  key_ring                   = google_kms_key_ring.apigeering.id
  name                       = "apigee_key"
  purpose                    = "ENCRYPT_DECRYPT"
  provider                   = google
  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "SOFTWARE"
  }

}
