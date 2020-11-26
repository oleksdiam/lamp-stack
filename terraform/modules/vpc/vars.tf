variable "vpc_id" {
  description = "The AWS vpc to deploy to"
  default     = "vpc-0703617471eb7e67f"
}
variable "azs_count" {
  description = "Number of AZs in the particular region to use"
  default     = 3
}
variable "single_nat_gateway" {
  description = "Use of Nat gateways either at every public subnet or single one"
  default     = "true"
}
variable "cidr_start_index" {
  description = "the first from used for subnet's CIDR ranges"
  default     = 0
}
variable "environment" {
  description = "environment for service"
  default     = "DEV"
}
