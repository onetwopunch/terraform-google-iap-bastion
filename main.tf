provider "google" {
  project = var.project
  region  = var.region
}

locals{
  subnet_project = (var.subnet_project == null ? var.project : var.subnet_project)
  metadata = (var.enable_oslogin == true ? {"enable-oslogin" : "TRUE"} : {})
}

resource "google_service_account" "bastion" {
  account_id   = var.service_account_name
  display_name = var.service_account_name
}

resource "google_project_iam_member" "service_account" {
  count   = length(var.service_account_iam_roles)
  project = var.project
  role    = element(var.service_account_iam_roles, count.index)
  member  = "serviceAccount:${google_service_account.bastion.email}"
}

resource "google_project_iam_member" "additional_service_account" {
  count   = length(var.additional_service_account_iam_roles)
  project = var.project
  role    = element(var.additional_service_account_iam_roles, count.index)
  member  = "serviceAccount:${google_service_account.bastion.email}"
}

resource "google_compute_instance" "bastion" {
  project = var.project
  zone    = var.zone
  name    = var.instance_name

  machine_type = var.machine_type

  network_interface {
    subnetwork         = var.subnet
    subnetwork_project = var.subnet_project
  }

  service_account {
    email  = google_service_account.bastion.email
    scopes = var.scopes
  }

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  scratch_disk {}
  metadata_startup_script = var.startup_script

  shielded_instance_config {
    enable_secure_boot = (var.shielded_vm == true ? true : false)
  }
}

# Allow SSHing into machines tagged "allow-ssh"
resource "google_compute_firewall" "allow_ssh" {
  project = var.project
  name    = "allow-iap-ssh"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Allow SSH only from IAP
  source_ranges           = ["35.235.240.0/20"]
  target_service_accounts = [google_service_account.bastion.email]
}
