# Lambda-infra-Service
AWS automation for deploying set up though Lambda

Prerequisites
===================
Before executing this Terraform Cloud (TFC) deployment pipeline via GitHub Actions, ensure the following prerequisites are met:

1. AWS Account Setup
You must have an active AWS account.

Create an IAM user with sufficient permissions (AdministratorAccess or scoped access for Lambda, S3, IAM, Secrets Manager, etc.).

Alternatively, use an IAM Role with OIDC trust policy to enable GitHub Actions to assume the role securely via OpenID Connect (OIDC).

2. GitHub Account & Repository
A GitHub account is required.

Create or use an existing repository where your Terraform configurations, Lambda source code, and GitHub Actions workflow files will be stored.

Store required secrets under GitHub repository settings → Secrets and variables → Actions, such as:

TF_API_TOKEN: Terraform Cloud user API token

S3_BUCKET: Name of the target S3 bucket for Lambda deployment

LAMBDA_JSON_SECRET: (Optional) JSON containing post-deployment secret values

3. Terraform Cloud (TFC) Account
Create a free or paid account at Terraform Cloud.

Set up an organization and workspace within TFC.

For VCS-connected workspaces, push-based deployment is restricted — use API workflows instead (as done in this project).

Generate a User API Token from your Terraform Cloud User Settings and store it as TF_API_TOKEN in your GitHub secrets.

4. IAM Role for GitHub OIDC Access
Create an IAM Role in AWS with:

Trust relationship allowing GitHub Actions from your repo to assume the role via OIDC.

Permissions policy allowing access to services like Lambda, S3, Secrets Manager, etc.
===========================
Example trust policy for GitHub OIDC:

json

Trust relationships json code:
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::<aws account id> :oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": [
                "sts:AssumeRoleWithWebIdentity",
                "sts:TagSession"
            ],
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "ForAnyValue:StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:<GitHub organisation name>/<github repo name>:*"
                }
            }
        }
    ]
}
================================================
5. Terraform Backend Configuration
The project uses Terraform Cloud remote backend, configured in main.tf with:

hcl
Copy
Edit
terraform {
  cloud {
    organization = "your-org"
    workspaces {
      name = "your-workspace"
    }
  }
}

6. Required Tools (for Local Testing or Debugging)
If you plan to test locally:

Terraform CLI

AWS CLI

Python 3.12+

jq (for JSON processing in shell scripts)
