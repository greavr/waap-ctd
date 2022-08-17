# ----------------------------------------------------------------------------------------------------------------------
# Main modules
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# ORG Policies
# ----------------------------------------------------------------------------------------------------------------------
module "org_policy" {
  source  = "./modules/org_policy"

  project_id = var.project_id
}

# ----------------------------------------------------------------------------------------------------------------------
# Enable APIs
# ----------------------------------------------------------------------------------------------------------------------
resource "google_project_service" "enable-services" {
  for_each = toset(var.services_to_enable)

  project = var.project_id
  service = each.value
  disable_on_destroy = false
}

# ----------------------------------------------------------------------------------------------------------------------
# Configure VPC
# ----------------------------------------------------------------------------------------------------------------------
module "vpc" {
  source  = "./modules/vpc"
  project_id = var.project_id
  regions = var.regions
  vpc-name = var.vpc-name
  
  depends_on = [
    google_project_service.enable-services,
    module.org_policy
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Configure ReCaptcha
# ----------------------------------------------------------------------------------------------------------------------
module "recaptcha" {
  source  = "./modules/recaptcha"
  project_id = var.project_id
  
  depends_on = [
    google_project_service.enable-services,
    module.org_policy
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Configure Cloud Armour
# ----------------------------------------------------------------------------------------------------------------------
module "cloud-armour" {
  source  = "./modules/cloud-armour"
  project_id = var.project_id
  
  depends_on = [
    google_project_service.enable-services,
    module.org_policy
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Configure APIGEE
# ----------------------------------------------------------------------------------------------------------------------
module "apigee" {
  source  = "./modules/apigee"
  project_id = var.project_id
  primary-region = module.vpc.primary_region
  vpc_id = module.vpc.vpc_id
  
  depends_on = [
    module.vpc
  ]
}


# ----------------------------------------------------------------------------------------------------------------------
# Configure 3P Apigee
# ----------------------------------------------------------------------------------------------------------------------
provider "apigee" {
  access_token = data.google_client_config.current.access_token
  organization = module.apigee.apigee_org.id
}

# ----------------------------------------------------------------------------------------------------------------------
# Configure 3P Apigee Developer
# ----------------------------------------------------------------------------------------------------------------------
resource "apigee_developer" "waap_developer" {
  email = "developer@waap.com"
  first_name = "waap"
  last_name = "developer"
  user_name = "waap"

  depends_on = [
    module.apigee
  ]
}

resource "apigee_developer_app" "waap_developer_app" {
  developer_email = apigee_developer.waap_developer.email
  name = "waap-app"

  depends_on = [
    apigee_developer.waap_developer
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Build JuiceShop image
# ----------------------------------------------------------------------------------------------------------------------
module "cloud-build" {
  source = "./modules/cloud-build"

  project_id = var.project_id
  primary-region = module.vpc.primary_region
  gcs-bucket-name = var.gcs-bucket-name

  recaptcha_key = module.recaptcha.recaptcha-key
  api_endpoint = module.apigee.apigee_hostname
  api_key = "12345"
  docker_image_name = local.docker_image_name

  depends_on = [
    module.vpc,
    module.recaptcha,
    module.apigee
  ]
  
}


# ----------------------------------------------------------------------------------------------------------------------
# Configure JuiceShop
# ----------------------------------------------------------------------------------------------------------------------
module "juiceshop" {
  source  = "./modules/juiceshop"

  project_id = var.project_id
  primary-region = module.vpc.primary_region
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.subnet_id

  docker_image_name = local.docker_image_name
  cloud_armour_policy = module.cloud-armour.cloud-armour-policy

  depends_on = [
    module.cloud-build,
    module.cloud-armour
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Create Apigee Target Server
# ---------------------------------------------------------------------------------------------------------------------- 
resource "apigee_target_server" "target_server" {
  environment_name = "eval"
  name = "waap-demo-ts"
  host = "test.com"
  port = 443
  ssl_enabled = true

  depends_on = [
    google_project_service.enable-services
  ]
}

resource "apigee_proxy" "apigee_proxy_bundle" {
  name = "waap-demo-proxy-bundle"
  bundle = "waap-demo-proxy-bundle.zip"
  bundle_hash = filebase64sha256("waap-demo-proxy-bundle.zip")

  depends_on = [
    google_project_service.enable-services
  ]
}

resource "apigee_proxy_deployment" "proxy_deployment" {
  proxy_name = apigee_proxy.apigee_proxy_bundle.name
  environment_name = "eval"
  revision = apigee_proxy.apigee_proxy_bundle.revision

  depends_on = [
    apigee_proxy.apigee_proxy_bundle
  ]
}

resource "apigee_product" "waap_api_product" {
  name = "waap-product"
  display_name = "waap-product"
  auto_approval_type = true
  description = "WAAP Product API"
  environments = [
    "eval"
  ]
  attributes = {
    access = "public"
  }
  operation {
    api_source = apigee_proxy.apigee_proxy_bundle.name
    path       = "/"
    methods    = [
        "GET",
        "POST"
    ]
  }

  depends_on = [
    apigee_proxy.apigee_proxy_bundle
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Configure MIG
# ----------------------------------------------------------------------------------------------------------------------
module "mig" {
  source  = "./modules/mig"
  project_id = var.project_id
  primary-region = module.vpc.primary_region
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.subnet_id

  cloud_armour_policy = module.cloud-armour.cloud-armour-policy

  apigee_hostname = module.apigee.apigee_hostname
  l4-ip = module.apigee.l4-ip
  
  depends_on = [
    module.apigee
  ]
}