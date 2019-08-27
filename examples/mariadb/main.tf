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

provider "google-beta" {
  version = "~> 2.0"
}

module "admin" {
  source          = "../../modules/admin"
  project_id      = var.project_id
  network_project = var.network_project
  network         = var.network
  service_account = var.service_account
  bucket_name     = var.bucket_name
  client_ip_range = var.client_ip_range
}

module "health_check" {
  source            = "../../modules/health_check"
  project_id        = var.project_id
  health_check_name = var.health_check_name
}

module "mariadb" {
  source             = "../../modules/mariadb"
  cluster_name       = var.cluster_name
  create_time        = "${var.create_time == "" ? timestamp() : var.create_time}"
  databases          = var.databases
  project_id         = var.project_id
  region             = var.region
  zone               = var.zone
  garb_zone          = var.garb_zone
  garb_instance_type = var.instance_type
  garb_region        = var.garb_region
  garb_subnetwork    = var.garb_subnetwork
  network_project    = var.network_project
  subnetwork         = var.subnetwork
  health_check_uri   = module.health_check.health_check_uri
  service_account    = var.service_account
  bucket_name        = module.admin.bucket_name
  vm_image           = var.vm_image
  instance_type      = var.instance_type
  disk_size_gb       = var.disk_size_gb
  disk_type          = var.disk_type
  client_ip_range    = var.client_ip_range
  pass               = var.pass
  statspass          = var.statspass
  replpass           = var.replpass
  instance_count     = var.instance_count
  template_version   = var.template_version
}