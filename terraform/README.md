# Azure Communication Service Terraform Configuration

This Terraform configuration deploys Azure Communication Service (ACS) and Azure Email Service resources.

## Structure

```
terraform/
├── environments/                    # Environment-specific configurations
│   ├── dev/
│   │   ├── main.tf                 # Dev environment main config
│   │   ├── variables.tf            # Dev environment variables
│   │   ├── outputs.tf              # Dev environment outputs
│   │   └── terraform.tfvars        # Dev environment values
│   └── prod/
│       ├── main.tf                 # Prod environment main config
│       ├── variables.tf            # Prod environment variables
│       ├── outputs.tf              # Prod environment outputs
│       └── terraform.tfvars        # Prod environment values
└── modules/                         # Reusable modules
    ├── communication-service/       # Azure Communication Service module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── email-service/               # Azure Email Service module
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Prerequisites

- Terraform >= 1.0
- Azure CLI installed and authenticated
- Appropriate Azure subscription permissions

## GitHub Actions CI/CD Pipeline Setup

This repository includes a GitHub Actions workflow that automatically deploys infrastructure changes. Follow these steps to configure it:

### 1. Create Azure Service Principal

Create a service principal for GitHub Actions authentication:

```powershell
az ad sp create-for-rbac --name "github-terraform-sp" `
  --role Contributor `
  --scopes /subscriptions/{subscription-id}
```

Save the output - you'll need the `appId`, `password`, `tenant`, and subscription ID.

### 2. Create Terraform State Storage

Create a storage account for Terraform remote state:

```powershell
# Create resource group
az group create --name <resource-group-name> --location canadacentral

# Create storage account (name must be globally unique)
az storage account create --name tfstate<unique> `
  --resource-group <resource-group-name> `
  --location canadacentral `
  --sku Standard_LRS `
  --encryption-services blob

# Create blob container
az storage container create --name tfstate `
  --account-name tfstate<unique>
```

### 3. Assign Service Principal Permissions

Grant the service principal access to the storage account:

```powershell
az role assignment create `
  --assignee <service-principal-app-id> `
  --role "Storage Blob Data Contributor" `
  --scope /subscriptions/{subscription-id}/<resource-group-name>/tfstate-rg/providers/Microsoft.Storage/storageAccounts/tfstate<unique>
```

### 4. Configure GitHub Secrets

Navigate to **Settings → Secrets and variables → Actions** and add:

**Azure Authentication:**
- `ARM_CLIENT_ID` - Service Principal Application (Client) ID
- `ARM_CLIENT_SECRET` - Service Principal Client Secret
- `ARM_SUBSCRIPTION_ID` - Azure Subscription ID
- `ARM_TENANT_ID` - Azure AD Tenant ID

**Terraform State Backend:**
- `TF_STATE_STORAGE_ACCOUNT` - Storage account name (e.g., "tfstate<unique>")
- `TF_STATE_RESOURCE_GROUP` - Resource group name (e.g., "tfstate-rg")

**Terraform Variable Secrets:**
- `DEV_VM_ADMIN_PASSWORD` - Dev VM admin password (matches `vm_admin_password`)
- `DEV_SSL_CERT_DATA` - Base64 PFX generated via `Generate-AppGatewayCert.ps1` for Dev
- `DEV_SSL_CERT_PASSWORD` - Password used when exporting the Dev certificate
- `PROD_VM_ADMIN_PASSWORD` - Prod VM admin password
- `PROD_SSL_CERT_DATA` - Base64 PFX for Prod Application Gateway
- `PROD_SSL_CERT_PASSWORD` - Password used when exporting the Prod certificate

> Run `.\terraform\Generate-AppGatewayCert.ps1` (or supply your own CA-issued PFX) and copy the Base64 output + password into the appropriate secrets. The workflow maps these secrets into Terraform through `TF_VAR_*` environment variables so plans and applies can run without committing sensitive data.

### 5. Configure GitHub Environments

Navigate to **Settings → Environments** and create:

- **dev** environment (optional: add protection rules)
- **prod** environment (recommended: add required reviewers for manual approval)

### Pipeline Behavior

- **Pull Requests:** Runs `terraform plan` and comments results on the PR
- **Push to main:** Deploys to dev, then requires approval for prod deployment
- **Manual Trigger:** Can be run via workflow_dispatch

## Usage

### Initialize Terraform

```bash
cd terraform/environments/dev
terraform init
```

### Deploy to Development Environment

```bash
cd terraform/environments/dev
terraform plan
terraform apply
```

### Deploy to Production Environment

```bash
cd terraform/environments/prod
terraform plan
terraform apply
```

### Destroy Resources

```bash
cd terraform/environments/dev
terraform destroy
```

## Modules

### communication-service

Deploys an Azure Communication Service resource.

**Inputs:**
- `name` - Name of the ACS resource
- `resource_group_name` - Resource group name
- `data_location` - Data residency location

**Outputs:**
- `id` - Resource ID
- `primary_connection_string` - Connection string (sensitive)
- `primary_key` - Access key (sensitive)

### email-service

Deploys an Azure Email Communication Service resource.

**Inputs:**
- `name` - Name of the Email Service resource
- `resource_group_name` - Resource group name
- `data_location` - Data residency location

**Outputs:**
- `id` - Resource ID
- `endpoint` - Service endpoint

## Notes

- Connection strings and keys are marked as sensitive outputs
- Customize `terraform.tfvars` files for your specific environments
- Backend state is managed remotely in Azure Storage using Azure AD authentication
- The CI/CD pipeline automatically creates `backend.tf` files during execution
- Service principal requires "Storage Blob Data Contributor" role on the state storage account
