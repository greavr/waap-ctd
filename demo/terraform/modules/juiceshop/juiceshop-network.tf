# ----------------------------------------------------------------------------------------------------------------------
# Reserve External IPs
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_global_address" "juiceshop_lb_ip" {
    address_type = "EXTERNAL"
    ip_version   = "IPV4"
    name         = "juiceshop-lb-ip"
    project      = var.project_id
}

# ----------------------------------------------------------------------------------------------------------------------
# Create HealthCheck
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_health_check" "juiceshop_healthcheck" {
  check_interval_sec = 10
  healthy_threshold  = 2

  http_health_check {
    port               = 3000
    port_specification = "USE_FIXED_PORT"
    proxy_header       = "NONE"
    request_path       = "/rest/admin/application-version"
  }

  name                = "juiceshop-healthcheck"
  project             = var.project_id
  timeout_sec         = 5
  unhealthy_threshold = 3
}

# ----------------------------------------------------------------------------------------------------------------------
# Create Backend Service
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_backend_service" "juiceshop_be" {
  connection_draining_timeout_sec = 0
  health_checks                   = [google_compute_health_check.juiceshop_healthcheck.id]
  load_balancing_scheme           = "EXTERNAL"

  log_config {
    enable = true
  }

  name             = "juiceshop-be"
  port_name        = "http-juiceshop"
  project          = var.project_id
  protocol         = "HTTP"
  security_policy  = var.cloud_armour_policy.name
  session_affinity = "NONE"
  timeout_sec      = 30

  depends_on = [
    google_compute_health_check.juiceshop_healthcheck
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Create URL Map
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_url_map" "juiceshop_url_map" {
  default_service = google_compute_backend_service.juiceshop_be.id
  name            = "juiceshop-url-map"
  project         = var.project_id
  depends_on = [
    google_compute_backend_service.juiceshop_be
  ]
}


# ----------------------------------------------------------------------------------------------------------------------
# Create GCLB Target
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_target_https_proxy" "juiceshop_https_target" {
  name             = "juiceshop-https-target"
  project          = var.project_id
  quic_override    = "NONE"
  ssl_certificates = [ google_compute_managed_ssl_certificate.juiceshopcert.id ]
  url_map          = google_compute_url_map.juiceshop_url_map.id

  depends_on = [
    google_compute_managed_ssl_certificate.juiceshopcert,
    google_compute_url_map.juiceshop_url_map
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Create global forwarding rule
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_global_forwarding_rule" "juiceshop_fwd_rule" {
  ip_address            = google_compute_global_address.juiceshop_lb_ip.address
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  name                  = "juiceshop-fwd-rule"
  port_range            = "443-443"
  project               = var.project_id
  target                = google_compute_target_https_proxy.juiceshop_https_target.id

  depends_on = [
    google_compute_global_address.juiceshop_lb_ip,
    google_compute_target_https_proxy.juiceshop_https_target
  ]
}