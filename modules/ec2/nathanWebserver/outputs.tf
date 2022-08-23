output "webserverPublicIp" {
  value = aws_instance.webserver.public_ip
}