terraform {
  required_version = ">= 1.1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.31.0"
    }
    google-beta = {
      source = "hashicorp/google-beta"
      version = "~> 4.10.0"
    }
    time = {
      source = "hashicorp/time"
      version = "~> 0.7.2"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.3.1"
    }  
    apigee = {
      source  = "scastria/apigee"
      version = "~> 0.1.51"
    }  
  }
}