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

variable "cluster_name" {
  description = "Name of redis cluster included in name of resources being created"
  type        = string
}
variable "project_id" {
  description = "The ID of the project where resources will be created"
  type        = string
}
variable "region" {
  description = "ID of GCP Region used by each node."
  type        = list(string)
}
variable "zone" {
  description = "ID of GCP Zone used by each node."
  type        = list(string)
}
variable "network_project" {
  description = "ID of project containing network where redis VM instances will be created"
  type        = string
}
variable "network" {
  description = "Name of network where redis VM instances will be created"
  type        = string
}
variable "subnetwork" {
  description = "Name of subnetwork where redis VM instances will be created"
  type        = string
}
variable "service_account" {
  description = "Name of service account for redis VM instances being created"
  type        = string
}
variable "bucket_name" {
  description = "Name of GCS bucket containing redis configuration files"
  type        = string
}
variable "health_check_uri" {
  description = "URI of health check for managed instance group being created (format=projects/*/global/healthChecks/*)"
  type        = string
}
variable "instance_type" {
  description = "Name of instance type for redis VM instances being created"
  type        = string
}
variable "disk_size_gb" {
  description = "Size of persistent disk attached to redis VM instances being created"
  type        = number
}
variable "pass" {
  description = "Redis password."
  type        = string
}
