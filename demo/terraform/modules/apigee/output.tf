output "apigee_hostname" {
    value = "${replace(google_compute_global_address.lb_ipv4_vip_1.address, ".", "-")}.nip.io"
}

output "l4-ip" {
    value = google_compute_global_address.lb_ipv4_vip_1.address
}


output "apigee_org" {
    value = google_apigee_organization.apigee_org
}