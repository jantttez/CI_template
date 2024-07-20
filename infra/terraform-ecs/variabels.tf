
variable "default_subnet" {
  default = "10.0.0.1/24"

}

variable "GITLAB_USER" {
  default = "jantttez"
}

variable "GITLAB_PASSWORD" {
  default = "{$PASSWORD}"
}


variable "project_name" {
    default = "name"
  
}