# variable "vm_name" {
#   type    = string
#   default = "vm1"
# }

# variable "num_cpus" {
#   type    = number
#   default = 2
# }

# variable "memory" {
#   type    = number
#   default = 8096
# }

# variable "disk_size" {
#   type    = number
#   default = 80
# }

# variable "guest_id" {
#   type    = string
#   default = "other3xLinux64Guest"
# }

# variable "resource_pool_id" {
#   type = string
# }

# variable "datastore_id" {
#   type = string
# }

# # variable "network_id" {
# #   type = string
# # }

# variable "firmware" {
#   type        = string
#   description = "Virtual firmware type (bios or efi)"
#   default     = "efi"
# }

# variable "template_uuid" {
#   type        = string
#   description = "The UUID of the source template VM"
# }

# # variable "template_name" {
# #   type = string
# # }

# variable "vm_domain" {
#   type        = string
#   description = "Domain name for guest customization"
#   default     = "local"
# }

# variable "adapter_type" {
#   type        = string
#   description = "Network adapter type (e.g., vmxnet3)"
#   default     = "vmxnet3"
# }

# variable "disk_label" {
#   type        = string
#   description = "Disk label for the primary disk"
#   default     = "disk0"
# }

# variable "thin_provisioned" {
#   type        = bool
#   description = "Thin provision the disk"
#   default     = true
# }

# variable "ipv4_gateway" {
#   type        = string
#   description = "IPv4 default gateway for guest customization"
# }

# variable "dns_server_list" {
#   type        = list(string)
#   description = "List of DNS servers"
#   default     = ["8.8.8.8", "1.1.1.1"]
# }

# variable "networks" {
#   type = list(object({
#     network_id   = string
#     ipv4_address = string
#     ipv4_netmask = number
#   }))
#   description = "List of networks and static IP settings"
# }


variable "resource_pool_id" {
  type        = string
  description = "The ID of the resource pool where VMs will be created."
}

variable "default_admin_password" {
  type        = string
  description = "Default administrator password for Windows guest customization"
  default     = "Admin12345!"
  sensitive   = true
}

variable "datastore_id" {
  type        = string
  description = "The ID of the datastore where VMs will be stored."
}

# Defaults
variable "default_num_cpus" {
  type    = number
  default = 2
}

variable "default_memory" {
  type    = number
  default = 8096
}

variable "default_guest_id" {
  type    = string
  default = "other3xLinux64Guest"
}

variable "default_firmware" {
  type = string
}

variable "default_adapter_type" {
  type    = string
  default = "vmxnet3"
}

variable "default_vm_domain" {
  type    = string
  default = "local"
}

variable "default_dns_server_list" {
  type    = list(string)
  default = ["8.8.8.8", "1.1.1.1"]
}

# Main multi-VM input map
variable "vms" {
  type = map(object({
    template_uuid   = string
    num_cpus        = optional(number)
    memory          = optional(number)
    guest_id        = optional(string)
    firmware        = optional(string)
    adapter_type    = optional(string)
    vm_domain       = optional(string)
    ipv4_gateway    = string
    dns_server_list = optional(list(string))
    networks = list(object({
      network_id   = string
      ipv4_address = optional(string)
      ipv4_netmask = optional(number)
    }))
    disks = list(object({
      label            = string
      size             = number
      thin_provisioned = optional(bool)
    }))
  }))
  description = "A map of virtual machines to provision with their respective configurations."
}
