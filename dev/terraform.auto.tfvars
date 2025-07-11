# Sample tfvars file for Airflow Runtime Environment

# General variables
prefix      = "lambda-01"
environment = "dev01"

# Networking variables
vpc_id             = <"vpc id">
private_subnet_ids = ["subnet-01", "subnet-02", "subnet-03"]
enable_internet_access = true

# Default Lambda variables (used as fallback values)
lambda_runtime             = "python3.12"
lambda_timeout             = 900
lambda_memory_size         = 1024
lambda_ephemeral_storage_size = 1024
lambda_environment_variables = {}

# Lambda functions configuration
lambda_functions = {
  # Default function (equivalent to the original single lambda)
  default = {
    name = "default"
    description = "Airflow runtime environment Lambda function"
    # Uses all the default values from the variables above
  }
}

# S3 Configuration
s3_config = {
  enabled           = true
  force_destroy     = true  # Set to false for production
  enable_versioning = true
}

# S3 Event Notifications
s3_event_notifications = {
  # Process new data files
  lambda_alert_data1 = {
    name          = "lambda-alert-data1"
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "dev/Inputs"
    filter_suffix = ".xlsx"
    target = {
      type = "lambda"
      name = "default"
    }
  }
}

# S3 variables
s3_force_destroy    = false  # Set to false for production
enable_s3_versioning = true

# Tags
tags = {
  Project     = "Project1"
  Owner       = "Dev-engg"
  CostCenter  = "123456"
}

deploy_rds = false
