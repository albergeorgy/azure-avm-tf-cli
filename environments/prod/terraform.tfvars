environment           = "prod"
project_name          = "avmtfcli"
location              = "canadacentral"
vnet_address_space    = ["10.1.0.0/16"]
subnet_default_prefix = "10.1.1.0/24"
subnet_pe_prefix      = "10.1.2.0/24"
subnet_vm_prefix      = "10.1.3.0/24"
vm_tt222222_name      = "tt222222"

# Set these via GitHub Secrets or environment variables:
# subscription_id = "YOUR_SUBSCRIPTION_ID"
# tenant_id       = "YOUR_TENANT_ID"
