# ----------------------------------------------------------------------------------------------------------------------
# Generate Web Recaptcha Key
# ----------------------------------------------------------------------------------------------------------------------
resource "google_recaptcha_enterprise_key" "primary" {
  display_name = "juiceshop-session-token-key"

  project = var.project_id

  web_settings {
    integration_type  = "SCORE"
    allow_all_domains = true
  }
}