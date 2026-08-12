variable "vsphere_user" {
  type        = string
  description = "vCenter username"
}

variable "vsphere_password" {
  type        = string
  description = "vCenter password"
  sensitive   = true
}

variable "vsphere_server" {
  type        = string
  description = "vCenter server IP or FQDN"
}

variable "datacenters" {
  type        = map(any)
  description = "Map of datacenters"
}

variable "clusters" {
  type = map(object({
    datacenter_key = string
  }))
  description = "Map of clusters and their parent datacenters"
}

variable "datastores" {
  type = map(object({
    datacenter_key = string
  }))
  description = "Map of datastores"
}

variable "esxi_hosts" {
  type = map(object({
    datacenter_key = string
    cluster_key    = string
    username       = string
    password       = string
    devices        = list(string)
  }))
  description = "Map of ESXi hosts, their datacenters, and their physical uplinks"
}

variable "vswitches" {
  type = map(object({
    datacenter_key = string
  }))
  description = "Map of vSwitches/VDS to create"
}

variable "port_groups" {
  type = map(object({
    vswitch_key = string
    vlan_id     = number
  }))
  description = "Map of port groups, their vSwitch parent, and VLAN IDs"
}

variable "default_firmware" {
  type        = string
  description = "Default firmware type for VMs (bios or efi)"
}

variable "default_vm_domain" {
  type        = string
  description = "Default domain for VM guest customization"
}

variable "vms" {
  type = map(object({
    datacenter_key  = string
    cluster_key     = string
    datastore_key   = string
    network_keys    = list(string)
    nic_ips         = list(string)
    subnet_mask     = number
    gateway         = string
    num_cpus        = number
    memory          = number
    disk_size       = number
    guest_id        = string
    template_name   = string
    firmware        = optional(string)
    vm_domain       = optional(string)
    dns_server_list = optional(list(string))
  }))
}