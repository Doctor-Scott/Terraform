output "webserverPublicIp" {
  value = aws_instance.webserver.public_ip
}

/* output "ansiblePublicIP" {
  value = aws_instance.ansible.public_ip
} */
/* output "dockerPublicIP" {
  value = aws_instance.docker.public_ip
} */
