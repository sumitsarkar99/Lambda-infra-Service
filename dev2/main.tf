provider "aws" {
  region = "ap-southeast-2"
}

module "airflow_environment" {
  source = "app.terraform.io/FMGL/airflow-runtime/aws"
  version = "1.1.17"

  # General variables
  prefix      = var.prefix
  environment = var.environment
  tags        = var.tags

  # Networking variables
  vpc_id                = var.vpc_id
  private_subnet_ids    = var.private_subnet_ids
  enable_internet_access = var.enable_internet_access

  # Lambda variables
  lambda_runtime                      = var.lambda_runtime
  lambda_timeout                      = var.lambda_timeout
  lambda_memory_size                  = var.lambda_memory_size
  lambda_ephemeral_storage_size       = var.lambda_ephemeral_storage_size
  lambda_environment_variables        = var.lambda_environment_variables
  enable_lambda_cross_account_access  = var.enable_lambda_cross_account_access
  lambda_cross_account_principal_arns = var.lambda_cross_account_principal_arns
  lambda_functions                    = var.lambda_functions

  # S3 configuration
  s3_config = var.s3_config
  s3_event_notifications = var.s3_event_notifications

  # Component toggles
  deploy_rds = var.deploy_rds
}
