output "service_account" {
  value = google_service_account.bastion.email
}

output "instance" {
  value = google_compute_instance.bastion
}
