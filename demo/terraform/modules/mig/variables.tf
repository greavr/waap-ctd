variable "project_id" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "primary-region" {}
variable "apigee_hostname" {}
variable "l4-ip" {}
variable "cloud_armour_policy" {}
variable "gce_service_account_roles" {
    default     = [
        "compute.instanceAdmin.v1",
        "storage.objectViewer",
        "compute.networkAdmin"
    ]
}
