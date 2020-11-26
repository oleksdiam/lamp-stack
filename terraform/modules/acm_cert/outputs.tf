output "acm_certificate" {
  value = aws_acm_certificate.cert
}
output "domain_name" {
  value = aws_acm_certificate.cert.domain_name
}
