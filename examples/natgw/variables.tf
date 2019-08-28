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

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "template_version" {
  description = "A version identifier included in instance template names."
  type        = string
}

variable "vm_image" { type = string }
variable "network_project" { type = string }
variable "network" { type = string }
variable "service_account" { type = string }
variable "instance_type" { type = string }
variable "client_ip_range" { type = string }
variable "disk_size_gb" { type = number }
variable "health_check_name" { type = string }
variable "disk_type" { type = string }
variable "fw_rule_name" { type = string }
variable "group_name" { type = string }
variable "address_name" { type = string }
variable "template_name" { type = string }
