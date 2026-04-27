# Azure AVM Terraform CLI

Deploy Azure resources using [Azure Verified Modules (AVM)](https://azure.github.io/Azure-Verified-Modules/) with Terraform and GitHub Actions CI/CD.

## 🏗 Resources Deployed

| Resource | AVM Module |
|----------|-----------|
| Resource Group | `Azure/avm-res-resources-resourcegroup/azurerm` |
| Virtual Network | `Azure/avm-res-network-virtualnetwork/azurerm` |
| Key Vault | `Azure/avm-res-keyvault-vault/azurerm` |
| Network Security Group | `Azure/avm-res-network-networksecuritygroup/azurerm` |

## 🚀 Getting Started

### Prerequisites

- [Terraform >= 1.9](https://developer.hashicorp.com/terraform/install)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- Azure subscription with a service principal (OIDC recommended)
- Azure Storage Account for Terraform state backend

### GitHub Secrets Required

Configure these secrets in your repository settings (**Settings → Secrets → Actions**):

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | Service principal / app registration client ID |
| `AZURE_SUBSCRIPTION_ID` | Target Azure subscription ID |
| `AZURE_TENANT_ID` | Azure AD tenant ID |

> 💡 This project uses **OIDC (Workload Identity Federation)** for authentication — no client secrets needed.

### Backend Setup

Create the Terraform state storage before first use:

```bash
az group create -n rg-terraform-state -l canadacentral
az storage account create -n stterraformstate -g rg-terraform-state -l canadacentral --sku Standard_LRS
az storage container create -n tfstate --account-name stterraformstate
```

### Local Development

```bash
# Initialize
terraform init

# Plan for dev
terraform plan -var-file="environments/dev/terraform.tfvars" \
  -var="subscription_id=YOUR_SUB_ID" \
  -var="tenant_id=YOUR_TENANT_ID"

# Apply
terraform apply -var-file="environments/dev/terraform.tfvars" \
  -var="subscription_id=YOUR_SUB_ID" \
  -var="tenant_id=YOUR_TENANT_ID"
```

## 🔄 CI/CD Workflows

| Workflow | Trigger | Description |
|----------|---------|-------------|
| **Terraform Plan** | PR to `main` | Runs plan for dev & prod, comments results on PR |
| **Terraform Apply** | Push to `main` / Manual | Applies changes to selected environment |
| **Terraform Destroy** | Manual only | Destroys resources (requires confirmation) |

## 📁 Project Structure

```
├── main.tf                    # AVM module declarations
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── locals.tf                  # Common tags & local values
├── environments/
│   ├── dev/terraform.tfvars   # Dev environment config
│   └── prod/terraform.tfvars  # Prod environment config
└── .github/workflows/
    ├── terraform-plan.yml     # PR plan workflow
    ├── terraform-apply.yml    # Apply workflow
    └── terraform-destroy.yml  # Destroy workflow
```

## 📚 References

- [Azure Verified Modules Registry](https://registry.terraform.io/namespaces/Azure)
- [AVM Documentation](https://azure.github.io/Azure-Verified-Modules/)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
