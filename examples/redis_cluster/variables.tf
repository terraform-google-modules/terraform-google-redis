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

variable "region" {
  description = "List of instance regions."
  type        = list(string)
}

variable "zone" {
  description = "List of instance zones."
  type        = list(string)
}

variable "service_account" {
  description = "The name of the service account."
  type        = string
}

variable "network_project" {
  description = "The project ID containing the network to create the cluster in."
  type        = string
}

variable "network" {
  description = "The name of the network to create the cluster in."
  type        = string
}

variable "subnetwork" {
  description = "The name of the subnetwork to create the cluster in."
  type        = string
}

variable "client_ip_range" {
  description = "The IP range clients will be allowed to connect from."
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster to create."
  type        = string
}

variable "health_check_name" {
  description = "The name of the health check to create."
  type        = string
}

variable "instance_type" {
  description = "The type of instance."
  type        = string
}

variable "disk_size_gb" {
  description = "The size of persistent disk on each instance."
  type        = number
}

variable "pass" {
  description = "Redis password."
  type        = string
}
