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

variable "cluster_name" { type = string }
variable "project_id" { type = string }
variable "region" {
  description = "Region used by each node."
  type        = list(string)
}
variable "zone" {
  description = "Zone used by each node."
  type        = list(string)
}
variable "network_project" { type = string }
variable "network" { type = string }
variable "subnetwork" { type = string }
variable "service_account" { type = string }
variable "bucket_name" { type = string }
variable "health_check_uri" {
  description = "URI of health check projects/*/global/healthChecks/*."
  type        = string
}
variable "instance_type" { type = string }
variable "disk_size_gb" { type = number }
variable "pass" {
  description = "Redis password."
  type        = string
}
