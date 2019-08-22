/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

provider "random" {
  version = "~> 2.0"
}

resource "random_id" "id" {
  byte_length = 4
}

locals {
  id     = "cft-mariadb-${random_id.id.hex}"
  region = "us-east1"
  zone   = "us-east1-b"
  subnet = google_compute_subnetwork.test.name
}

resource "google_compute_network" "test" {
  project                 = var.project_id
  name                    = local.id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "test" {
  project                  = var.project_id
  region                   = local.region
  network                  = google_compute_network.test.self_link
  name                     = local.id
  ip_cidr_range            = "10.0.0.0/24"
  private_ip_google_access = true
}

# NAT instance for test environment
resource "google_compute_instance" "nat" {
  project      = var.project_id
  name         = "nat"
  machine_type = "f1-micro"
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork_project = var.project_id
    subnetwork         = local.subnet
    access_config {}
  }

  metadata_startup_script = <<EOF
#!/bin/bash
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/20-natgw.conf
DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent
EOF
}

# NAT Route
resource "google_compute_route" "nat" {
  project           = var.project_id
  name              = "nat-route"
  dest_range        = "0.0.0.0/0"
  network           = google_compute_network.test.name
  next_hop_instance = google_compute_instance.nat.self_link
  tags              = ["internal"]
  priority          = 100
}

module "example" {
  source = "../../../examples/mariadb"

  project_id   = var.project_id
  bucket_name  = local.id
  cluster_name = "cluster"
  create_time  = timestamp()
  databases    = "db"
  region = [
    local.region,
    local.region,
    local.region,
    local.region,
  ]
  zone = [
    local.zone,
    local.zone,
    local.zone,
    local.zone,
  ]
  subnetwork = [
    local.subnet,
    local.subnet,
    local.subnet,
    local.subnet,
  ]

  /* It's necessary to pass a reference here
   * otherwise terraform will not wait for the network to become ready
   * and CI will fail with "resource is not ready"
   */
  network            = google_compute_network.test.name
  network_project    = var.project_id
  garb_region        = local.region
  garb_zone          = local.zone
  garb_subnetwork    = google_compute_subnetwork.test.name
  garb_instance_type = "f1-micro"
  health_check_name  = local.id
  service_account    = local.id
  instance_type      = "n1-standard-2"
  disk_size_gb       = 32
  disk_type          = "pd-standard"
  client_ip_range    = "0.0.0.0/0"
  pass               = local.id
  statspass          = local.id
  replpass           = local.id
  instance_count     = 4
  template_version   = "v1"
}
