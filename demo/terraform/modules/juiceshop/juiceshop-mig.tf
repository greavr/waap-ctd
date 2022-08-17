# ----------------------------------------------------------------------------------------------------------------------
# Juiceshop GCE Container Setup
# ----------------------------------------------------------------------------------------------------------------------
module "gce-container" {
  source = "terraform-google-modules/container-vm/google"
  version = "~> 3.0"

  container = {
    name = "juiceshop-demo-mig-template"
    image = var.docker_image_name
    securityContext = {
      privileged : false
    }
    stdin : false
    tty : true

    # Declare volumes to be mounted.
    # This is similar to how docker volumes are declared.
    volumeMounts = []
  }

  # Declare the Volumes which will be used for mounting.
  volumes = []

  restart_policy = "Always"
}

# ----------------------------------------------------------------------------------------------------------------------
# Create GCE SA
# ----------------------------------------------------------------------------------------------------------------------
resource "google_service_account" "compute_service_account" {
  account_id   = "compute-service-account"
  display_name = "Compute Engine default service account"
  project      = var.project_id
}

# ----------------------------------------------------------------------------------------------------------------------
# Create Instance Template
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_instance_template" "juiceshop_demo_mig_template" {
  disk {
    auto_delete  = true
    boot         = true
    device_name  = "juiceshop-demo-template"
    disk_size_gb = 10
    disk_type    = "pd-balanced"
    mode         = "READ_WRITE"
    source_image = "https://compute.googleapis.com/compute/v1/projects/cos-cloud/global/images/cos-stable-89-16108-470-1"
    type         = "PERSISTENT"
  }

  labels = {
    container-vm = "cos-stable-89-16108-470-1"
  }

  machine_type = "n2-standard-2"

  metadata = {
    #gce-container-declaration = module.gce-container.metadata_value
    google-logging-enabled    = "true"
  }

  name = "juiceshop-demo-mig-template"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    network            = "${var.vpc_id}"
    subnetwork         = "${var.subnet_id}"
  }

  project = var.project_id
  region  = var.primary-region

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    # provisioning_model  = "STANDARD"
  }

  service_account {
    email  = google_service_account.compute_service_account.email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_vtpm                 = true
  }

  tags = ["http-server", "https-server", "juiceshop"]

  depends_on = [
    google_service_account.compute_service_account,
    #module.gce-container
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Create Mig
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_region_instance_group_manager" "mig_manager_juiceshop" {
  name               = "juiceshop-demo-mig"
  project            = var.project_id
  base_instance_name = "juiceshop-demo-mig"
  region             = var.primary-region
  version {
    instance_template  = google_compute_instance_template.juiceshop_demo_mig_template.id
  }
  named_port {
    name = "http-juiceshop"
    port = 3000
  }

  depends_on = [
    google_compute_instance_template.juiceshop_demo_mig_template
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Create Autoscaler Profile
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_region_autoscaler" "mig_autoscaler_juiceshop" {
  name    = "juiceshop-demo-mig-autoscaler"
  project = var.project_id
  region  = var.primary-region
  target  = google_compute_region_instance_group_manager.mig_manager_juiceshop.id
  autoscaling_policy {
    max_replicas    = 2
    min_replicas    = 1
    cooldown_period = 60
    cpu_utilization {
      target = 0.60
    }
  }

  depends_on = [
    google_compute_region_instance_group_manager.mig_manager_juiceshop
  ]
}