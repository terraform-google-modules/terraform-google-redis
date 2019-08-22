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

variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "bucket_name" {
  description = "The name of the bucket to create."
  type        = string
}

variable "cluster_name" {
  type = string
}

variable "create_time" {
  description = "Creation time formatted as 2018-01-02T23:12:01Z used to allow cluster bootstrap."
  type        = string
  default     = ""
}

variable "instance_count" {
  type    = number
  default = 4
}

variable "region" {
  type = list(string)
}

variable "zone" {
  type = list(string)
}

variable "subnetwork" {
  type = list(string)
}

variable "vm_image" { default = "debian-cloud/debian-9" }
variable "garb_instance_type" { default = "n1-standard-1" }
variable "garb_zone" { type = string }
variable "garb_region" { type = string }
variable "garb_subnetwork" { default = "default" }
variable "network_project" { type = string }
variable "network" { default = "default" }
variable "service_account" { type = string }
variable "instance_type" { type = string }
variable "client_ip_range" { default = "10.0.0.0/8" }
variable "pass" { type = string }
variable "replpass" { type = string }
variable "statspass" { type = string }
variable "disk_size_gb" { type = number }
variable "disk_type" { default = "pd-standard" }
variable "health_check_name" { type = string }

variable "databases" {
  description = "Space separated list of databases to be created."
  type        = string
}

variable "template_version" {
  description = "A version identifier included in instance template names."
  type        = string
  default     = "v1"
}
