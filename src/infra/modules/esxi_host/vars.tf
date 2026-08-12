variable "hostname" {
  type = string
}

variable "username" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "datacenter_id" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "license_key" {
  type      = string
  default   = null
  sensitive = true
}