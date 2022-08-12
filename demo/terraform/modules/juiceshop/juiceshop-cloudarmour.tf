# ----------------------------------------------------------------------------------------------------------------------
# Configure Cloud Armour
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_security_policy" "waap_policies" {
  name    = "waap-policies"
  project = var.project_id

    rule {
        action      = "allow"
        description = "Default rule, higher priority overrides it"

        match {
            config {
                src_ip_ranges = ["*"]
            }
            versioned_expr = "SRC_IPS_V1"
        }
        priority = 2147483647
    }

    rule {
        action      = "allow"
        description = "Deny all requests below 0.8 recaptcha score"

        match {
            expr {
                expression = "recaptchaTokenScore() <= 0.9"
            }
        }
        priority = 10000
    }

    rule {
        action      = "deny(403)"
        description = "Block US IP & header: Hacker"

        match {
            expr {
                expression = "origin.region_code == 'US' && request.headers['user-agent'].contains('Hacker')"
            }
        }
        priority = 7000
    }

    rule {
        action      = "deny(403)"
        description = "Regular Expression Rule"

        match {
            expr {
                expression = "request.headers['user-agent'].contains('Hacker')"
            }
        }
        priority = 7001
    }

    rule {
        action      = "deny(403)"
        description = "block sql injection"

        match {
            expr {
                expression = "evaluatePreconfiguredExpr('sqli-stable', ['owasp-crs-v030001-id942251-sqli', 'owasp-crs-v030001-id942420-sqli', 'owasp-crs-v030001-id942431-sqli', 'owasp-crs-v030001-id942460-sqli', 'owasp-crs-v030001-id942421-sqli', 'owasp-crs-v030001-id942432-sqli'])"
            }
        }
        priority = 9000
    }

    rule {
        action      = "deny(403)"
        description = "block xss"

        match {
            expr {
                expression = "evaluatePreconfiguredExpr('xss-stable', ['owasp-crs-v030001-id941110-xss', 'owasp-crs-v030001-id941120-xss', 'owasp-crs-v030001-id941130-xss', 'owasp-crs-v030001-id941140-xss', 'owasp-crs-v030001-id941160-xss', 'owasp-crs-v030001-id941170-xss', 'owasp-crs-v030001-id941180-xss', 'owasp-crs-v030001-id941190-xss', 'owasp-crs-v030001-id941200-xss', 'owasp-crs-v030001-id941210-xss', 'owasp-crs-v030001-id941220-xss', 'owasp-crs-v030001-id941230-xss', 'owasp-crs-v030001-id941240-xss', 'owasp-crs-v030001-id941250-xss', 'owasp-crs-v030001-id941260-xss', 'owasp-crs-v030001-id941270-xss', 'owasp-crs-v030001-id941280-xss', 'owasp-crs-v030001-id941290-xss', 'owasp-crs-v030001-id941300-xss', 'owasp-crs-v030001-id941310-xss', 'owasp-crs-v030001-id941350-xss', 'owasp-crs-v030001-id941150-xss', 'owasp-crs-v030001-id941320-xss', 'owasp-crs-v030001-id941330-xss', 'owasp-crs-v030001-id941340-xss'])"
            }
        }
        priority = 3000
    }

}