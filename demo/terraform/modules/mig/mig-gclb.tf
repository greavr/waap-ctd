# ----------------------------------------------------------------------------------------------------------------------
# L7 GCLB
# ----------------------------------------------------------------------------------------------------------------------
# Create a health check
resource "google_compute_health_check" "hc_apigee_proxy_443" {
  check_interval_sec = 5
  healthy_threshold  = 2

  https_health_check {
    port               = 443
    port_specification = "USE_FIXED_PORT"
    proxy_header       = "NONE"
    request_path       = "/healthz/ingress"
  }

  name                = "hc-apigee-proxy-443"
  project             = var.project_id
  timeout_sec         = 5
  unhealthy_threshold = 2
}

# Create a backend service
resource "google_compute_backend_service" "apigee_proxy_backend" {
  connection_draining_timeout_sec = 300
  health_checks                   = [google_compute_health_check.hc_apigee_proxy_443.id]
  load_balancing_scheme           = "EXTERNAL"
  name                            = "apigee-proxy-backend"
  port_name                       = "https"
  project                         = var.project_id
  protocol                        = "HTTPS"
  security_policy                 = var.cloud_armour_policy.name
  session_affinity                = "NONE"
  timeout_sec                     = 60
  backend {
    group = google_compute_region_instance_group_manager.mig_manager.instance_group
  }

  depends_on = [
    google_compute_firewall.k8s_allow_lb_to_apigee_proxy,
    google_compute_health_check.hc_apigee_proxy_443
  ]
}

# Create a Load Balancing URL map
resource "google_compute_url_map" "apigee_proxy_map" {
  default_service = google_compute_backend_service.apigee_proxy_backend.id
  name            = "apigee-proxy-map"
  project         = var.project_id

  depends_on = [
    google_compute_backend_service.apigee_proxy_backend
  ]
}

# Create a Load Balancing target HTTPS proxy
resource "google_compute_target_https_proxy" "apigee_proxy_https_proxy" {
  name             = "apigee-proxy-https-proxy"
  project          = var.project_id
  quic_override    = "NONE"
  ssl_certificates = [google_compute_managed_ssl_certificate.apigee_ssl_cert.id]
  url_map          = google_compute_url_map.apigee_proxy_map.id

  depends_on = [
    google_compute_managed_ssl_certificate.apigee_ssl_cert,
    google_compute_url_map.apigee_proxy_map
  ]
}

# Create a global forwarding rule
resource "google_compute_global_forwarding_rule" "apigee_proxy_https_lb_rule" {
  ip_address            = var.l4-ip
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  name                  = "apigee-proxy-https-lb-rule"
  port_range            = "443-443"
  project               = var.project_id
  target                = google_compute_target_https_proxy.apigee_proxy_https_proxy.id

  depends_on = [
    google_compute_target_https_proxy.apigee_proxy_https_proxy
  ]
}