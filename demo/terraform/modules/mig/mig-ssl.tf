# ----------------------------------------------------------------------------------------------------------------------
# Create the SSL certificate
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_managed_ssl_certificate" "apigee_ssl_cert" {
  project = var.project_id
  name    = "apigee-ssl-cert"
  managed {
    domains = [var.apigee_hostname]
  }
}