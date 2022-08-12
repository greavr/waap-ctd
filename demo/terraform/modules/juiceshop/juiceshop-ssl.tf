# ----------------------------------------------------------------------------------------------------------------------
# Create GCLB Target
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_managed_ssl_certificate" "juiceshopcert" {
  project = var.project_id
  name    = "juiceshopcert"
  managed {
    domains = ["${replace(google_compute_global_address.juiceshop_lb_ip.address, ".", "-")}.nip.io"]
  }

  depends_on = [
    google_compute_global_address.juiceshop_lb_ip
  ]
}