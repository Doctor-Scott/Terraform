output "ansiblePublicIP" {
  value = aws_instance.ansible.public_ip
}
output "dockerPrivateIP" {
  value = aws_instance.docker.private_ip
}
