# resource "vsphere_host_port_group" "port_group" {
#   name                = var.port_group_name
#   virtual_switch_name = var.virtual_switch_name
#   host_system_id      = var.host_system_id
#   vlan_id             = var.vlan_id
# }

resource "vsphere_distributed_port_group" "pg" {
  for_each = var.port_groups

  name                            = each.key
  distributed_virtual_switch_uuid = var.vswitch_id
  vlan_id                         = each.value.vlan_id
}

terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "~> 2.16.1"
    }
  }
}
