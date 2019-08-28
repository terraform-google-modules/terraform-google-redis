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

terraform {
  required_version = "~> 0.12.0"
}

resource "google_compute_address" "main" {
  project      = var.project_id
  region       = var.region
  subnetwork   = var.subnetwork
  name         = var.address_name
  address_type = "INTERNAL"
}

data "template_file" "startup" {
  template = file("${path.module}/startup.sh.tpl")
  vars = {
    client_ip_range = var.client_ip_range
  }
}

resource "google_compute_instance_template" "main" {
  project              = var.project_id
  region               = var.region
  name                 = var.template_name
  machine_type         = var.instance_type
  description          = "NAT Gateway Instance Template"
  instance_description = "GSZUtil NAT Gateway"
  can_ip_forward       = false
  tags                 = ["gsznat", "internal"]
  labels = {
    template = "tf-gsznat"
  }
  metadata = {
    startup-script = data.template_file.startup.rendered
  }
  disk {
    source_image = var.vm_image
    disk_size_gb = var.disk_size_gb
    type         = var.disk_type
  }
  network_interface {
    subnetwork_project = var.project_id
    subnetwork         = var.subnetwork
    network_ip         = google_compute_address.main.address
  }
  service_account {
    email  = "${var.service_account}@${var.project_id}.iam.gserviceaccount.com"
    scopes = ["userinfo-email"]
  }
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "main" {
  provider           = "google-beta"
  project            = var.project_id
  name               = var.group_name
  base_instance_name = var.group_name
  zone               = var.zone
  target_size        = 1
  version {
    name              = var.template_version
    instance_template = google_compute_instance_template.main.self_link
  }
  update_policy {
    minimal_action        = "REPLACE"
    type                  = "OPPORTUNISTIC"
    max_unavailable_fixed = "1"
  }
  auto_healing_policies {
    health_check      = var.health_check_uri
    initial_delay_sec = 300
  }
}
