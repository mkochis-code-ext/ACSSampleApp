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
- Use remote state storage for team collaboration
