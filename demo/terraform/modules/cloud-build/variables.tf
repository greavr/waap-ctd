variable "project_id" {}
variable "primary-region" {}
variable "gcs-bucket-name" {}

variable "source-repo" {
  default ="https://github.com/ssvaidyanathan/juice-shop.git"
}

variable "docker_image_name" {}
variable "recaptcha_key" {}
variable "api_endpoint" {}
variable "api_key" {}
variable "apigee_env" {
    default = "eval"
}
variable "basepath" {
  default = "/owasp"
}