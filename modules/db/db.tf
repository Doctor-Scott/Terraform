




resource "aws_security_group" "rds-sg" {
  name        = "rds-security-group"
  description = "allow inbound access to the database"
  vpc_id      = var.vpc_id

  ingress {
    protocol  = "tcp"
    from_port = 3306
    to_port   = 3306

    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = ["10.0.0.0/16"]
  }
}


resource "aws_db_subnet_group" "mysqlSubnet" {
  name       = "main"
  subnet_ids = [var.subnet_private1_id, var.subnet_private2_id]
  tags = {
    Name = "DB subnet group"
  }
}

resource "aws_db_instance" "db" {
  identifier             = "mydb"
  engine                 = "mysql"
  engine_version         = "5.6"
  instance_class         = "t2micro"
  allocated_storage      = 1
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
  db_subnet_group_name   = aws_db_subnet_group.mysqlSubnet.id
  db_name                = "mainDB"
  username               = "root"
  password               = "password"
  tags = {
    Name = "default mysql db"
  }
}
 