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

provider "google" {
  version = "~> 2.0"
}

module "admin" {
  source = "../../modules/admin"

  project_id      = var.project_id
  bucket_name     = var.bucket_name
  service_account = var.service_account
  network         = var.network
  client_ip_range = var.client_ip_range
}

module "health_check" {
  source = "../../modules/health_check"

  project_id        = var.project_id
  health_check_name = var.health_check_name
}

module "redis" {
  source = "../../modules/redis"

  project_id       = var.project_id
  bucket_name      = module.admin.bucket_name
  cluster_name     = var.cluster_name
  region           = var.region
  zone             = var.zone
  network_project  = var.network_project
  network          = var.network
  subnetwork       = var.subnetwork
  service_account  = var.service_account
  health_check_uri = module.health_check.health_check_uri
  instance_type    = var.instance_type
  disk_size_gb     = var.disk_size_gb
  pass             = var.pass
}
