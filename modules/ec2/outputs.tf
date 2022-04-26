output "ansiblePublicIP" {
  value = aws_instance.ansible.public_ip
}
output "dockerPublicIP" {
  value = aws_instance.docker.public_ip
}
