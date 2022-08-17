# ----------------------------------------------------------------------------------------------------------------------
# Variables
# ----------------------------------------------------------------------------------------------------------------------
variable "vpc-name" {
    type = string
    description = "Custom VPC Name"
    default = "apigee-waap-demo"
}

# List of regions (support for multi-region deployment)
variable "regions" { 
    type = list(object({
        region = string
        cidr = string
        })
    )
    default = [
        {
            region = "us-east1"
            cidr = "10.0.32.0/20"
        }]
}

# Service to enable
variable "services_to_enable" {
    description = "List of GCP Services to enable"
    type    = list(string)
    default =  [
        "compute.googleapis.com",
        "iap.googleapis.com",
        "apigee.googleapis.com",
        "cloudresourcemanager.googleapis.com",
        "cloudbuild.googleapis.com",
        "iam.googleapis.com",
        "logging.googleapis.com",
        "monitoring.googleapis.com",
        "compute.googleapis.com",
        "serviceusage.googleapis.com",
        "stackdriver.googleapis.com",
        "servicemanagement.googleapis.com",
        "servicecontrol.googleapis.com",
        "storage.googleapis.com",
        "servicenetworking.googleapis.com",
        "cloudkms.googleapis.com",
        "containerregistry.googleapis.com",
        "run.googleapis.com",
        "recaptchaenterprise.googleapis.com",
        "artifactregistry.googleapis.com"
    ]
}

variable "apigee-token" {
    default = "ya29.A0AVA9y1uYdniO73mw75NcbgM8BZz_fzaLaryMtTtKLtICLP2aSIPklUITZDO1PRQxlSf32ffV59Eg21E5_DiuxQot9EureJ7Z1i1TGAvzdJIzMemFsblPfTdmbrV3bJKIADIQEgYb9GYqE6esa1qWPE4J3rWhvq6ThpI0V-8-MrpoKyxiF-Sy-gq3kPQ-EymByxTOVsP3feNERCNqiRm8HqmgVL9pQ3J_6a5vf7kff63miZ3NaaGRT5puN5Son6wPrM402D_T2gYUNnWUtBVEFTQVRBU0ZRRTY1ZHI4M0JFZlVPRlQ0VEkwWjVDSU5ncENGdw0273"
}


variable "gcs-bucket-name" {
    default = "juiceshop-code" 
}

locals {
    docker_image_name = "gcr.io/${var.project_id}/owasp-juice-shop"  
}

# ----------------------------------------------------------------------------------------------------------------------
# CTD Required
# ----------------------------------------------------------------------------------------------------------------------
variable "project_id" {
  type        = string
  description = "project id required"
}
# variable "project_name" {
#  type        = string
#  description = "project name in which demo deploy"
# }
# variable "project_number" {
#  type        = string
#  description = "project number in which demo deploy"
# }
# variable "gcp_account_name" {
#  description = "user performing the demo"
# }
# variable "deployment_service_account_name" {
#  description = "Cloudbuild_Service_account having permission to deploy terraform resources"
# }
# variable "org_id" {
#  description = "Organization ID in which project created"
# }
# variable "data_location" {
#  type        = string
#  description = "Location of source data file in central bucket"
# }
# variable "secret_stored_project" {
#   type        = string
#   description = "Project where secret is accessing from"
# }