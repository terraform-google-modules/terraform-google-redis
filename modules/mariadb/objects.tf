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

data "template_file" "mariadb" {
  template = file("${path.module}/scripts/mariadb.sh.tpl")
  vars = {
    pass      = var.pass
    replpass  = var.replpass
    statspass = var.statspass
  }
}

resource "google_storage_bucket_object" "mariadb" {
  bucket  = var.bucket_name
  name    = "${var.cluster_name}/mariadb.sh"
  content = data.template_file.mariadb.rendered
}

resource "google_storage_bucket_object" "garb" {
  bucket = var.bucket_name
  name   = "${var.cluster_name}/garb.sh"
  source = "${path.module}/scripts/garb.sh"
}

resource "google_storage_bucket_object" "ca" {
  bucket  = var.bucket_name
  name    = "${var.cluster_name}/ca.crt"
  content = tls_self_signed_cert.ca.cert_pem
}

resource "google_storage_bucket_object" "garbcrt" {
  bucket  = var.bucket_name
  name    = "${var.cluster_name}/garb.crt"
  content = tls_locally_signed_cert.crt.*.cert_pem[var.instance_count]
}

resource "google_storage_bucket_object" "garbkey" {
  bucket  = var.bucket_name
  name    = "${var.cluster_name}/garb.pem"
  content = tls_private_key.key.*.private_key_pem[var.instance_count]
}

resource "google_storage_bucket_object" "crt" {
  count   = var.instance_count
  bucket  = var.bucket_name
  name    = "${var.cluster_name}/${count.index}.crt"
  content = tls_locally_signed_cert.crt.*.cert_pem[count.index]
}

resource "google_storage_bucket_object" "key" {
  count   = var.instance_count
  bucket  = var.bucket_name
  name    = "${var.cluster_name}/${count.index}.pem"
  content = tls_private_key.key.*.private_key_pem[count.index]
}
