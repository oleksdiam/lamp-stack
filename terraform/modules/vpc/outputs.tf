output "azs_deployed_qty" {
  value = local.azs_number
}
output "public_subnets" {
  value = aws_subnet.subnet_public.*.id
}
output "private_subnets" {
  value = aws_subnet.subnet_private.*.id
}
output "db_subnets" {
  value = aws_subnet.subnet_db.*.id
}
output "rds_subnet_group" {
  value = aws_db_subnet_group.rds_subnet_group
}
