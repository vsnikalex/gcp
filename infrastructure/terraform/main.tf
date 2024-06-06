terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.70.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)

  project = var.project
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  credentials = file(var.credentials_file)

  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "default" {
  provider = google-beta
  name                    = "website-net"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "proxy" {
  provider = google-beta
  name          = "website-net-proxy"
  ip_cidr_range = "10.129.0.0/26"
  purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
  role          = "ACTIVE"
  region        = var.region
  network       = google_compute_network.default.id
}

resource "google_compute_subnetwork" "default" {
  provider = google-beta
  name          = "website-net-default"
  ip_cidr_range = "10.1.2.0/24"
  region        = var.region
  network       = google_compute_network.default.id
}

resource "google_compute_firewall" "fw1" {
  provider = google-beta
  name = "website-fw-1"
  network = google_compute_network.default.id
  source_ranges = ["10.1.2.0/24"]
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
  direction = "INGRESS"
}

resource "google_compute_firewall" "fw2" {
  provider = google-beta
  depends_on = [google_compute_firewall.fw1]
  name = "website-fw-2"
  network = google_compute_network.default.id
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  target_tags = ["allow-ssh"]
  direction = "INGRESS"
}

resource "google_compute_firewall" "fw3" {
  provider = google-beta
  depends_on = [google_compute_firewall.fw2]
  name = "website-fw-3"
  network = google_compute_network.default.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }
  target_tags = ["load-balanced-backend"]
  direction = "INGRESS"
}

resource "google_compute_firewall" "fw4" {
  provider = google-beta
  depends_on = [google_compute_firewall.fw3]
  name = "website-fw-4"
  network = google_compute_network.default.id
  source_ranges = ["10.129.0.0/26"]
  target_tags = ["load-balanced-backend"]
  allow {
    protocol = "tcp"
    ports = ["80"]
  }
  allow {
    protocol = "tcp"
    ports = ["443"]
  }
  allow {
    protocol = "tcp"
    ports = ["8000"]
  }
  direction = "INGRESS"
}

resource "google_compute_region_health_check" "default" {
  provider = google-beta
  depends_on = [google_compute_firewall.fw4]
  region = var.region
  name   = "website-hc"
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

data "google_compute_image" "debian_image" {
  provider = google-beta
  family   = "debian-9"
  project  = "debian-cloud"
}

resource "google_compute_instance_template" "instance_template" {
  provider     = google-beta
  name         = "template-website-backend"
  machine_type = "e2-medium"

  network_interface {
    network = google_compute_network.default.id
    subnetwork = google_compute_subnetwork.default.id
  }

  labels = {
    environment = "application_webserver"
  }

  disk {
    source_image = data.google_compute_image.debian_image.self_link
    auto_delete  = true
    boot         = true
  }

  metadata = {
    ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }

  tags = ["allow-ssh", "load-balanced-backend"]
}

resource "google_compute_region_instance_group_manager" "rigm" {
  provider = google-beta
  region   = var.region
  name     = "website-rigm"
  version {
    instance_template = google_compute_instance_template.instance_template.id
    name              = "primary"
  }
  base_instance_name = "internal-glb"
  target_size        = 3
}

resource "google_compute_region_backend_service" "default" {
  provider = google-beta

  load_balancing_scheme = "INTERNAL_MANAGED"

  backend {
    group = google_compute_region_instance_group_manager.rigm.instance_group
    balancing_mode = "UTILIZATION"
    capacity_scaler = 1.0
  }

  region      = var.region
  name        = "website-backend"
  protocol    = "HTTP"
  timeout_sec = 10

  health_checks = [google_compute_region_health_check.default.id]
}

resource "google_compute_region_url_map" "default" {
  provider = google-beta

  region          = var.region
  name            = "website-map"
  default_service = google_compute_region_backend_service.default.id
}

resource "google_compute_region_target_http_proxy" "default" {
  provider = google-beta

  region  = var.region
  name    = "website-proxy"
  url_map = google_compute_region_url_map.default.id
}

resource "google_compute_forwarding_rule" "default" {
  provider = google-beta
  depends_on = [google_compute_subnetwork.proxy]
  name   = "website-forwarding-rule"
  region = var.region

  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.default.id
  network               = google_compute_network.default.id
  subnetwork            = google_compute_subnetwork.default.id
  network_tier          = "PREMIUM"
}

resource "google_compute_router" "router" {
  name    = "website-router"
  region  = google_compute_subnetwork.default.region
  network = google_compute_network.default.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "website-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_instance" "ansible_runner" {
  name         = "ansible-runner"
  machine_type = "f1-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  metadata = {
    startup-script = <<SCRIPT
sudo useradd -m ansible
sudo mkdir /home/ansible/.ssh

sudo echo '${file("~/.ssh/gcp_rsa")}' >> /home/ansible/.ssh/id_rsa
sudo echo '${file("~/.ssh/gcp_account.json")}' >> /home/ansible/.ssh/gcp_account.json
sudo -u ansible bash -c "chmod 400 ~/.ssh/id_rsa; chmod 400 ~/.ssh/gcp_account.json"

sudo curl https://bootstrap.pypa.io/pip/3.5/get-pip.py -o /home/ansible/get-pip.py
sudo python3 /home/ansible/get-pip.py
sudo python3 -m pip install ansible
sudo python3 -m pip install requests google-auth

sudo apt-get install git -y
SCRIPT
  }

  network_interface {
    subnetwork = google_compute_subnetwork.default.name
  }

  tags = ["allow-ssh"]
}
