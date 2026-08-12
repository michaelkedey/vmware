# # output "datacenter_id" {
# #   value = module.data_center.datacenter_id
# # }

# # output "cluster_id" {
# #   value = module.cluster.cluster_id
# # }

# # outputs.tf
# output "datacenter_ids" {
#   value = { for k, v in data.vsphere_datacenter.datacenter : k => v.id }
# }

# output "cluster_ids" {
#   value = { for k, v in data.vsphere_compute_cluster.cluster : k => v.id }
# }

# # output "resource_pool_id" {
# #   value = module.cluster.resource_pool_id
# # }

# output "vm_ips" {
#   description = "IP addresses of the deployed Virtual Machines"
#   value       = { for k, m in module.vm : k => m.vm_ip_address }
# }

# output "ssh_commands" {
#   description = "Quick copy-paste SSH login strings"
#   value       = { for k, m in module.vm : k => "ssh root@${m.vm_ip_address}" }
# }


output "datacenter_ids" {
  value = { for k, v in data.vsphere_datacenter.datacenter : k => v.id }
}

output "cluster_ids" {
  value = { for k, v in data.vsphere_compute_cluster.cluster : k => v.id }
}

output "vm_guest_ips" {
  description = "IP addresses of the deployed Virtual Machines"
  value       = { for k, m in module.vm : k => m.vm_guest_ip_addresses }
}

output "ssh_commands" {
  description = "Quick copy-paste SSH login strings using the first discovered guest IP"
  value       = { for k, m in module.vm : k => "ssh root@${m.vm_guest_ip_addresses[k][0]}" }
}