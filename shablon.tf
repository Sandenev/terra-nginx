#файл шаблон для создания пустых инстансев в гугл клауде
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.59.0"
    }
  }
}

provider "google" {
  # Configuration options
  credentials = file("cred_file.json")
  project     = "имя проекта"
  region      = "us-central1"
  zone      = "us-central1-a"
}

resource "google_compute_instance" "terra-shablon" {
  name         = "terra-shablon"
  #machine_type = "e2-micro" // 2vCPU, 1 GB RAM
  machine_type = "e2-small" // 2vCPU, 2GB RAM
  #machine_type = "e2-medium" // 2vCPU, 4GB RAM
  #machine_type = "custom-6-20480" // 6vCPU, 20GB RAM / 6.5GB RAM per CPU, if needed more refer to next line
  #machine_type = "custom-2-15360-ext" // 2vCPU, 15GB RAM

  #tags = ["terra", "shablon"]
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      size = "10" // size in GB for Disk
      type = "pd-balanced" // Available options: pd-standard, pd-balanced, pd-ssd
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP and external static IP
      #nat_ip = google_compute_address.static.address
    }
  }

  metadata = {
    ssh-keys = "root:${file("/root/.ssh/id_rsa.pub")}" // Point to ssh public key for user root
  }
}
