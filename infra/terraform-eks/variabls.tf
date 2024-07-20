variable "vpc_cidr_block" {
  default = "192.168.0.0/16"
}

variable "publick_cidr_block" {
  default = [
    "172.0.1.0/24",
    "172.0.2.0/24",
  ]
}


variable "private_cidr_block" {
  default = [
    "172.0.11.0/24",
    "172.0.22.0/24",
  ]
}
