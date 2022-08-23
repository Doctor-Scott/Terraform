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

resource "aws_instance" "webserver" {
  ami                         = var.ami_app
  instance_type               = "t2.micro"
  key_name                    = var.ssh_key
  associate_public_ip_address = true
  subnet_id                   = var.my_subnet_id
  private_ip                  = var.private_ip
  vpc_security_group_ids      = [aws_security_group.ec2-sg.id]
  tags = {
    Name = "estio-nathan-webserver"
  }

  user_data  = <<-EOL
  #!/bin/bash 
  sudo apt update
  sudo touch /home/ubuntu/username /home/ubuntu/password /home/ubuntu/endpoint /home/ubuntu/name
  sudo chown ubuntu /home/ubuntu/username /home/ubuntu/username /home/ubuntu/password /home/ubuntu/endpoint /home/ubuntu/name
  sudo chgrp ubuntu /home/ubuntu/username /home/ubuntu/username /home/ubuntu/password /home/ubuntu/endpoint /home/ubuntu/name
  sudo echo "USERNAME=${var.username}" >> /etc/environment
  sudo echo "PASSWORD=${var.password}" >> /etc/environment
  sudo echo "ENDPOINT=${var.get_db_endpoint}" >> /etc/environment
  sudo echo "NAME=${var.db_name}" >> /etc/environment
  EOL
  depends_on = [var.get_db_endpoint]

}

resource "null_resource" "connect_web" {
  provisioner "remote-exec" {
    inline = [
      "sudo echo 'ubuntu ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo"
    ]
    connection {
      host        = aws_instance.webserver.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/${var.ssh_key}.pem")
    }

  }
  depends_on = [aws_instance.webserver]
}

resource "null_resource" "file_transfer" {
  provisioner "file" {
    source      = "modules/ec2/scripts/playbook.yaml"
    destination = "/home/ubuntu/"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/${var.ssh_key}.pem")
      host        = aws_instance.webserver.public_ip
    }
  }

  depends_on = [
    aws_instance.webserver, null_resource.connect_web
  ]

}

resource "null_resource" "connect_web2" {
  provisioner "remote-exec" {
    inline = [
      "sudo su -l ubuntu -c 'sudo git clone https://github.com/nathanforester/FlaskMovieDB2.git'",
      "sudo su -l ubuntu -c 'sudo chown -R /home/ubuntu/FlaskMovieDB2'",
      "sudo su -l ubuntu -c 'sudo chown ubuntu /home/ubuntu/FlaskMovieDB2/startup.sh /home/ubuntu/FlaskMovieDB2/create.py /home/ubuntu/FlaskMovieDB2/app.py'",
      "sudo su -l ubuntu -c 'sudo apt install mysql-server -y'",
      "sudo su -l ubuntu -c 'sudo apt install software-properties-common'",
      "sudo su -l ubuntu -c 'sudo add-apt-repository --yes --update ppa:ansible/ansible'",
      "sudo su -l ubuntu -c 'sudo apt install ansible -y'",
      "sudo su -l ubuntu -c 'ansible-playbook /home/ubuntu/ansible-project/playbook.yaml'",
      "sudo su -l ubuntu -c 'sudo chown ubuntu /var/run/docker.sock'",
      "sudo su -l ubuntu -c '. /home/ubuntu/FlaskMovieDB2/startup.sh'",
    ]

    connection {
      host        = aws_instance.webserver.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/${var.ssh_key}.pem")
    }

  }
  depends_on = [aws_instance.webserver, null_resource.connect_web, null_resource.file_transfer]
}
