output "db_endpoint" {
  value = aws_db_instance.mariadb.endpoint
}
output "dbname" {
  value = aws_db_instance.mariadb.name
}
output "dbusername" {
  value = aws_db_instance.mariadb.username
}
output "dbpass" {
  value = aws_db_instance.mariadb.password
}
