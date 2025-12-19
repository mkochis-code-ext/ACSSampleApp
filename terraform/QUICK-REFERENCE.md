# Quick Reference Guide

## Common Commands

### Initial Deployment

```powershell
# Login to Azure
az login
az account set --subscription "your-subscription-id"

# Navigate to dev environment
cd terraform\environments\dev

# Create config file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Deploy
terraform init
terraform plan
terraform apply
```

### Get Information

```powershell
# View all outputs
terraform output

# Get specific output
terraform output vm_name
terraform output application_gateway_public_ip

# Get sensitive output
terraform output -raw communication_service_primary_connection_string

# List resources
terraform state list

# Show specific resource
terraform state show module.acs_project.module.windows_vm.azurerm_windows_virtual_machine.vm
```

### Manage VM

```powershell
# Get resource group and VM name from Terraform
$RG = terraform output -raw resource_group_name
$VM = terraform output -raw vm_name

# Stop VM (deallocate to save costs)
az vm deallocate --resource-group $RG --name $VM

# Start VM
az vm start --resource-group $RG --name $VM

# Get VM status
az vm get-instance-view --resource-group $RG --name $VM --query instanceView.statuses[1]

# Restart VM
az vm restart --resource-group $RG --name $VM
```

### Connect to VM

**Via Azure Portal:**
1. Navigate to portal.azure.com
2. Find your resource group: `rg-pltdemo-dev-xxx`
3. Click on VM: `vm-pltdemo-dev-xxx`
4. Click "Connect" → "Bastion"
5. Enter username: `azureadmin` (or your custom)
6. Enter password from terraform.tfvars
7. Click "Connect"

**Get Connection Info:**
```powershell
terraform output vm_name
terraform output vm_admin_username
# Password is in your terraform.tfvars file
```

### Update Infrastructure

```powershell
# Modify variables in terraform.tfvars or .tf files

# See what will change
terraform plan

# Apply changes
terraform apply

# Apply with auto-approve (careful!)
terraform apply -auto-approve
```

### Troubleshooting

```powershell
# Refresh state
terraform refresh

# Validate configuration
terraform validate

# Format terraform files
terraform fmt -recursive

# Show current state
terraform show

# Check Application Gateway backend health
$RG = terraform output -raw resource_group_name
$APPGW = "appgw-pltdemo-dev-xxx"
az network application-gateway show-backend-health --name $APPGW --resource-group $RG

# View VM boot diagnostics
az vm boot-diagnostics get-boot-log --resource-group $RG --name $VM
```

### Cleanup

```powershell
# Stop VM first (optional, saves cost while deciding)
az vm deallocate --resource-group $RG --name $VM

# Destroy all resources
terraform destroy

# Destroy specific resource
terraform destroy -target=module.acs_project.module.windows_vm
```

## Important Outputs Reference

| Output | Description | How to Get |
|--------|-------------|------------|
| resource_group_name | Resource group name | `terraform output resource_group_name` |
| vm_name | Windows VM name | `terraform output vm_name` |
| vm_admin_username | VM username | `terraform output vm_admin_username` |
| vm_private_ip | VM private IP | `terraform output vm_private_ip` |
| bastion_public_ip | Bastion public IP | `terraform output bastion_public_ip` |
| application_gateway_public_ip | App Gateway public IP | `terraform output application_gateway_public_ip` |
| communication_service_id | ACS resource ID | `terraform output communication_service_id` |
| email_domain_from_sender | Email sender domain | `terraform output email_domain_from_sender` |
| communication_service_primary_connection_string | ACS connection string (sensitive) | `terraform output -raw communication_service_primary_connection_string` |

## Azure Portal Quick Links

After deployment, find your resources at:

```
Resource Group: https://portal.azure.com/#@/resource/subscriptions/{subscription-id}/resourceGroups/{rg-name}

Replace with your actual values or use:
az group show --name $(terraform output -raw resource_group_name) --query id -o tsv
```

## Configuration Files

### terraform.tfvars (Required)

```hcl
environment_prefix = "dev"
location          = "canadacentral"
data_location     = "Canada"
vm_admin_password = "YourSecureP@ssw0rd123!"
```

### Optional Overrides

```hcl
# Network settings
vnet_address_space     = ["10.0.0.0/16"]
appgw_subnet_prefix    = ["10.0.1.0/24"]
bastion_subnet_prefix  = ["10.0.2.0/24"]
vm_subnet_prefix       = ["10.0.3.0/24"]

# VM settings
vm_size           = "Standard_B2ms"
vm_admin_username = "myadmin"
image_publisher   = "MicrosoftWindowsServer"
image_offer       = "WindowsServer"
image_sku         = "2022-Datacenter"
image_version     = "latest"

# App Gateway settings
appgw_capacity = 1  # Reduce for dev
```

## Password Requirements

VM password must have:
- ✅ 12-72 characters
- ✅ Lowercase letter (a-z)
- ✅ Uppercase letter (A-Z)
- ✅ Number (0-9)
- ✅ Special character (!@#$%^&*...)
- ❌ No username in password
- ❌ No common passwords

Good examples:
- `SecureP@ssw0rd123!`
- `MyVeryStr0ng!Password`
- `Azure2024$Demo#Pass`

## Cost Management

### Stop/Start Schedule

```powershell
# Stop VM Friday evening
az vm deallocate --resource-group $RG --name $VM

# Start VM Monday morning
az vm start --resource-group $RG --name $VM
```

### Check Current Costs

```powershell
# View cost analysis
az consumption usage list --start-date 2024-12-01 --end-date 2024-12-31

# Or use Azure Portal Cost Management
https://portal.azure.com/#blade/Microsoft_Azure_CostManagement/Menu/costanalysis
```

### Cost Optimization Tips

1. **Stop VM when not in use** - Saves ~$120/month
2. **Use smaller VM size** - B-series for burstable workloads
3. **Delete unused resources** - Run `terraform destroy` when done testing
4. **Set up cost alerts** - In Azure Portal Cost Management

## Monitoring

### Check Resource Health

```powershell
$RG = terraform output -raw resource_group_name

# All resources in resource group
az resource list --resource-group $RG --output table

# Specific resource status
az vm show --resource-group $RG --name $VM --show-details
```

### View Logs

```powershell
# Application Gateway access logs
# Enable diagnostics first, then query Log Analytics

# VM activity log
az monitor activity-log list --resource-group $RG --offset 1h
```

## Common Issues & Quick Fixes

### "Invalid password" during terraform apply
- Ensure password meets Azure complexity requirements
- Check for spaces or special characters in terraform.tfvars

### "Cannot connect to VM via Bastion"
- Wait 5-10 minutes after deployment for Bastion to fully provision
- Verify VM is running: `az vm get-instance-view`
- Check password in terraform.tfvars

### "Application Gateway backend unhealthy"
- This is expected - App Gateway can't directly reach ACS without additional config
- Focus on VM connectivity for running scripts

### "Terraform state locked"
- Wait for other operations to complete
- Force unlock (careful): `terraform force-unlock <lock-id>`

## Useful Azure CLI Commands

```powershell
# List all resource groups
az group list --output table

# List all VMs
az vm list --output table

# List public IPs
az network public-ip list --resource-group $RG --output table

# Show subscription info
az account show

# List available VM sizes in region
az vm list-sizes --location canadacentral --output table

# Show all Bastion hosts
az network bastion list --output table
```

## File Locations

```
terraform/
├── environments/dev/
│   ├── terraform.tfvars          ← Your config (create from .example)
│   ├── terraform.tfvars.example  ← Template
│   └── *.tf                      ← Terraform files
├── Generate-AppGatewayCert.ps1   ← Certificate generator
├── DEPLOYMENT-GUIDE.md           ← Full deployment guide
├── UPDATE-SUMMARY.md             ← What changed
└── QUICK-REFERENCE.md            ← This file
```

## Getting Help

1. **Check logs**: Use Azure Portal to view resource activity logs
2. **Terraform docs**: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
3. **Azure docs**: https://docs.microsoft.com/en-us/azure/
4. **Review**: DEPLOYMENT-GUIDE.md for detailed troubleshooting

## Emergency Stop

If something goes wrong and costs are running:

```powershell
# Stop the VM immediately
az vm deallocate --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw vm_name)

# Or destroy everything
terraform destroy -auto-approve
```

## Backup Important Info

Before destroying infrastructure, save:
- [ ] ACS connection string
- [ ] ACS endpoint
- [ ] Email domain configuration
- [ ] Any data from the VM

```powershell
# Save all outputs to file
terraform output > outputs-backup.txt
terraform output -raw communication_service_primary_connection_string > acs-connection-string.txt
```

---

**Need more help?** See DEPLOYMENT-GUIDE.md for comprehensive instructions and troubleshooting.
