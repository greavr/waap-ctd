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
# Configure JuiceShop
# ----------------------------------------------------------------------------------------------------------------------
module "juiceshop" {
  source  = "./modules/juiceshop"

  project_id = var.project_id
  primary-region = module.vpc.primary_region
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.subnet_id

  apigee_org = module.apigee.apigee_org
  access_token = var.apigee-token

  depends_on = [
    google_project_service.enable-services,
    module.org_policy
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
  cloud_armour_policy = module.juiceshop.cloud_armour_policy

  subnet_id = module.vpc.subnet_id
  gce-sa = module.juiceshop.gce-sa

  apigee_hostname = module.apigee.apigee_hostname
  l4-ip = module.apigee.l4-ip
  
  depends_on = [
    module.juiceshop
  ]
}