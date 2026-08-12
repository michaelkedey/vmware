resource "vsphere_datacenter" "dc" {
  name = var.datacenter_name
}

terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "~> 2.16.1"
    }
  }
}
