# terraform-google-natgw

The modules contained in this repository create a nat gateway with configurable client ip

## Usage

Basic usage of this module is as follows:

```hcl
module "example" {
  source = "../../../examples/natgw"

  project_id        = "myproject"
  region            = "us-east1"
  zone              = "us-east1-b"
  network_project   = "default"
  network           = "default"
  subnetwork        = "default"
  client_ip_range   = "10.0.0.0/8"
  template_name     = "nat-tpl"
  health_check_name = "nat-gw"
  fw_rule_name      = "nat-fw"
  group_name        = "nat-mig"
  address_name      = "nat-addr"
  service_account   = "nat-gw"
  instance_type     = "g1-small"
  vm_image          = "debian-cloud/debian-9"
  disk_type         = "pd-standard"
  disk_size_gb      = 32
  template_version  = "v1"
}
```

Functional example is included in the [examples](./examples/) directory.

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.12
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v2.0

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html
