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

resource "google_service_account" "redis" {
  project      = var.project_id
  account_id   = var.service_account
  display_name = "Redis Service Account"
}

resource "google_compute_firewall" "healthcheck" {
  project = var.project_id
  name    = "redis"
  network = var.network
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "tcp"
    ports    = ["6379"]
  }
  source_ranges           = ["35.191.0.0/16", "130.211.0.0/22"]
  target_service_accounts = [google_service_account.redis.email]
}

resource "google_compute_firewall" "redis" {
  project = var.project_id
  name    = "redis-cluster"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["6379", "26379"]
  }
  source_service_accounts = [google_service_account.redis.email]
  target_service_accounts = [google_service_account.redis.email]
}

resource "google_compute_firewall" "client" {
  project = var.project_id
  name    = "redis-client"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["6379"]
  }
  source_ranges           = [var.client_ip_range]
  target_service_accounts = [google_service_account.redis.email]
}

resource "google_project_iam_member" "redis_logs" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.redis.email}"
}

resource "google_project_iam_member" "redis_metrics" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.redis.email}"
}

resource "google_storage_bucket" "config" {
  project       = var.project_id
  name          = var.bucket_name
  storage_class = "MULTI_REGIONAL"
  depends_on    = [null_resource.api]
}

resource "google_storage_bucket_iam_binding" "config" {
  bucket  = google_storage_bucket.config.name
  role    = "roles/storage.objectViewer"
  members = ["serviceAccount:${google_service_account.redis.email}"]
}

# Needed for CI to wait for Cloud Storage API to become ready
resource "null_resource" "api" {
  provisioner "local-exec" {
    command = <<EOF
for i in {1..6}; do
  if gcloud services list --project="${var.project_id}" | grep -q "storage-api.googleapis.com"; then
    exit 0
  fi
  echo "Waiting for storage-api.googleapis.com to be enabled"
  sleep 10
done

echo "storage-api.googleapis.com was not enabled after 60s"
exit 1
EOF
  }
}
