# Azure Verified Modules (AVM) - Terraform Infrastructure
# This project deploys Azure resources using official Azure Verified Modules

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 2.0.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstategw18ef"
    container_name       = "tfstate"
    key                  = "azure-avm.tfstate"
    use_oidc             = true
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# --- Resource Group (AVM) ---
module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "~> 0.4"

  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location

  tags = local.common_tags
}

# --- Virtual Network (AVM) ---
module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.7"

  name      = "vnet-${var.project_name}-${var.environment}"
  parent_id = module.resource_group.resource_id
  location  = var.location

  address_space = var.vnet_address_space

  subnets = {
    default = {
      name             = "snet-default"
      address_prefixes = [var.subnet_default_prefix]
    }
    private_endpoints = {
      name             = "snet-private-endpoints"
      address_prefixes = [var.subnet_pe_prefix]
    }
  }

  tags = local.common_tags
}

# --- Key Vault (AVM) ---
module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "~> 0.9"

  name                = "kv-${var.project_name}-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = var.location
  tenant_id           = var.tenant_id

  sku_name                  = "standard"
  purge_protection_enabled  = var.environment == "prod" ? true : false
  soft_delete_retention_days = 7

  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = local.common_tags

  depends_on = [module.resource_group]
}

# --- Network Security Group (AVM) ---
module "nsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "~> 0.4"

  name                = "nsg-${var.project_name}-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = var.location

  security_rules = {
    allow_https_inbound = {
      name                       = "AllowHTTPSInbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  tags = local.common_tags

  depends_on = [module.resource_group]
}

# --- Log Analytics Workspace (AVM) ---
module "log_analytics" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "~> 0.4"

  name                = "log-${var.project_name}-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = var.location

  log_analytics_workspace_retention_in_days = var.environment == "prod" ? 90 : 30

  tags = local.common_tags

  depends_on = [module.resource_group]
}
