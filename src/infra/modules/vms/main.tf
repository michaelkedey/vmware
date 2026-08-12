terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "~> 2.16.1"
    }
  }
}

resource "vsphere_virtual_machine" "vm" {
  for_each = var.vms

  name             = each.key
  resource_pool_id = var.resource_pool_id
  datastore_id     = var.datastore_id

  num_cpus = coalesce(each.value.num_cpus, var.default_num_cpus)
  memory   = coalesce(each.value.memory, var.default_memory)
  guest_id = coalesce(each.value.guest_id, var.default_guest_id)
  firmware = coalesce(each.value.firmware, var.default_firmware)

  cdrom {
    client_device = true
  }

  dynamic "network_interface" {
    for_each = each.value.networks
    content {
      network_id   = network_interface.value.network_id
      adapter_type = coalesce(each.value.adapter_type, var.default_adapter_type)
    }
  }

  dynamic "disk" {
    for_each = each.value.disks
    content {
      label            = disk.value.label
      size             = disk.value.size
      thin_provisioned = lookup(disk.value, "thin_provisioned", true)
    }
  }

  clone {
    template_uuid = each.value.template_uuid

    customize {
      # Linux customization (CentOS/RHEL/etc)
      dynamic "linux_options" {
        for_each = !contains(["windows", "win"], substr(lower(coalesce(each.value.guest_id, var.default_guest_id)), 0, 3)) ? [1] : []
        content {
          host_name = each.key
          domain    = coalesce(each.value.vm_domain, var.default_vm_domain)
        }
      }

      # Windows customization
      dynamic "windows_options" {
        for_each = contains(["windows", "win"], substr(lower(coalesce(each.value.guest_id, var.default_guest_id)), 0, 3)) ? [1] : []
        content {
          computer_name  = each.key
          admin_password = lookup(each.value, "admin_password", "Admin12345!")
        }
      }

      dynamic "network_interface" {
        for_each = each.value.networks
        content {
          ipv4_address = network_interface.value.ipv4_address
          ipv4_netmask = network_interface.value.ipv4_netmask
        }
      }

      ipv4_gateway    = each.value.ipv4_gateway
      dns_server_list = coalesce(each.value.dns_server_list, var.default_dns_server_list)
    }
  }
}

# resource "vsphere_virtual_machine" "vm" {
#   for_each = var.vms

#   name             = each.key
#   resource_pool_id = var.resource_pool_id
#   datastore_id     = var.datastore_id

#   num_cpus = coalesce(each.value.num_cpus, var.default_num_cpus)
#   memory   = coalesce(each.value.memory, var.default_memory)
#   guest_id = coalesce(each.value.guest_id, var.default_guest_id)
#   firmware = coalesce(each.value.firmware, var.default_firmware)

#   cdrom {
#     client_device = true
#   }

#   dynamic "network_interface" {
#     for_each = each.value.networks
#     content {
#       network_id   = network_interface.value.network_id
#       adapter_type = lookup(each.value, "adapter_type", var.default_adapter_type)
#     }
#   }

#   dynamic "disk" {
#     for_each = each.value.disks
#     content {
#       label            = disk.value.label
#       size             = disk.value.size
#       thin_provisioned = lookup(disk.value, "thin_provisioned", true)
#     }
#   }

#   clone {
#     template_uuid = each.value.template_uuid

#     # Completely empty customize block (no hanging vCenter scripts)
#     dynamic "customize" {
#       for_each = contains(["windows", "win"], substr(lower(lookup(each.value, "guest_id", var.default_guest_id)), 0, 3)) ? [1] : []
#       content {
#         windows_options {
#           computer_name  = each.key
#           admin_password = lookup(each.value, "admin_password", "Admin12345!")
#         }
#       }
#     }
#   }

#   # Since your key is already in the template, we only use remote-exec to fix the hostname
#   provisioner "remote-exec" {
#     connection {
#       type        = "ssh"
#       user        = "root"
#       private_key = file("~/.ssh/id_ed25519") # Uses your private key directly!
#       host        = self.default_ip_address
#     }

#     inline = [
#       "hostnamectl set-hostname ${each.key}"
#     ]
#   }
# }



