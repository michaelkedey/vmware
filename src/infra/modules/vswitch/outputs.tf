# output "vds_ids" {
#   description = "A map of vSwitch names to their respective IDs."
#   value       = { for k, vds in vsphere_distributed_virtual_switch.vds : k => vds.id }
# }

# output "vds_names" {
#   description = "A map of vSwitch names."
#   value       = { for k, vds in vsphere_distributed_virtual_switch.vds : k => vds.name }
# }

# output "vds_uplinks" {
#   description = "A map of vSwitch names to their assigned uplink port group keys."
#   value       = { for k, vds in vsphere_distributed_virtual_switch.vds : k => vds.uplink_distribution }
# }

output "vds_ids" {
  description = "A map of vSwitch names to their respective IDs."
  value       = { for k, vds in vsphere_distributed_virtual_switch.vds : k => vds.id }
}

output "vds_names" {
  description = "A map of vSwitch names."
  value       = { for k, vds in vsphere_distributed_virtual_switch.vds : k => vds.name }
}