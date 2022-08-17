# ----------------------------------------------------------------------------------------------------------------------
# MIG SA
# ----------------------------------------------------------------------------------------------------------------------
resource "google_service_account" "apigee-gce-sa" {
    account_id   = "apigee-gce-sa"
    display_name = "apigee-gce-sa"
}

resource "google_project_iam_member" "service_account-roles" {
    project = var.project_id
    for_each = toset(var.gce_service_account_roles)
    role    = "roles/${each.value}"
    member  = "serviceAccount:${google_service_account.apigee-gce-sa.email}"
    depends_on = [
        google_service_account.apigee-gce-sa
        ]
}