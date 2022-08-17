output "gce-sa" {
  value = google_service_account.compute_service_account
}

output "juiceshop_hostname" {
  value = "${replace(google_compute_global_address.juiceshop_lb_ip.address, ".", "-")}.nip.io"
}