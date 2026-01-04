## Project Overview

This project was built to replace a manual static website deployment process where developers uploaded files directly to production servers.

While this approach works early on, it quickly becomes error-prone. Files can be missed, deployments become inconsistent, and rolling back a bad release takes time.

The goal of this project was to introduce a simple, low-cost CI/CD pipeline using AWS and GitHub Actions that automates deployments without adding unnecessary complexity. All infrastructure is provisioned using Terraform, and frontend updates are deployed automatically whenever code is pushed to GitHub.

A blue/green deployment strategy is used to allow safe releases and fast rollback with minimal downtime.

## Architecture Diagram

The architecture diagram for this project can be found here:

[View architecture diagram](architecture/diagram.drawio.png)

### High-Level Flow

Developer
  |
  | git push
  v
GitHub Repository
  |
  | GitHub Actions
  v
Amazon S3
  ├── /blue (inactive or previous version)
  └── /green (active version)
  |
  v
Amazon CloudFront (Origin Access Control)
  |
  v
End Users

## Design Decisions

* Terraform is used to provision all AWS resources to avoid manual configuration and ensure consistency.
* A single S3 bucket with blue and green prefixes is used instead of multiple buckets to keep costs and infrastructure complexity low.
* CloudFront Origin Access Control (OAC) is used instead of OAI to follow current AWS best practices.
* Traffic switching is handled by updating the CloudFront origin path rather than invalidating the cache.

## Technologies Used

* Terraform
* GitHub Actions
* AWS IAM
* Amazon S3
* Amazon CloudFront

## Repository Structure

```
.
├── README.md
├── architecture
│   └── diagram.drawio.png
├── frontend
│   ├── index.html
│   ├── script.js
│   └── styles.css
└── infrastructure
    ├── environments
    │   └── dev
    │       ├── backend.tf
    │       ├── main.tf
    │       ├── provider.tf
    │       └── variables.tf
    └── modules
        └── s3-static-site
            ├── cloudfront.tf
            ├── outputs.tf
            ├── s3_bucket.tf
            └── variables.tf
```

## Setup Instructions

### Prerequisites

* AWS account
* GitHub account
* Terraform v1.x installed
* AWS CLI configured locally

### Configure GitHub Secrets

Configure the following GitHub repository secrets:

* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY
* EMAIL_USERNAME
* EMAIL_PASSWORD

These credentials are used by the GitHub Actions workflow to authenticate with AWS and perform deployments.

### Infrastructure Configuration

All AWS resources are created using Terraform. No manual AWS Console setup is required.

The main infrastructure entry point for this environment is defined in:

```
infrastructure/environments/dev/main.tf
```

The frontend infrastructure is provisioned using a reusable Terraform module.

### Configuration Details

* `frontend_bucket_name`
  Specifies the S3 bucket used to store static frontend assets.
  This bucket contains separate prefixes for blue and green deployments.

* `certificate_arn`
  ACM certificate used by CloudFront for HTTPS.
  The certificate must exist in the `us-east-1` region.

* `active_environment`
  Controls which S3 prefix CloudFront serves traffic from.
  Valid values are `/blue` and `/green`.
  Updating this value allows traffic to be switched between environments without redeploying assets.

### Provision Infrastructure

From the project root:

```
cd infrastructure/environments/dev
terraform init
terraform validate
terraform plan
terraform apply
```

This provisions:

* An S3 bucket for static frontend assets
* Blue and green deployment prefixes
* A CloudFront distribution secured with Origin Access Control
* Required IAM roles and bucket policies

IAM users or roles are **not** created by Terraform in this project.

## Deployment Process

1. Frontend changes are made in the `frontend/` directory
2. Changes are committed and pushed to the main branch
3. GitHub Actions workflow runs automatically
4. Files are uploaded to the inactive S3 environment
5. CloudFront origin path is updated
6. Traffic switches with minimal downtime
7. A deployment notification email is sent

## Rollback Process

If a deployment needs to be reverted:

1. Update the `active_environment` value in `main.tf`
2. Run:

```
terraform apply
```

CloudFront will begin serving content from the previous environment after propagation.

## Troubleshooting Guide

### Terraform Apply Fails

* Run `terraform validate`
* Check AWS credentials and permissions
* Review the Terraform error output
* Confirm the backend configuration is correct

---

### GitHub Actions Deployment Fails

* Review GitHub Actions logs
* Verify that repository secrets are configured correctly
* Ensure the AWS credentials have sufficient permissions

---

### Website Does Not Update

* Confirm the CloudFront origin path is pointing to the expected environment
* Ensure files exist in the active S3 prefix
* Allow a few minutes for CloudFront changes to propagate

---

### Access Denied Errors

* Verify that the S3 bucket policy allows CloudFront access
* Confirm Origin Access Control is correctly configured
* Check IAM permissions used by the CI/CD pipeline

---

## Security Considerations

* S3 public access is blocked
* IAM permissions follow the principle of least privilege
* Secrets are stored in GitHub repository secrets
* CloudFront Origin Access Control is used instead of legacy OAI
* Infrastructure changes are managed through Terraform
