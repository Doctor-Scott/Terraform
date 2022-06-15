




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

  ingress {
    protocol  = "tcp"
    from_port = 3306
    to_port   = 3306

    cidr_blocks = ["${var.publicIP}/32"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = ["${var.publicIP}/32"]
  }
}


resource "aws_db_subnet_group" "mysqlSubnet" {
  name       = "main"
  subnet_ids = [var.subnet_public1_id, var.subnet_public2_id]
  /* subnet_ids = [var.subnet_private1_id, var.subnet_private2_id, var.subnet_public_id] */

  tags = {
    Name = "DB subnet group"
  }
}

resource "aws_db_instance" "db" {

  identifier             = "mydb"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  allocated_storage      = 10
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
  db_subnet_group_name   = aws_db_subnet_group.mysqlSubnet.id
  db_name                = "estio"
  username               = "root"
  password               = var.dbPassword
  publicly_accessible    = true

  skip_final_snapshot = true
  tags = {
    Name = "mysql"
  }
}
output "rds_endpoint" {
  value = aws_db_instance.db.endpoint
}