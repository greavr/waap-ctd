terraform {
	backend "gcs" {
		bucket = "rgreaves-ctd-waap-terraform"
		prefix = "terraform/state"
	}
}