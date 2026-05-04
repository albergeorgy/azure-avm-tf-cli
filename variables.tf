variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "avmtfcli"
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be 'dev' or 'prod'."
  }
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "canadacentral"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_default_prefix" {
  description = "Address prefix for the default subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_pe_prefix" {
  description = "Address prefix for the private endpoints subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "vm_admin_password" {
  description = "Admin password for the Windows VM"
  type        = string
  sensitive   = true
}

variable "vm_name" {
  description = "Name for the Windows VM resource"
  type        = string
  default     = "test0001"
}
