## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecr_repository.repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [null_resource.push_image](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | The name of the container to build | `any` | n/a | yes |
| <a name="input_build_folder"></a> [build\_folder](#input\_build\_folder) | The folder containing a Dockerfile for building | `any` | n/a | yes |
| <a name="input_profile"></a> [profile](#input\_profile) | The AWS profile to use for ECR Login commands | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region of the ECR repository to push to | `any` | n/a | yes |
| <a name="input_tag"></a> [tag](#input\_tag) | The version of the container to be built | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_image_name"></a> [image\_name](#output\_image\_name) | The image name (including tag) |
