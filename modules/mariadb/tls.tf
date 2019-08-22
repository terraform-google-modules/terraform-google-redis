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

resource "tls_private_key" "ca" {
  algorithm = "RSA"
}

resource "tls_private_key" "key" {
  count     = var.instance_count + 1
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm         = "RSA"
  private_key_pem       = tls_private_key.ca.private_key_pem
  validity_period_hours = 87600
  is_ca_certificate     = true
  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]
  subject {
    country             = "US"
    province            = "CA"
    locality            = "Mountain View"
    organization        = "Google"
    organizational_unit = "Google Cloud Foundation Toolkit"
    common_name         = "terraform"
  }
}

resource "tls_cert_request" "csr" {
  count           = var.instance_count + 1
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.key.*.private_key_pem[count.index]
  subject {
    country             = "US"
    province            = "CA"
    locality            = "Mountain View"
    organization        = "Google"
    organizational_unit = "Google Cloud Foundation Toolkit"
    common_name         = count.index
  }
}

resource "tls_locally_signed_cert" "crt" {
  count                 = var.instance_count + 1
  cert_request_pem      = tls_cert_request.csr.*.cert_request_pem[count.index]
  ca_key_algorithm      = "RSA"
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = 43800
  allowed_uses          = ["server_auth", "client_auth"]
}
