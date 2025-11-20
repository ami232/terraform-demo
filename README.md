# Terraform Azure Deployment Guide

Deploy to Azure with Terraform using manual deployment.

## Prerequisites

- Azure subscription with Contributor role
- Azure CLI and Terraform installed

```bash
# Windows (PowerShell)
choco install terraform azure-cli
# Or download from: https://terraform.io & https://aka.ms/installazurecliwindows

# macOS
brew tap hashicorp/tap
brew install hashicorp/tap/terraform azure-cli

# Linux (Ubuntu/Debian)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

## Deployment Steps

### 1. Login to Azure

```bash
az login
```

If you have multiple subscriptions:

```bash
az account list --output table
az account set --subscription "YOUR_SUBSCRIPTION_NAME"
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Validate Configuration

```bash
terraform validate
terraform fmt
```

### 4. Preview Changes

```bash
terraform plan
```

Review the planned changes carefully.

### 5. Deploy

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### 6. Get the URL

```bash
terraform output web_app_url
```

Visit the URL to see your deployed application.

## Deploying Flask App Updates

After Terraform creates the infrastructure, deploy your Flask app code:

### Get the app name

```bash
terraform output web_app_name
# Or check main.tf for the app name
```

### (Optional) Export names as environment variables

For macOS/Linux (zsh/bash):
```bash
export RESOURCE_GROUP="$(terraform output -raw resource_group_name)"
export APP_NAME="$(terraform output -raw web_app_name)"
```

For Windows PowerShell:
```powershell
$env:RESOURCE_GROUP = (terraform output -raw resource_group_name)
$env:APP_NAME = (terraform output -raw web_app_name)
```

You can then reuse these in deployment commands without hardcoding.

### Deploy with zip

```bash
# Create zip file with application code only
zip -r app.zip app.py requirements.txt

# If not already exported:
export RESOURCE_GROUP="$(terraform output -raw resource_group_name)"
export APP_NAME="$(terraform output -raw web_app_name)"

# Deploy to Azure (uses Terraform-defined startup command)
az webapp deploy \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_NAME" \
  --src-path app.zip \
  --type zip

# Watch deployment logs
az webapp log tail \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP"
```

If variables are not set, replace `$RESOURCE_GROUP` and `$APP_NAME` manually.

**Note:** Startup is handled by the `app_command_line` value in `main.tf` (`gunicorn --bind=0.0.0.0:8000 --timeout=600 app:app`). No separate startup script is needed.

### Redeploy after code changes

```bash
zip -r app.zip app.py requirements.txt
az webapp deploy \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_NAME" \
  --src-path app.zip \
  --type zip
```

## Common Commands

```bash
terraform fmt          # Format code
terraform validate     # Check syntax
terraform plan         # Preview changes
terraform apply        # Deploy changes
terraform destroy      # Remove all resources
terraform output       # Show output values
terraform show         # Show current state
```

## Making Updates

When you change your configuration:

```bash
terraform plan         # See what will change
terraform apply        # Apply the changes
```

Terraform will only modify what changed.

## Troubleshooting

**Auth errors**: Run `az login` again or check you're using the right subscription

**Name conflicts**: Web app names must be globally unique - change the name in `main.tf`

**Permissions**: Need Contributor role on the resource group

**Deploy fails**: Check logs with `az webapp log tail --name $APP_NAME`

**State locked**: Another terraform operation is running - wait or remove lock with `terraform force-unlock`

## Cleanup

Remove all deployed resources:

```bash
terraform destroy
```

Type `yes` to confirm. This will delete everything created by Terraform.
