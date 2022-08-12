# ----------------------------------------------------------------------------------------------------------------------
# Organization policy
# ----------------------------------------------------------------------------------------------------------------------
resource "google_project_organization_policy" "requireShieldedVm" {
  project     = var.project_id
  constraint = "compute.requireShieldedVm"
  boolean_policy {
    enforced = false
  }
}

resource "google_project_organization_policy" "vmExternalIpAccess" {
  project     = var.project_id
  constraint = "compute.vmExternalIpAccess"
  list_policy {
    allow {
      all = true
    }
  }
}

resource "time_sleep" "wait_X_seconds" {
    depends_on = [
        google_project_organization_policy.requireShieldedVm,
        google_project_organization_policy.vmExternalIpAccess
        ]

    create_duration = var.wait-time
}