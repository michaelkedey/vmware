output "vm_ids" {
  description = "A map of VM names to their respective IDs."
  value       = { for k, vm in vsphere_virtual_machine.vm : k => vm.id }
}

output "vm_names" {
  description = "A map of VM names."
  value       = { for k, vm in vsphere_virtual_machine.vm : k => vm.name }
}

output "vm_guest_ip_addresses" {
  description = "A map of VM names to their guest IP addresses."
  value       = { for k, vm in vsphere_virtual_machine.vm : k => vm.guest_ip_addresses }
}

output "vm_moid" {
  description = "A map of VM names to their Managed Object IDs (MoID)."
  value       = { for k, vm in vsphere_virtual_machine.vm : k => vm.moid }
}