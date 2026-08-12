data "vsphere_datastore" "ds" {
  name          = var.datastore_name
  datacenter_id = var.datacenter_id
}
terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "~> 2.16.1"
    }
  }
}
