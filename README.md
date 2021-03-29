# Example Web-App

This repository contains a simple Guestbook web-app, allowing visitors to record their name on entry. Jump to [Deployment Plan](#deployment-plan) for instructions to create infrastructure.

## Components

| Location | Description |
| --- | --- |
| [webapp](/webapp) | A pre-compiled Go binary for Linux or MacOS alongside static files |
| [terraform](/terraform) | Contains all required Terraform files to create infrastructure |

See the `TF-DOCS.md` file at each level for further Terraform detail.

## Prerequisites

Ensure the following are installed:

- `aws-cli`
- `terraform`
- `docker`
- `docker-compose`

## Design and Implementation

### Architecture

This repository will create the following components:

1. A new VPC with three public/private subnets respectively
1. A new Amazon EKS cluster, running version `1.19` (by default)
1. A new autoscaling group containing two EC2 EKS workers (`t3.small`)
1. A new ECR repository for the `example-webapp` docker container
1. A Kubernetes podspec, service for the `example-webapp`
1. A Kubernetes `daemonset` of the AWS Cloudwatch Agent (for Container Insights)

### Design Alternatives

The following Alternatives were considered for this repository:

| Alternative Deployment Architectures | Reasons why not used |
| --- | --- |
| On-machine deployment | Whilst this is the simplest deployment method (achieved by `docker-compose` or a `minikube` cluster) it is not readily scalable, secured or accessible outside of a local network. |
| Bare Metal deployment | This method requires a new host OS to be restarted every time a change is made to the application, and is not immutable (changes may be made to application code by hand and cause drift). Describable as code, but not as robust as using a managed service (the owners are responsible for operating system updates as well as the running application) |
| Serverless deployment | The application is not suited for a serverless deployment method as it requires a connection to a Redis database on `localhost`.

| Alternative Deployment Methods | Reasons why not used |
| --- | --- |
| AWS CLI | Error-prone, any scripting or encapsulation of the CLI may require updates when AWS APIs/CLI are updated. AWS only. |
| AWS CloudFormation | Not DRY (creating reusable loops or modules is challenging or requires a Lambda function to transform data), closed source and AWS only. Requires the use of `user-data` to procedurally define on-host configuration, which may fail if the Host OS changes. |
| A combination of AWS CloudFormation and configuration management (Ansible, Chef) | Requires additional infrastructure to support configuration management tools, procedurally generated configuration which may be prone to drift, changes require an awareness of already-present infrastructure |

| Alternative Logging/Monitoring/Alerting Methods | Reasons why not used |
| --- | --- |
| Prometheus/Grafana | Requires additional infrastructure and adds complexity. Not suited for a deployment of this size. Note that AWS now support an EKS exporter for [Prometheus](https://docs.amazonaws.cn/en_us/AmazonCloudWatch/latest/monitoring/ContainerInsights-Prometheus.html).|
| Kubernetes Metrics Server | Not suitable for alerting - primary functions are for Autoscaling |

## Deployment Plan

### Running the web-app locally via Docker-Compose

1. Clone this repository.
1. Run `docker-compose up -d` in the root directory (alongside the `docker-compose.yml` file).
1. The webapp will be available on `localhost:80`.
1. Run `docker-compose down` when finished.

### Deploying to AWS via Terraform
**Currently no remote state is used.**

Ensure [configuration is appropriately](#configuration) set in `main.tf` before continuing

1. Clone this repository.
1. Ensure your AWS credentials are valid and have the appropriate permissions to deploy requested infrastructure.
1. Execute the `deploy.sh` shell script. This performs the following actions:
  1. Execute `terraform init && terraform plan` in the `/terraform` directory.
  1. Execute `terraform apply` to start the deployment.
  1. Once created, review the output from the `terraform apply` run and access the web-app on the provided url:

```
Outputs:

load_balancer_hostname = "{{alb_id}}.{{region}}.elb.amazonaws.com"

```

6. Run `terraform destroy` when finished.

## Monitoring, Reporting and Alerting

### Liveness Probes

These are defined at the container level:

| Container | Type | Command/Path | Description |
| --- | --- | --- | --- |
| `example-webapp` | `http` | `/info` | This healthcheck ensures that the web-app has launched **and** is able to connect to `redis` |
| `redis` | `exec` | `redis-cli ping` | This healthcheck is executed within the `redis` container - a response of `PONG` indicates the `redis` service is running |

### Kubernetes Metrics
The Amazon Cloudwatch agent is deployed as a Kubernetes `daemonset` on the EKS cluster to report metrics. Alarms may be configured appropriately - the following are suggested metrics to alert on (per `namespace`, `pod` or `service`):

| Metric | Description |
| --- | --- |
| `cluster_failed_node_count` | A number above zero indicates nodes are failing to become healthy and not serving traffic.
|`service_number_of_running_pods` | If this is less than desired, there may be an issue with pods becoming healthy
|`pod_number_of_container_restarts` | If this is high pods may be failing healthchecks and being restarted by EKS
|`pod_cpu_utilization_over_pod_limit` | If this is high for an extended period of time it may indicate a reduced responsiveness for the application |
|`pod_memory_utilization_over_pod_limit` | If this is high for an extended period of time it may indicate a memory leak or excessive load |

Logs may be viewed at Cloudwatch under the `/aws/containerinsights` namespace.

### Other Metrics

| Metric | Description |
| --- | --- |
| % of `5XX` type responses via Load Balancer | `5XX` response codes indicate an application error which should be investigated |

## Configuration

Within the `main.tf` file:
- Set `local.allowed_account_ids` to a list of permitted AWS Account(s) to deploy to
- Set `local.allowed_access_cidrs` to a list of CIDR blocks that are permitted to access the Kubernetes API and the deployed applications (the CIDR of the NAT gateway is added automatically)
- If using STS:
  - set `local.role_arn` to the IAM role to assume (must already exist)
  - set `local.use_sts` to `true`
- Set `local.profile` to the AWS profile
- Set `local.region` to the AWS region to deploy to
- Set `local.use_credentials_file` to `true` if using credentials contained within `~/.aws/credentials` - otherwise Terraform will default to environment variables.

Set the `instance_type` and `instance_count` variables to specify the size and worker count of the AWS EKS cluster.

## Testing

Upon a new push to GitHub, the following occurs:

- `terraform fmt`
- `terraform validate`
- `checkov -d terraform --quiet -frameork terraform`

These actions help to ensure:

- Code is of a standard format (`terraform fmt`)
- Terraform configuration is valid (`terraform validate`)
- There are no readily identified security considerations to resolve (`checkov`)

Ideally this repository would be deployed upon a pull request to `main` - the GitHub action could be extended to include:

- `terraform plan` on creation of Pull Request
- `terraform apply` on merge of Pull Request to `main`

## Debugging

1. Run `aws eks update-kubeconfig --name {{cluster-name}}` to set credentials for the deployed cluster (note if using STS additional parameters may be required, such as `--role-arn`, `--profile`, `--region`)
1. Use the following commands to:
  - Describe the current nodes (`kubectl describe nodes`)
  - Get the currently running pods (`kubectl get pods -A`)
  - Get the `example-webapp` pods (`kubectl get pods -n example-webapp-namespace`)
  - Assess the state of the `example-webapp` pods (`kubectl describe pods example-webapp -n example-webapp-namespace`)

## Improvements

- Use an `ingress` controller instead of a `LoadBalancer` type for services to support `https`
- Migrate `redis` to ElasticCache/a separate shared pod
- Perform docker container build off-machine via CI/CD pipeline
- Automatic deployments from `main`
- Enforce stricter security groups within VPC for EKS workers

## Resources/references

### Kubernetes Documentation
- [kubernetes pod spec](https://kubernetes.io/docs/concepts/workloads/pods/)
- [kubernetes service spec](https://kubernetes.io/docs/concepts/services-networking/service/)
- [kubernetes monitoring](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/)

### Terraform Documentation
- [kubernetes provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [kubernetes example](https://github.com/hashicorp/terraform-provider-kubernetes/blob/main/_examples/eks/kubernetes-config/main.tf)

### GitHub Actions
- [checkov-action](https://github.com/bridgecrewio/checkov-action) - for Terraform security and best practices
- [terraform](https://github.com/marketplace/actions/hashicorp-setup-terraform) - for Terraform setup

### EKS Requirements/Security Considerations
- [EKS Cloudwatch Metrics](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-metrics-EKS.html)
- [EKS Security](https://docs.aws.amazon.com/eks/latest/userguide/security.html)

### Additional Software
- [k2tf](https://github.com/sl1pm4t/k2tf) - convert Kubernetes YAML files to Terraform
- [minikube](https://minikube.sigs.k8s.io/docs/start/) - for local K8S testing
