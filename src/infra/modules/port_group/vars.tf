variable "vswitch_id" {
  type        = string
  description = "The UUID of the distributed virtual switch."
}

variable "port_groups" {
  type = map(object({
    vlan_id = number
  }))
  description = "A map of port group names and their associated VLAN IDs."
}