




resource "aws_security_group" "docdb-sg" {
  name        = "docdb-security-group"
  description = "allow inbound access to the database"
  vpc_id      = var.vpc_id

  ingress {
    protocol  = "tcp"
    from_port = 27017
    to_port   = 27017

    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 27017
    to_port     = 27017
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    protocol  = "tcp"
    from_port = 27017
    to_port   = 27017

    cidr_blocks = ["${var.publicIP}/32"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 27017
    to_port     = 27017
    cidr_blocks = ["${var.publicIP}/32"]
  }
}


resource "aws_db_subnet_group" "docdbSubnet" {
  name       = "main"
  subnet_ids = [var.subnet_public1_id, var.subnet_public2_id]
  /* subnet_ids = [var.subnet_private1_id, var.subnet_private2_id, var.subnet_public_id] */

  tags = {
    Name = "DB subnet group"
  }
}

resource "aws_docdb_cluster_instance" "db" {
  count              = 1
  identifier         = "estio-cluster-${count.index}"
  cluster_identifier = aws_docdb_cluster.db.id
  instance_class = "db.t3.medium"
}

resource "aws_docdb_cluster" "db" {
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.docdbSubnet.name
  cluster_identifier   = "estio-cluster"
  engine               = "docdb"
  master_username      = "root"
  master_password      = var.dbPassword
db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.db.name

  vpc_security_group_ids = [aws_security_group.docdb-sg.id]
}


resource "aws_docdb_cluster_parameter_group" "db" {
  family = "docdb4.0"
  name = "estio-cluster"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}
/* resource "aws_db_instance" "db" {

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
} */

