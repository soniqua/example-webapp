## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws |  |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 2.7 |

## Resources

| Name | Type |
|------|------|
| [aws_security_group.eks_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [kubernetes_config_map.cloudwatch](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_daemonset.cloudwatch](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/daemonset) | resource |
| [kubernetes_namespace.cloudwatch](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_role.cloudwatch](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role_binding.cloudwatch](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_service_account.cloudwatch](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_access_CIDR_range"></a> [api\_access\_CIDR\_range](#input\_api\_access\_CIDR\_range) | CIDR range(s) to be whitelisted for the K8S API endpoint | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_ca_cert"></a> [cluster\_ca\_cert](#output\_cluster\_ca\_cert) | CA Cert for K8S |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for EKS control plane. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | EKS cluster ID. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Kubernetes Cluster Name |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | Security group ids attached to the cluster control plane. |
| <a name="output_config_map_aws_auth"></a> [config\_map\_aws\_auth](#output\_config\_map\_aws\_auth) | A kubernetes configuration to authenticate to this EKS cluster. |
| <a name="output_kubectl_config"></a> [kubectl\_config](#output\_kubectl\_config) | kubectl config as generated by the module. |
| <a name="output_region"></a> [region](#output\_region) | AWS region |
