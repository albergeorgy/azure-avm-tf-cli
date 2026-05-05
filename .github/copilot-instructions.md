# Copilot Coding Agent Instructions — Azure AVM Terraform

## Project Context

This repo deploys Azure infrastructure using Azure Verified Modules (AVM) with Terraform.
The backend is Azure Storage (OIDC auth). CI/CD uses GitHub Actions.

## When you receive a request

1. **Identify the Azure resources needed** from the natural language description
2. **Always use Azure Verified Modules (AVM)** from the Terraform registry
   - Registry namespace: `Azure/avm-res-*` and `Azure/avm-ptn-*`
   - Browse available modules: https://registry.terraform.io/namespaces/Azure
   - Pattern modules (`avm-ptn-*`) for common patterns (e.g., hub-spoke networking)
   - Resource modules (`avm-res-*`) for individual resources
3. **Follow existing code patterns** in `main.tf` for naming, tagging, and structure
4. **Use variables** — add new variables to `variables.tf` with descriptions and defaults
5. **Add outputs** for key resource IDs and names to `outputs.tf`
6. **Use environment tfvars** — update `environments/dev/terraform.tfvars` and `environments/prod/terraform.tfvars`
7. **Run `terraform fmt`** before committing
8. **Run `terraform validate`** to check for errors
9. **If terraform validate fails**, fix the error and retry — do not give up

## Naming Convention

- Resource names: `{type}-{project_name}-{environment}` (e.g., `rg-myproject-dev`)
- Use `local.common_tags` for all resources

## AVM Module Examples Already in Use

- Resource Group: `Azure/avm-res-resources-resourcegroup/azurerm ~> 0.4`
- Virtual Network: `Azure/avm-res-network-virtualnetwork/azurerm ~> 0.7`
- Key Vault: `Azure/avm-res-keyvault-vault/azurerm ~> 0.9`
- NSG: `Azure/avm-res-network-networksecuritygroup/azurerm ~> 0.4`
- Log Analytics: `Azure/avm-res-operationalinsights-workspace/azurerm ~> 0.4`
- Windows VM: `Azure/avm-res-compute-virtualmachine/azurerm ~> 0.18`

## Common AVM Modules to Consider

- AKS: `Azure/avm-res-containerservice-managedcluster/azurerm`
- SQL Database: `Azure/avm-res-sql-server/azurerm`
- Storage Account: `Azure/avm-res-storage-storageaccount/azurerm`
- App Service: `Azure/avm-res-web-site/azurerm`
- Container Registry: `Azure/avm-res-containerregistry-registry/azurerm`
- Private Endpoint: `Azure/avm-res-network-privateendpoint/azurerm`
- Public IP: `Azure/avm-res-network-publicipaddress/azurerm`
- Azure Firewall: `Azure/avm-res-network-azurefirewall/azurerm`
- Application Gateway: `Azure/avm-res-network-applicationgateway/azurerm`
- Hub Networking Pattern: `Azure/avm-ptn-hubnetworking/azurerm`

## Important Rules

- NEVER hardcode secrets — use variables or Key Vault references
- ALWAYS set `tags = local.common_tags` on every resource
- Default region is `canadacentral` unless specified
- **Windows VM os_disk must be at least 128 GB** (Windows Server images require ≥127 GB)
- **Canada East does NOT support Availability Zones** — set `zones = []` for resources deployed there
- Use `depends_on` only when implicit dependencies are insufficient
- All resources must be placed inside the existing resource group module or a new one if the request warrants separation
- When a ServiceNow RITM is referenced in the issue body, include the RITM number in the PR description
