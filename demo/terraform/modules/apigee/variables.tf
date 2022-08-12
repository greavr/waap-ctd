variable "project_id" {}
variable "vpc_id" {}
variable "primary-region" {}

locals {
  apigee_hostname = "${replace(google_compute_global_address.lb_ipv4_vip_1.address, ".", "-")}.nip.io"
 }