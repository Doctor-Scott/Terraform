
variable "ami_id" {
  type    = string
  default = "ami-0015a39e4b7c0966f"
}

variable "ssh_key" {
  type    = string
  default = "Estio-Ubuntu"
}

variable "subnet_id" {
  type        = string
  description = "subnet_id"
}

variable "vpc_id" {
  type = string
}

variable "igw_id" {
  type = string
}

variable "private_ip" {
  type = string
}

variable "rdsDns"{
  type = string
default = ""
}

variable "dbPassword" { type = string }
