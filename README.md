# Terraform Redis Module for GCP

This repository contains Terraform Modules used to launch a Redis Sentinel HA Cluster on Google Cloud.

Redis Sentinel manages a High-Availability Redis cluster with Google Cloud Managed Instance Group providing auto-healing and monitoring built in. Redis is very useful for caching application data in memory and can also be used as a message broker.

The core template creates a 3-node cluster with Redis Sentinel and Redis Server running on each node. Three Managed Instance Groups are used in order to enable creation of a multi-zonal cluster.

## Description

The template writes an installation script to a Cloud Storage Bucket. The installation script installs Redis Server, Redis Sentinel, and StackDriver Agent. Instance Templates are configured such that any Instance created from the template will download and runs the installation script at startup. Managed Instance Groups use an Instance Template to create cluster member instances and replace each instance that becomes unhealthy.


## Failover Characteristics

Systemd will restart Redis if the process is stopped on an individual instance.

Redis Sentinel will promote a new master node to accept writes if the current master becomes unresponsive.

Managed Instance Group runs a TCP health check and will replace any instance that is unresponsive multiple times in a row.

## Monitoring with StackDriver

StackDriver Agent Redis Plugin exports the following metrics:
- Blocked clients
- Command count
- Connected clients
- Connection count
- Expired keys
- Lua memory usage
- Memory usage
- PubSub channels
- PubSub patterns
- Slave connections
- Unsaved changes
- Uptime

It also exports CPU, Disk and Network metrics.

The metrics can be viewed using [StackDriver Metrics Explorer](https://app.google.stackdriver.com/metrics-explorer). Select "GCE VM Instance" as the Resource Type.

Redis metrics are given URIs begin with "agent.googleapis.com/redis/" and can be filtered by cluster using the "cluster_name" metadata label added by this template.

StackDriver can be used to create dashboards or define alerts, and has built-in integration with [PagerDuty](https://app.google.stackdriver.com/settings/accounts/notifications/pagerduty), [Slack](https://app.google.stackdriver.com/settings/accounts/notifications/slack) and [SMS](https://app.google.stackdriver.com/settings/accounts/notifications/sms).


## File structure
The project has the following folders and files:

- README.md: this file
- [modules/admin](modules/admin): Creates Service Account, Cloud Storage Bucket, Firewall Rules and grants permissions to the Service Account
- [modules/healthcheck](modules/healthcheck): Creates TCP Healthcheck
- [modules/redis](modules/redis): Creates Instance templates, Managed Instance Groups, Static Private IP, Startup Script
- [examples/redis_cluster](examples/redis_cluster): Example Usage of Redis Cluster modules - modify this to deploy Redis Cluster in your own project
- [test/fixtures/redis_cluster](test/fixtures/redis_cluster): Test Usage of Redis Cluster modules


## Usage

Basic usage of this module is as follows:

```hcl
module "redis" {
  source  = "terraform-google-modules/redis/google"
  version = "~> 0.1"

  project_id  = "<PROJECT ID>"
  bucket_name = "gcs-test-bucket"
}
```

Functional examples are included in the
[examples](./examples/) directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| bucket\_name | The name of the bucket to create | string | n/a | yes |
| project\_id | The project ID to deploy to | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_name |  |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.12
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v2.0
- [Terraform Beta Provider for GCP][terraform-provider-google-beta] plugin v2.0

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

- Storage Admin: `roles/storage.admin`

The [Project Factory module][project-factory-module] and the
[IAM module][iam-module] may be used in combination to provision a
service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Google Cloud Storage JSON API: `storage-api.googleapis.com`

The [Project Factory module][project-factory-module] can be used to
provision a project with the necessary APIs enabled.

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform-provider-google-beta]: https://github.com/terraform-providers/terraform-provider-google-beta/blob/master/google-beta/
[terraform]: https://www.terraform.io/downloads.html
