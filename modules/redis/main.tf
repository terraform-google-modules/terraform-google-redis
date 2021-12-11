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
  runid = random_id.id.hex
}

resource "google_compute_address" "redis" {
  project      = var.project_id
  region       = var.region[0]
  subnetwork   = var.subnetwork
  name         = "redis-${var.cluster_name}-${local.runid}-0"
  address_type = "INTERNAL"
}

data "template_file" "config" {
  template = file("${path.module}/redis.sh.tpl")
  vars = {
    master = google_compute_address.redis.address
    pass   = var.pass
  }
}

resource "google_storage_bucket_object" "config" {
  bucket  = var.bucket_name
  name    = "${var.cluster_name}/redis.sh"
  content = data.template_file.config.rendered
}

resource "google_compute_instance_template" "redis" {
  count                = 3
  project              = var.project_id
  region               = var.region[count.index]
  name                 = "redis-${var.cluster_name}-${local.runid}-${count.index}"
  description          = "redis instance template"
  instance_description = "Redis Server"
  machine_type         = var.instance_type
  can_ip_forward       = false
  tags                 = ["internal", "redis"]
  labels = {
    template     = "terraform-google-redis"
    cluster_name = var.cluster_name
    node_id      = count.index
  }
  metadata = {
    startup-script = <<EOF
#!/bin/bash
gsutil cp gs://${var.bucket_name}/${google_storage_bucket_object.config.name} /tmp/startup.sh
chmod +x /tmp/startup.sh
nohup /bin/bash /tmp/startup.sh >/var/log/startup.log 2>&1 &
EOF
  }
  disk {
    source_image = "debian-cloud/debian-9"
    disk_size_gb = var.disk_size_gb
    type         = "pd-standard"
  }
  network_interface {
    subnetwork_project = var.project_id
    subnetwork         = var.subnetwork
    network_ip         = count.index == 0 ? google_compute_address.redis.address : null
  }
  service_account {
    email  = "${var.service_account}@${var.project_id}.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "redis" {
  count              = 3
  provider           = "google-beta"
  project            = var.project_id
  name               = "redis-${var.cluster_name}-${count.index}"
  base_instance_name = "redis-${var.cluster_name}-${count.index}"
  zone               = var.zone[count.index]
  target_size        = 1
  version {
    name              = "v1"
    instance_template = google_compute_instance_template.redis.*.self_link[count.index]
  }
  update_policy {
    minimal_action        = "REPLACE"
    type                  = "PROACTIVE"
    max_unavailable_fixed = "1"
  }
  auto_healing_policies {
    health_check      = var.health_check_uri
    initial_delay_sec = 300
  }
}
