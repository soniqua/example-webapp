# Example Web-App

This repository contains a simple Guestbook web-app, allowing visitors to record their name on entry.

## Components

| Location | Description |
| --- | --- |
| [dist](/dist) | A pre-compiled Go binary for Linux or MacOS |
| [public](/public) | Static files rendered as a Javascript front-end |

This branch will represent the default state of the assignment, and will not launch correctly.


## Design and Implementation


## Alternatives


## Deployment Plan

### Running the web-app locally

1. Clone this repository
1. Ensure a redis cluster is available on localhost
1. Run `./dist/example-webapp-{linux|osx}` depending on your operating system
1. Open a browser, and point to localhost:3000

### Deploying to AWS


## Monitoring, Reporting and Alerting


## Configuration


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

## Resources/references

### Kubernetes Documentation


### Terraform Documentation


### GitHub Actions
- [checkov-action](https://github.com/bridgecrewio/checkov-action)
- [kubernetes pod spec](https://kubernetes.io/docs/concepts/workloads/pods/)
- [kubernetes service spec](https://kubernetes.io/docs/concepts/services-networking/service/)
- []

### EKS Requirements/Security Considerations
