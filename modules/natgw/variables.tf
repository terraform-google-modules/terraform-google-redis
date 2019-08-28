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

variable "group_name" {
  description = "The name of the instance group manager."
  type        = string
}

variable "template_name" {
  description = "The name of the instance template."
  type        = string
}

variable "address_name" {
  description = "The name of the static IP address."
  type        = string
}

variable "network_project" {
  description = "The ID of the project containing the VPC network."
  type        = string
}

variable "service_account" {
  description = "The name of the service account to attach to VM instances."
  type        = string
}

variable "instance_type" {
  description = "The type of VM instance to use."
  type        = string
}

variable "client_ip_range" {
  description = "The IP range clients are allowed to connect from."
  type        = string
}

variable "disk_size_gb" {
  description = "Size of boot disk."
  type        = number
}

variable "disk_type" {
  description = "Type of boot disk."
  type        = string
}

variable "health_check_uri" {
  description = "URI of health check projects/*/global/healthChecks/*."
  type        = string
}

variable "vm_image" {
  description = "VM Image to use in instance templates."
  type        = string
}

variable "template_version" {
  description = "Version string used in instance template naming."
  type        = string
}

variable "region" {
  description = "Instance region."
  type        = string
}

variable "zone" {
  description = "Instance zone."
  type        = string
}

variable "subnetwork" {
  description = "Instance subnetwork."
  type        = string
}

