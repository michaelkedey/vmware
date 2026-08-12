output "port_group_ids" {
  description = "A map of port group names to their respective IDs."
  value       = { for k, pg in vsphere_distributed_port_group.pg : k => pg.id }
}

output "port_group_names" {
  description = "A map of port group names."
  value       = { for k, pg in vsphere_distributed_port_group.pg : k => pg.name }
}