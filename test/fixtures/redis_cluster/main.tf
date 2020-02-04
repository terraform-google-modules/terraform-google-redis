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
  id     = "cft-redis-${random_id.id.hex}"
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

# Needed for CI to wait for Cloud Storage API to become ready
resource "null_resource" "api" {
  provisioner "local-exec" {
    command = <<EOF
for i in {1..6}; do
  if gcloud services list --project="${var.project_id}" | grep -q "storage-api.googleapis.com"; then
    exit 0
  fi
  echo "Waiting for storage-api.googleapis.com to be enabled"
  sleep 10
done

echo "storage-api.googleapis.com was not enabled after 60s"
exit 1
EOF
  }
}

module "redis" {
  source = "../../../examples/redis_cluster"

  project_id      = var.project_id
  network_project = var.project_id
  network         = google_compute_network.test.name
  subnetwork      = google_compute_subnetwork.test.name
  bucket_name     = local.id
  cluster_name    = local.id
  region = [
    local.region,
    local.region,
    local.region,
  ]
  zone = [
    local.zone,
    local.zone,
    local.zone,
  ]
  service_account   = "redis-server"
  health_check_name = "redis"
  pass              = "changeit"
  instance_type     = "n1-highmem-2"
  client_ip_range   = "0.0.0.0/0"
  disk_size_gb      = 32
}
