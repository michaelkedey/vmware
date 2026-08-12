resource "vsphere_compute_cluster" "cluster" {
  name          = var.cluster_name
  datacenter_id = var.datacenter_id
  ha_enabled    = false
  drs_enabled   = false
}

terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "~> 2.16.1"
    }
  }
}
