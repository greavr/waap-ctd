# # ----------------------------------------------------------------------------------------------------------------------
# # Apigee Target Server
# # ----------------------------------------------------------------------------------------------------------------------
# resource "apigee_target_server" "target_server" {
#     environment_name = "eval"
#     name = "waap-demo-ts"
#     host = "${replace(google_compute_global_address.juiceshop_lb_ip.address, ".", "-")}.nip.io"
#     port = 443
#     ssl_enabled = true
# }

# # ----------------------------------------------------------------------------------------------------------------------
# # Create Developer Account
# # ----------------------------------------------------------------------------------------------------------------------
# resource "apigee_developer" "waap_developer" {
#     email = "developer@waap.com"
#     first_name = "waap"
#     last_name = "developer"
#     user_name = "waap"
# }


# resource "apigee_developer_app" "waap_developer_app" {
#     developer_email = apigee_developer.waap_developer.email
#     name = "waap-app"
# }