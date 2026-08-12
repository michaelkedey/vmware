variable "datacenter_id" {
  type        = string
  description = "The ID of the datacenter where the VDS will be created."
}

variable "vds_map" {
  type = map(object({
    host_nics = list(object({
      host_system_id = string
      host_devices   = list(string)
    }))
  }))
  description = "A map of vSwitch names and their associated host NIC mappings."
}