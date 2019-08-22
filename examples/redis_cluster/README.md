# Simple Example

This example illustrates how to use the `redis` module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| bucket\_name | The name of the bucket to create. | string | n/a | yes |
| client\_ip\_range | The IP range clients will be allowed to connect from. | string | n/a | yes |
| cluster\_name | The name of the cluster to create. | string | n/a | yes |
| disk\_size\_gb | The size of persistent disk on each instance. | number | n/a | yes |
| health\_check\_name | The name of the health check to create. | string | n/a | yes |
| instance\_type | The type of instance. | string | n/a | yes |
| network | The name of the network to create the cluster in. | string | n/a | yes |
| network\_project | The project ID containing the network to create the cluster in. | string | n/a | yes |
| pass | Redis password. | string | n/a | yes |
| project\_id | The ID of the project in which to provision resources. | string | n/a | yes |
| region | List of instance regions. | list(string) | n/a | yes |
| service\_account | The name of the service account. | string | n/a | yes |
| subnetwork | The name of the subnetwork to create the cluster in. | string | n/a | yes |
| zone | List of instance zones. | list(string) | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_name | The name of the bucket. |
| health\_check\_uri | The URI of the health check. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

To provision this example, run the following from within this directory:
- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure
