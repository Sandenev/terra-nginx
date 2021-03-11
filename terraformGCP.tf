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
  credentials = file("cred_file.json") //this file could be created via lin below
  //https://console.cloud.google.com/apis/credentials/serviceaccountkey
  project     = "name of your project"
  region      = "us-central1"
  zone      = "us-central1-a"
}

resource "google_compute_instance" "terra-nginx" {
  name         = "terra-nginx"
  machine_type = "e2-small" // 2vCPU, 2GB RAM
  #machine_type = "e2-medium" // 2vCPU, 4GB RAM
  #machine_type = "custom-6-20480" // 6vCPU, 20GB RAM / 6.5GB RAM per CPU, if needed more refer to next line
  #machine_type = "custom-2-15360-ext" // 2vCPU, 15GB RAM

  #tags = ["terra", "nginx"]
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

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install default-jre -y",
      "sudo apt install nginx -y",
    ]
    connection {
      type     = "ssh"
      user     = "root"
      private_key = file("/root/.ssh/id_rsa")
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }

  provisioner "file" {
    source      = "index.html"
    destination = "/var/www/html/index.html"
    connection {
      type     = "ssh"
      user     = "root"
      private_key = file("/root/.ssh/id_rsa")
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }
}

