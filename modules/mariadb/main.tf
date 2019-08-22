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

resource "google_compute_address" "mariadb" {
  count        = var.instance_count
  project      = var.project_id
  name         = format("mariadb-${var.cluster_name}-%03d", count.index)
  subnetwork   = var.subnetwork[count.index]
  address_type = "INTERNAL"
  region       = var.region[count.index]
  timeouts {
    create = "10m"
  }
}

resource "google_compute_instance_template" "mariadb" {
  count                = var.instance_count
  project              = var.project_id
  region               = var.region[count.index]
  name                 = "mariadb-${var.cluster_name}-${count.index}-${var.template_version}"
  description          = "MariaDB Instance Template"
  instance_description = "MariaDB Server"
  machine_type         = var.instance_type
  can_ip_forward       = false
  tags                 = ["mariadb", "internal"]
  labels = {
    template     = "tf-mariadb"
    cluster_name = var.cluster_name
  }
  metadata = {
    startup-script  = <<EOF
#!/bin/bash
gsutil cp gs://${var.bucket_name}/${var.cluster_name}/mariadb.sh /tmp/startup.sh
nohup /bin/bash /tmp/startup.sh >/var/log/startup-script.log 2>&1 &
EOF
    node-id         = count.index
    cluster-name    = var.cluster_name
    cluster-members = "${google_compute_address.mariadb.*.address[0]},${google_compute_address.mariadb.*.address[1]},${google_compute_address.mariadb.*.address[2]},${google_compute_address.mariadb.*.address[3]}"
    config-bucket   = var.bucket_name
    databases       = var.databases
    create-time     = var.create_time
  }
  disk {
    source_image = var.vm_image
    disk_size_gb = var.disk_size_gb
    type         = var.disk_type
  }
  network_interface {
    subnetwork         = var.subnetwork[count.index]
    subnetwork_project = var.project_id
    network_ip         = google_compute_address.mariadb.*.address[count.index]
  }
  service_account {
    email  = "${var.service_account}@${var.project_id}.iam.gserviceaccount.com"
    scopes = ["userinfo-email", "compute-ro", "storage-rw", "monitoring-write"]
  }
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "mariadb" {
  count              = var.instance_count
  provider           = "google-beta"
  project            = var.project_id
  name               = format("mariadb-${var.cluster_name}-%03d", count.index)
  base_instance_name = format("mariadb-${var.cluster_name}-%03d", count.index)
  zone               = var.zone[count.index]
  target_size        = 1
  version {
    name              = "v1"
    instance_template = google_compute_instance_template.mariadb.*.self_link[count.index]
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

resource "google_compute_instance_template" "garb" {
  project              = var.project_id
  region               = var.garb_region
  name                 = "mariadb-${var.cluster_name}-garb-${var.template_version}"
  description          = "MariaDB Galera Arbitrator Instance Template"
  instance_description = "MariaDB Galera Arbitrator"
  machine_type         = var.garb_instance_type
  can_ip_forward       = false
  tags                 = ["mariadb", "internal"]
  labels = {
    template     = "tf-mariadb"
    cluster_name = var.cluster_name
  }
  metadata = {
    startup-script  = <<EOF
#!/bin/bash
gsutil cp gs://${var.bucket_name}/${var.cluster_name}/garb.sh /tmp/startup.sh
nohup /bin/bash /tmp/startup.sh >/var/log/startup-script.log 2>&1 &
EOF
    cluster-name    = var.cluster_name
    node-id         = "garb"
    config-bucket   = var.bucket_name
    cluster-members = "${google_compute_address.mariadb.*.address[0]},${google_compute_address.mariadb.*.address[1]},${google_compute_address.mariadb.*.address[2]},${google_compute_address.mariadb.*.address[3]}"
  }
  disk {
    source_image = var.vm_image
    disk_size_gb = "32"
    type         = "pd-standard"
  }
  network_interface {
    subnetwork_project = var.project_id
    subnetwork         = var.garb_subnetwork
  }
  service_account {
    email  = "${var.service_account}@${var.project_id}.iam.gserviceaccount.com"
    scopes = ["userinfo-email", "compute-ro", "storage-rw"]
  }
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "garb" {
  provider           = "google-beta"
  project            = var.project_id
  name               = "mariadb-${var.cluster_name}-garb"
  base_instance_name = "mariadb-${var.cluster_name}-garb"
  zone               = var.garb_zone
  target_size        = 1
  version {
    name              = "v1"
    instance_template = google_compute_instance_template.garb.self_link
  }
  update_policy {
    minimal_action        = "REPLACE"
    type                  = "OPPORTUNISTIC"
    max_unavailable_fixed = "1"
  }
}
