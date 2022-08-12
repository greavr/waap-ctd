# ----------------------------------------------------------------------------------------------------------------------
# Firewall Rules
# ----------------------------------------------------------------------------------------------------------------------
## GCLB &  MIG
resource "google_compute_firewall" "k8s_allow_lb_to_apigee_proxy" {
  allow {
    ports    = ["443"]
    protocol = "tcp"
  }

  description   = "Allow incoming from GLB on TCP port 443 to Apigee Proxy"
  direction     = "INGRESS"
  name          = "k8s-allow-lb-to-apigee-proxy"
  network       = var.vpc_id
  priority      = 1000
  project       = var.project_id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["gke-apigee-proxy"]
}

