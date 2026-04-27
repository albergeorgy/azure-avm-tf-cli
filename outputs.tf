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
