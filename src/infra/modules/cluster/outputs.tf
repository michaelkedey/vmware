output "cluster_id" {
  description = "The managed object ID of the vSphere compute cluster"
  value       = vsphere_compute_cluster.cluster.id
}

output "resource_pool_id" {
  description = "The default resource pool ID of the cluster (needed for VMs)"
  value       = vsphere_compute_cluster.cluster.resource_pool_id
}