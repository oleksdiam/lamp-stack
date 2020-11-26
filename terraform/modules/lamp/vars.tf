variable "ami_image" {
  description = "Standard ami Amazon Linux 2 HVM 64bitx86 image"
  default     = "ami-04bf6dcdc9ab498ca"
}
variable "instance_type" {
  description = "Instance type to deploy"
  default     = "t2.micro"
}
variable "vpc_id" {
  description = "The AWS vpc to deploy to"
  default     = "vpc-0703617471eb7e67f"
}
variable "azs_count" {
  description = "Number of AZs in the particular region to use"
  default     = 3
}
variable "public_subnets" {
  description = "Tuple of public subnets"
}
variable "private_subnets" {
  description = "Tuple of private subnets"
}
variable "ssh_sg_id" {
  description = "ID of Security group provided SSH access"
}

variable "allowed_ports" {
  description = "ports allowed for requests to application"
  default     = ["80", "443"]
}
