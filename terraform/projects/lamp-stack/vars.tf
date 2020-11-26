variable "aws_profile" {
  description = "The AWS profile used for deploy"
  default     = "ss-devops"
}
variable "aws_region" {
  description = "The AWS region we deploy to"
  default     = "us-east-1"
}
variable "aws_vpc" {
  description = "The AWS vpc to deploy to"
  default     = "vpc-0703617471eb7e67f"
}
variable "azs_count" {
  description = "Quantity of AZs in the particular region to use"
  default     = 3
}
# limitation is that 'count' parameter can't depend on dynamic data

variable "environment" {
  description = "environment for service"
  default     = "DEV"
}

variable "app_ami" {
  description = "ami's ID for app instance"
  default     = "ami-04bf6dcdc9ab498ca"
}
variable "empty_ami" {
  description = "empty ami's ID for bastion instance and other purposes"
  default     = "ami-04bf6dcdc9ab498ca"
}
variable "dbname" {
  description = "Database name"
  default     = "wpdb"
}
variable "dbuser" {
  description = "Name of Database superuser"
  default     = "wpuser"
}
variable "dbpass" {
  description = "Password of Database superuser"
  default     = "Ub$K7s_T3K"
}

variable "domain_name" {
  description = "FQDN of application"
  default     = "odiam.wordpress.support-coe.com"
}

variable "ssh_access_cidr" {
  description = "The list of CIDRs that allowed SSH access from"
  default     = ["0.0.0.0/0"]
}
