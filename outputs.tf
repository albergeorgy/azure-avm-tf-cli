output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = module.resource_group.resource_id
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = module.virtual_network.name
}

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = module.virtual_network.resource_id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.key_vault.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.key_vault.uri
}

output "nsg_id" {
  description = "ID of the Network Security Group"
  value       = module.nsg.resource_id
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = module.log_analytics.resource_id
}

output "windows_vm_name" {
  description = "Name of the Windows VM"
  value       = module.windows_vm.name
}

output "windows_vm_private_ip" {
  description = "Private IP address of the Windows VM"
  value       = module.windows_vm.network_interfaces.nic0.private_ip_addresses[0]
}

output "application_gateway_name" {
  description = "Name of the Application Gateway"
  value       = module.application_gateway.application_gateway_name
}

output "application_gateway_public_ip" {
  description = "Public IP address of the Application Gateway"
  value       = module.application_gateway.new_public_ip_address
}
