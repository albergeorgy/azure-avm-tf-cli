environment        = "dev"
project_name       = "avmtfcli"
location           = "canadacentral"
vnet_address_space = ["10.0.0.0/16"]
subnet_default_prefix = "10.0.1.0/24"
subnet_pe_prefix      = "10.0.2.0/24"
subnet_appgw_prefix   = "10.0.3.0/24"

# Set these via GitHub Secrets or environment variables:
# subscription_id = "YOUR_SUBSCRIPTION_ID"
# tenant_id       = "YOUR_TENANT_ID"
