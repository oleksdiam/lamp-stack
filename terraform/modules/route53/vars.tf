variable "hosted_zone_id" {
  description = "ID of the choozen hosted zone"
}
variable "alb" {
  description = "Load balancer dedicated to DNS record, as an object"
}
variable "domain_name" {
  description = "FQDN of application"
}