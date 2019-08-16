# IAP Bastion

Google Cloud provides a way to access compute instances that are on private subnets using Identity Aware Proxy (IAP). This allows you to SSH into hosts using your Google Cloud Identity (OAuth2) and place a Bastion host on a private subnet. This module creates a Bastion with a service account attached and firewall rules configured to allow SSH via IAP.

## Example

module "iap-bastion" {
  source = 

  project = var.project
  region = var.region
  zone = var.zone
  network = google_compute_network.tools.self_link
  subnet = google_compute_subnetwork.tools.self_link
}
