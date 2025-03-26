output "admin_ssh_key_public" {
  description = "The generated public key data in PEM format"
  value       = module.vmss.admin_ssh_key_public
}

output "admin_ssh_key_private" {
  description = "The generated private key data in PEM format"
  sensitive   = true
  value       = module.vmss.admin_ssh_key_private
}

output "linux_vm_password" {
  description = "Password for the Linux VM"
  sensitive   = true
  value       = module.vmss.linux_vm_password
}

output "load_balancer_public_ip" {
  description = "The Public IP address allocated for load balancer"
  value       = module.vmss.load_balancer_public_ip
}

output "load_balancer_nat_pool_id" {
  description = "The resource ID of the Load Balancer NAT pool."
  value       = module.vmss.load_balancer_nat_pool_id
}

output "load_balancer_health_probe_id" {
  description = "The resource ID of the Load Balancer Probe."
  value       = module.vmss.load_balancer_health_probe_id
}

output "load_balancer_rules_id" {
  description = "The resource ID of the Load Balancer Rule"
  value       = module.vmss.load_balancer_rules_id
}

output "network_security_group_id" {
  description = "The resource id of Network security group"
  value       = module.vmss.network_security_group_id
}

output "linux_virtual_machine_scale_set_name" {
  description = "The name of the Linux Virtual Machine Scale Set."
  value       = module.vmss.linux_virtual_machine_scale_set_name
}

output "linux_virtual_machine_scale_set_id" {
  description = "The resource ID of the Linux Virtual Machine Scale Set."
  value       = module.vmss.linux_virtual_machine_scale_set_id
}

output "linux_virtual_machine_scale_set_unique_id" {
  description = "The unique ID of the Linux Virtual Machine Scale Set."
  value       = module.vmss.linux_virtual_machine_scale_set_unique_id
}

