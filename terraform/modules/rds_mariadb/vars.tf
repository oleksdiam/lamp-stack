variable "vpc_id" {
  description = "The AWS vpc to deploy to"
  default     = "vpc-0703617471eb7e67f"
}
variable "storage_size" {
  description = "Allocated storage size, GiB"
  default     = 20
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
}
variable "rds_subnet_group" {
  description = "subnet group where the database is placing"
}
