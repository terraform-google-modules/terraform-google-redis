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

resource "google_compute_health_check" "mariadb" {
  project             = var.project_id
  name                = var.health_check_name
  timeout_sec         = 30
  check_interval_sec  = 60
  healthy_threshold   = 1
  unhealthy_threshold = 4

  tcp_health_check {
    port = "3306"
  }
}
