resource "vsphere_distributed_virtual_switch" "vds" {
  for_each = var.vds_map

  name          = each.key
  datacenter_id = var.datacenter_id

  # Map physical hosts and their physical NICs to the VDS uplinks
  dynamic "host" {
    for_each = each.value.host_nics
    content {
      host_system_id = host.value.host_system_id
      devices        = host.value.host_devices
    }
  }
}
terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "~> 2.16.1"
    }
  }
}
