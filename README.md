# IAP Bastion

Google Cloud provides a way to access compute instances that are on private subnets using [Identity Aware Proxy (IAP)](https://cloud.google.com/iap/docs/using-tcp-forwarding). This allows you to SSH into hosts using your Google Cloud Identity (OAuth2) with [OS Login](https://cloud.google.com/compute/docs/instances/managing-instance-access) and place a Bastion host on a private subnet. This module creates a Bastion with a service account attached and firewall rules configured to allow SSH via IAP. OS Login is enabled by default, so if you cannot immediately login with SSH, ensure your user has the `roles/oslogin.User` or `roles/oslogin.Admin`

## Usage

```
module "iap_bastion" {
  source = "onetwopunch/iap-bastion/google"
  version = "0.1.1"

  project = var.project
  region = var.region
  zone = var.zone
  network = google_compute_network.net.self_link
  subnet = google_compute_subnetwork.net.self_link
}

resource "google_compute_firewall" "allow_access_from_bastion" {
  project = var.project
  name    = "allow-bastion-ssh"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Allow SSH only from IAP Bastion
  source_service_accounts = [module.iap_bastion.service_account]
  target_tags = ["bastion-ssh"]
}
```

### Connecting via SSH

```
gcloud compute ssh bastion
```

if you want to use standard SSH with tools like Ansible, you can also [add the wrapper script to your ssh-config](https://cloud.google.com/sdk/gcloud/reference/compute/config-ssh) using:

```
gcloud compute config-ssh
```

## Inputs
See the inputs on the [Terraform module registry](https://registry.terraform.io/modules/onetwopunch/iap-bastion/google). Be sure to choose the version that corresponds to the version of the module you are using locally.

# Outputs
See the outputs on the [Terraform module registry](https://registry.terraform.io/modules/onetwopunch/iap-bastion/google). Be sure to choose the version that corresponds to the version of the module you are using locally.
