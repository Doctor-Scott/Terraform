variable "ami_app" {
  type    = string
  default = "ami-073ee45c9f61cbaa3"
}

variable "ssh_key" {
  type    = string
  default = "Estio-Ubuntu"
}

/* variable "my_security_group_id" {
    type = string

} */

variable "my_subnet_id" {
  type    = string
  default = ""
}


variable "get_public_ip" {
  type = string
}

variable "get_db_endpoint" {
  type = string

}

variable "username" {
  type = string

}

variable "password" {
  type = string

}


variable "db_name" {
  type = string

}

/* variable "database_instance" {
    type = string

} */

variable "vpc_id" {
  type = string

}



variable "private_ip" {
  type = string
}