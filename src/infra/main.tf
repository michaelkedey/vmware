terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "~> 2.16.1"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true

}

data "vsphere_datacenter" "datacenter" {
  for_each = var.datacenters
  name     = each.value
}

data "vsphere_compute_cluster" "cluster" {
  for_each      = var.clusters
  name          = each.key
  datacenter_id = data.vsphere_datacenter.datacenter[each.value.datacenter_key].id
}

data "vsphere_datastore" "datastore" {
  for_each      = var.datastores
  name          = each.key
  datacenter_id = data.vsphere_datacenter.datacenter[each.value.datacenter_key].id
}

data "vsphere_host" "esxi" {
  for_each      = var.esxi_hosts
  name          = each.key
  datacenter_id = data.vsphere_datacenter.datacenter[each.value.datacenter_key].id
}

data "vsphere_virtual_machine" "template" {
  for_each      = var.vms
  name          = each.value.template_name
  datacenter_id = data.vsphere_datacenter.datacenter[each.value.datacenter_key].id
}

data "vsphere_network" "default_network" {
  for_each      = toset([for vm in var.vms : "VM Network" if contains(vm.network_keys, "VM Network")])
  name          = each.value
  datacenter_id = data.vsphere_datacenter.datacenter[var.vms[keys(var.vms)[0]].datacenter_key].id
}

# 4. vSwitches / VDS
module "vswitch" {
  source        = "./modules/vswitch"
  for_each      = var.vswitches
  datacenter_id = data.vsphere_datacenter.datacenter[each.value.datacenter_key].id

  vds_map = {
    (each.key) = {
      host_nics = [
        for hostname, host_info in var.esxi_hosts : {
          host_system_id = data.vsphere_host.esxi[hostname].id
          host_devices   = host_info.devices
        } if host_info.datacenter_key == each.value.datacenter_key
      ]
    }
  }
}

# Port Groups Module
module "port_group" {
  source     = "./modules/port_group"
  for_each   = var.port_groups
  vswitch_id = module.vswitch[each.value.vswitch_key].vds_ids[each.value.vswitch_key]

  port_groups = {
    (each.key) = {
      vlan_id = each.value.vlan_id
    }
  }
}

module "vm" {
  source   = "./modules/vms"
  for_each = var.vms

  datastore_id      = data.vsphere_datastore.datastore[each.value.datastore_key].id
  resource_pool_id  = data.vsphere_compute_cluster.cluster[each.value.cluster_key].resource_pool_id
  default_firmware  = var.default_firmware
  default_vm_domain = var.default_vm_domain

  vms = {
    (each.key) = {
      template_uuid   = data.vsphere_virtual_machine.template[each.key].id
      num_cpus        = each.value.num_cpus
      memory          = each.value.memory
      guest_id        = each.value.guest_id
      firmware        = each.value.firmware
      vm_domain       = lookup(each.value, "vm_domain", null)
      ipv4_gateway    = each.value.gateway
      dns_server_list = lookup(each.value, "dns_server_list", ["8.8.8.8", "1.1.1.1"])

      # networks = [
      #   for idx, net_key in each.value.network_keys : {
      #     network_id   = net_key == "VM Network" ? data.vsphere_network.default_network["VM Network"].id : module.port_group[net_key].port_group_ids[net_key]
      #     ipv4_address = each.value.nic_ips[idx]
      #     ipv4_netmask = each.value.subnet_mask
      #   }
      # ]]
      networks = [
        for idx, net_key in each.value.network_keys : {
          network_id   = net_key == "VM Network" ? data.vsphere_network.default_network["VM Network"].id : module.port_group[net_key].port_group_ids[net_key]
          ipv4_address = each.value.nic_ips[idx]
          ipv4_netmask = each.value.subnet_mask
        }
      ]

      ipv4_gateway = each.value.gateway

      networks = [
        for idx, net_key in each.value.network_keys : {
          network_id   = net_key == "VM Network" ? data.vsphere_network.default_network["VM Network"].id : module.port_group[net_key].port_group_ids[net_key]
          ipv4_address = net_key == "VM Network" ? null : each.value.nic_ips[idx]
          ipv4_netmask = net_key == "VM Network" ? null : each.value.subnet_mask
        }
      ]

      disks = [
        {
          label            = "disk0"
          size             = each.value.disk_size
          thin_provisioned = true
        }
      ]
    }
  }
}