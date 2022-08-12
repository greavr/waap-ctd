# ----------------------------------------------------------------------------------------------------------------------
# MIG Instance Template
# ----------------------------------------------------------------------------------------------------------------------
# Create Template
resource "google_compute_instance_template" "apigee_proxy" {
  project = var.project_id
  machine_type = "e2-micro"
  region  = var.primary-region
  name = "apigee-proxy-${var.primary-region}"
  tags = ["apigee-network-proxy", "gke-apigee-proxy", "https-server"]
  disk {
    auto_delete  = true
    boot         = true
    device_name  = "persistent-disk-0"
    disk_size_gb = 20
    mode         = "READ_WRITE"
    source_image = "projects/centos-cloud/global/images/family/centos-7"
    type         = "PERSISTENT"
  }
  network_interface {
    network            = var.vpc_id
    subnetwork         = var.subnet_id
  }
  metadata = {
    ENDPOINT           = var.apigee_hostname
    startup-script-url = "gs://apigee-5g-saas/apigee-envoy-proxy-release/latest/conf/startup-script.sh"
  }
  service_account {
    email  = var.gce-sa.email
    scopes = ["cloud-platform"]
  }
    
  labels = {
    managed-by-cnrm = "true"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    # provisioning_model  = "STANDARD"
  }
}

# Create a managed instance group
resource "google_compute_region_instance_group_manager" "mig_manager" {
  name               = "apigee-proxy-${var.primary-region}"
  project            = var.project_id
  base_instance_name = "apigee-proxy"
  region             = var.primary-region
  version {
    instance_template  = google_compute_instance_template.apigee_proxy.id
  }
  named_port {
    name = "https"
    port = 443
  }

  depends_on = [
    google_compute_instance_template.apigee_proxy
  ]
}

# Configure autoscaling for the group
resource "google_compute_region_autoscaler" "mig_autoscaler" {
  name    = "apigee-proxy-${var.primary-region}-asg"
  project = var.project_id
  region  = var.primary-region
  target  = google_compute_region_instance_group_manager.mig_manager.id
  autoscaling_policy {
    max_replicas    = 20
    min_replicas    = 2
    cooldown_period = 90
    cpu_utilization {
      target = 0.75
    }
  }

  depends_on = [
    google_compute_region_instance_group_manager.mig_manager
  ]
}