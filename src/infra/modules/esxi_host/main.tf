resource "vsphere_host" "host" {
  hostname   = var.hostname
  username   = var.username
  password   = var.password
  datacenter = var.datacenter_id
  cluster    = var.cluster_id
  lockdown   = "disabled"
  license    = var.license_key
  force      = true
}
terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "~> 2.16.1"
    }
  }
}
