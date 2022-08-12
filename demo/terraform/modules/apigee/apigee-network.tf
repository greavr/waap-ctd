# ----------------------------------------------------------------------------------------------------------------------
# Reserve the peering ip range for Apigee (/22 for eval)
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_global_address" "google_managed_apigee" {
  address_type  = "INTERNAL"
  description   = "Peering range for Google Apigee X Tenant"
  name          = "google-managed-apigee"
  network       = var.vpc_id
  prefix_length = 22
  project       = var.project_id
  purpose       = "VPC_PEERING"
}

# ----------------------------------------------------------------------------------------------------------------------
# Reserve the peering ip range for Apigee (/28 for eval) - troubleshooting
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_global_address" "google_managed_apigee_support" {
  address_type  = "INTERNAL"
  description   = "Peering range for supporting Apigee services"
  name          = "google-managed-apigee-support"
  network       = var.vpc_id
  prefix_length = 28
  project       = var.project_id
  purpose       = "VPC_PEERING"
}

# ----------------------------------------------------------------------------------------------------------------------
# Create the peering service networking connection
# ----------------------------------------------------------------------------------------------------------------------
resource "google_service_networking_connection" "apigee_vpc_connection" {
  network                 = var.vpc_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    google_compute_global_address.google_managed_apigee.name
    ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Reserve the external IP address
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_global_address" "lb_ipv4_vip_1" {
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
  name         = "lb-ipv4-vip-1"
  project      = var.project_id
}