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

# --- Canada East VNet for VM ---
module "vnet_canadaeast" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.7"

  name      = "vnet-${var.project_name}-${var.environment}-cae"
  parent_id = module.resource_group.resource_id
  location  = "canadaeast"

  address_space = ["10.0.16.0/20"]

  subnets = {
    vm = {
      name             = "snet-vm"
      address_prefixes = ["10.0.16.0/24"]
    }
  }

  tags = local.common_tags

  depends_on = [module.resource_group]
}

# --- Windows VM (AVM) - Canada East ---
module "vm_win" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "~> 0.18"

  name                = "vm-${var.project_name}-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = "canadaeast"
  os_type             = "Windows"
  sku_size            = "Standard_B2s"
  zone                = null

  encryption_at_host_enabled = false

  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  admin_username = "azureadmin"
  admin_password = var.vm_admin_password

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 128
  }

  network_interfaces = {
    primary = {
      name = "nic-vm-${var.project_name}-${var.environment}"
      ip_configurations = {
        primary = {
          name                          = "ipconfig1"
          private_ip_subnet_resource_id = module.vnet_canadaeast.subnets["vm"].resource_id
        }
      }
    }
  }

  tags = local.common_tags

  depends_on = [module.resource_group, module.vnet_canadaeast]
}

# --- Windows VM 2 (AVM) - Canada East ---
module "vm_win_2" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "~> 0.18"

  name                = "vm-${var.project_name}-${var.environment}-2"
  resource_group_name = module.resource_group.name
  location            = "canadaeast"
  os_type             = "Windows"
  sku_size            = "Standard_B2s"
  zone                = null

  encryption_at_host_enabled = false

  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  admin_username = "azureadmin"
  admin_password = var.vm_admin_password

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 128
  }

  network_interfaces = {
    primary = {
      name = "nic-vm-${var.project_name}-${var.environment}-2"
      ip_configurations = {
        primary = {
          name                          = "ipconfig1"
          private_ip_subnet_resource_id = module.vnet_canadaeast.subnets["vm"].resource_id
        }
      }
    }
  }

  tags = local.common_tags

  depends_on = [module.resource_group, module.vnet_canadaeast]
}
