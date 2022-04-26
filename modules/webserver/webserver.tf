

resource "aws_security_group" "ec2-sg" {
  name        = "security-group"
  description = "allow inbound access to the EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "docker" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = var.ssh_key
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  private_ip                  = var.private_ip
  vpc_security_group_ids      = [aws_security_group.ec2-sg.id]

  tags = {
    Name = "estio-docker"
  }
  depends_on = [var.vpc_id, var.igw_id]
  //user_data  = file("modules/webserver/scripts/dockerStart.sh")

}

resource "aws_instance" "ansible" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = var.ssh_key
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id

  vpc_security_group_ids = [aws_security_group.ec2-sg.id]

  provisioner "file" {
    source      = "~/.ssh/${var.ssh_key}.pem"
    destination = "/home/ubuntu/.ssh/${var.ssh_key}.pem"
    connection {
      host        = aws_instance.ansible.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/${var.ssh_key}.pem")
    }
  }

  provisioner "file" {
    source      = "modules/webserver/scripts/playbook.yml"
    destination = "/home/ubuntu/playbook.yml"
    connection {
      host        = aws_instance.ansible.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/${var.ssh_key}.pem")
    }
  }

  provisioner "file" {
    source      = "modules/webserver/scripts/inventory.yml"
    destination = "/home/ubuntu/inventory.yml"
    connection {
      host        = aws_instance.ansible.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/${var.ssh_key}.pem")
    }

  }

  tags = {
    Name = "estio-ansible"
  }
  depends_on = [var.vpc_id, var.igw_id, aws_instance.docker]
  user_data  = file("modules/webserver/scripts/ansibleStart.sh")

}