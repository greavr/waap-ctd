# ----------------------------------------------------------------------------------------------------------------------
# Configure Firewall Rules
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_firewall" "allow_all_egress_juiceshop_https" {
  allow {
    ports    = ["443"]
    protocol = "tcp"
  }

  destination_ranges = ["0.0.0.0/0"]
  direction          = "EGRESS"
  name               = "allow-all-egress-juiceshop-https"
  network            = var.vpc_id
  priority           = 1000
  project            = var.project_id
  target_tags        = ["juiceshop"]
}


resource "google_compute_firewall" "allow_juiceshop_demo_lb_health_check" {
  allow {
    ports    = ["80", "443", "3000"]
    protocol = "tcp"
  }

  direction     = "INGRESS"
  name          = "allow-juiceshop-demo-lb-health-check"
  network       = var.vpc_id
  priority      = 1000
  project       = var.project_id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["juiceshop"]
}

resource "google_compute_firewall" "allow_web" {
  allow {
    ports    = ["80","443","3000"]
    protocol = "tcp"
  }

  direction     = "INGRESS"
  name          = "default-allow-http"
  network       = var.vpc_id
  priority      = 1000
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}


resource "google_compute_firewall" "allow_all_internal" {
  allow {
    protocol = "all"
  }


  description   = "Allows connection from any source to any instance on the network using custom protocols."
  direction     = "INGRESS"
  name          = "default-allow-custom"
  network       = var.vpc_id
  priority      = 65534
  project       = var.project_id
  source_ranges = ["10.0.32.0/20"]
}

resource "google_compute_firewall" "default_allow_iap" {
  allow {
    ports    = ["3389","22"]
    protocol = "tcp"
  }

  description   = "Allows RDP/SSH connections from IAP."
  direction     = "INGRESS"
  name          = "all-rdp-ssh-iap"
  network       = var.vpc_id
  priority      = 65534
  project       = var.project_id
  source_ranges = ["35.235.240.0/20"]
}
