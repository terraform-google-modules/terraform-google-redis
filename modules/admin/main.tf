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

resource "google_service_account" "default" {
  project      = var.project_id
  account_id   = var.service_account
  display_name = var.service_account
}

resource "google_compute_firewall" "default" {
  project                 = var.network_project
  network                 = var.network
  name                    = var.fw_rule_name
  target_service_accounts = [google_service_account.default.email]
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  source_ranges = [var.client_ip_range, "35.191.0.0/16", "130.211.0.0/22"]
}
