# General variables
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "prefix" {
  description = "Prefix to be used for resource naming"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Networking variables
variable "vpc_id" {
  description = "ID of the VPC where resources will be deployed"
  type        = string
  default     = "vpc-0447ce23c0b23c40d"
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Lambda and RDS"
  type        = list(string)
  default     = ["subnet-0d3461bef14d8f64c", "subnet-09498c29d5a591532", "subnet-036dbbeda9811e85e"]
}

variable "enable_internet_access" {
  description = "Whether to enable internet access for Lambda functions"
  type        = bool
  default     = true
}

# Lambda variables
variable "lambda_runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "python3.12"
}

variable "lambda_timeout" {
  description = "Timeout for the Lambda function in seconds"
  type        = number
  default     = 900  # 15 minutes
}

variable "lambda_memory_size" {
  description = "Memory size for the Lambda function in MB"
  type        = number
  default     = 512
}

variable "lambda_ephemeral_storage_size" {
  description = "Ephemeral storage size for the Lambda function in MB"
  type        = number
  default     = 512
}

variable "lambda_environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {
    LOG_LEVEL = "INFO"
    REGION    = "ap-southeast-2"
  }
}

variable "enable_lambda_cross_account_access" {
  description = "Whether to enable cross-account access to Lambda"
  type        = bool
  default     = false
}

variable "lambda_cross_account_principal_arns" {
  description = "List of ARNs that can invoke the Lambda function from other accounts"
  type        = list(string)
  default     = []
}

# Lambda functions configuration
variable "lambda_functions" {
  description = "Map of Lambda functions to create with their configurations"
  type = map(object({
    name                     = string
    description             = optional(string, "")
    handler                 = optional(string, "index.handler")
    runtime                 = optional(string)
    timeout                 = optional(number)
    memory_size            = optional(number)
    ephemeral_storage_size = optional(number)
    environment_variables  = optional(map(string), {})
    enable_cross_account   = optional(bool, false)
    cross_account_principals = optional(list(string), [])
  }))
  default = {}
}

# RDS Aurora variables
variable "db_engine_version" {
  description = "Aurora PostgreSQL engine version"
  type        = string
  default     = "15.5"
}

variable "db_instance_class" {
  description = "Instance class for Aurora PostgreSQL"
  type        = string
  default     = "db.t4g.medium"
}

variable "db_instances" {
  description = "Map of DB instances to create"
  type        = map(any)
  default = {
    one = {}
  }
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "airflow"
}

variable "db_master_username" {
  description = "Master username for the database"
  type        = string
  default     = "airflow"
}

variable "db_backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "db_apply_immediately" {
  description = "Whether to apply DB changes immediately"
  type        = bool
  default     = false
}

variable "deploy_rds" {
  description = "Whether to deploy an RDS Aurora cluster"
  type        = bool
  default     = true
}

# S3 Configuration
variable "s3_config" {
  description = "Configuration for S3 bucket deployment"
  type = object({
    enabled = bool
    force_destroy = optional(bool, false)
    enable_versioning = optional(bool, true)
    lifecycle_rules = optional(list(any), [])
  })
  default = {
    enabled = false
  }
}

# S3 Event Configuration
variable "s3_event_notifications" {
  description = "Map of S3 event notifications configurations. For targets, specify configuration details based on type."
  type = map(object({
    name           = string
    events         = list(string)  # e.g., ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_prefix  = optional(string)
    filter_suffix  = optional(string)
   
    # Target configuration
    target = object({
      type = string  # "lambda", "sns", or "sqs"
      name = optional(string)  # Lambda function name for lambda type
      arn = optional(string)   # Full ARN for existing sns/sqs resources
     
      # For created resources (SNS/SQS)
      create = optional(bool, false)  # Whether to create the target resource
     
      # SNS specific configurations
      email_subscribers = optional(list(string), [])  # List of email addresses to subscribe to the SNS topic
     
      # SQS specific configurations
      retention_seconds = optional(number)        # Message retention period in seconds
      visibility_timeout = optional(number)       # Visibility timeout in seconds
     
      # Encryption settings for SNS/SQS
      encryption_key_id = optional(string)  # KMS key ID for encryption
    })
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.s3_event_notifications :
      contains(["lambda", "sns", "sqs"], v.target.type)
    ])
    error_message = "Target type must be one of: lambda, sns, or sqs"
  }

  validation {
    condition = alltrue([
      for k, v in var.s3_event_notifications :
      v.target.type != "lambda" || (v.target.name != null && can(regex("^[a-zA-Z0-9-_]+$", v.target.name)))
    ])
    error_message = "Lambda target names must be valid function names (alphanumeric with hyphens and underscores)"
  }

  validation {
    condition = alltrue([
      for k, v in var.s3_event_notifications :
      v.target.type != "sns" || v.target.create == true || (v.target.arn != null && can(regex("^arn:aws:sns:", v.target.arn)))
    ])
    error_message = "External SNS targets must be specified as full ARNs"
  }

  validation {
    condition = alltrue([
      for k, v in var.s3_event_notifications :
      v.target.type != "sqs" || v.target.create == true || (v.target.arn != null && can(regex("^arn:aws:sqs:", v.target.arn)))
    ])
    error_message = "External SQS targets must be specified as full ARNs"
  }
}
