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
  description = "The name of the cluster, used in resource naming."
  type        = string
}

variable "create_time" {
  description = "Creation time formatted as 2018-01-02T23:12:01Z used to allow cluster bootstrap."
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

variable "pass" {
  description = "Password for mariadb root user."
  type        = string
}

variable "replpass" {
  description = "Password for mariadb repl user."
  type        = string
}

variable "statspass" {
  description = "Password for mariadb stats user."
  type        = string
}

variable "instance_count" {
  description = "Number of instances to create."
  type        = number
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

variable "databases" {
  description = "Space separated list of database names to be created."
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

variable "garb_instance_type" {
  description = "Instance type to be used for garb instance."
  type        = string
}

variable "garb_zone" {
  description = "Zone to be used for garb instance."
  type        = string
}

variable "garb_region" {
  description = "Region to be used for garb instance."
  type        = string
}

variable "garb_subnetwork" {
  description = "Subnetwork to be used for garb instance."
  type        = string
}


# Map Variables with one record per instance
variable "region" {
  description = "List of instance regions."
  type        = list(string)
}

variable "zone" {
  description = "List of instance zones."
  type        = list(string)
}

variable "subnetwork" {
  description = "List of instance subnetwork names."
  type        = list(string)
}

