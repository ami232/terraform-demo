# Minimal Terraform -> Azure App Service demo

This folder contains a tiny example for students: a one-file Flask app (`app.py`) and a minimal Terraform configuration that creates an App Service plan and a Linux Web App inside an existing Resource Group.

Goal: show infrastructure as code using Terraform and how to deploy app code with the Azure CLI `az webapp deploy` command. The Terraform configuration assumes the Resource Group already exists (e.g., created by an earlier workflow or by an instructor).

Quick steps (local)

1. Install prerequisites: `terraform` and `az` (Azure CLI).

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

2. Login to Azure:

```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID_OR_NAME"
```

3. Copy example variables and edit (required):

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set `resource_group_name` to the existing Resource Group name
# and change `web_app_name` to something globally unique before running `terraform apply`.
```

4. Initialize and preview:

```bash
terraform init
terraform plan
```

5. Apply to create infra (this creates resources in your subscription):

```bash
terraform apply
```

6. Package and deploy the Flask app (after `apply` completes):

```bash
# macOS / Linux (bash)
export RESOURCE_GROUP=$(terraform output -raw resource_group_name)
export APP_NAME=$(terraform output -raw web_app_name)
zip -r app.zip app.py requirements.txt
az webapp deploy --resource-group "$RESOURCE_GROUP" --name "$APP_NAME" --src-path app.zip --type zip
az webapp log tail --resource-group "$RESOURCE_GROUP" --name "$APP_NAME"
```

```powershell
# Windows (PowerShell)
$env:RESOURCE_GROUP = (terraform output -raw resource_group_name)
$env:APP_NAME = (terraform output -raw web_app_name)
Compress-Archive -Path app.py, requirements.txt -DestinationPath app.zip -Force
az webapp deploy --resource-group $env:RESOURCE_GROUP --name $env:APP_NAME --src-path app.zip --type zip
az webapp log tail --resource-group $env:RESOURCE_GROUP --name $env:APP_NAME
```

7. Using GitHub Actions

This repository includes three GitHub Actions workflows in `.github/workflows`:

- `terraform-plan.yml`: runs on pull requests targeting `main` and performs `terraform init` + `terraform plan` and prints a short plan summary for reviewers.
- `terraform-deploy.yml`: runs on pushes to `main` (and can be triggered manually). It performs `terraform plan` and `terraform apply`, then packages and deploys the Flask app using `az webapp deploy`. This job is protected by the `production` environment so an approval is required before the apply step.
- `terraform-destroy.yml`: a manual `workflow_dispatch` workflow that runs `terraform plan -destroy` and applies after an environment approval. Use this only when you intend to destroy resources.

Required repository setup for CI

- GitHub repository **secret** (add via Settings → Secrets): `AZURE_CREDENTIALS` — a single JSON credential used by the `azure/login` action. This is the recommended, supported input for `azure/login@v1` in CI.
- GitHub repository **variables** (Settings → Variables) used by the workflows: `RESOURCE_GROUP_NAME`, `WEB_APP_NAME`, `APP_SERVICE_PLAN_NAME`. The workflows expose these as `TF_VAR_*` so Terraform picks them up automatically.
- Create an environment named `production` in the repo (Settings → Environments) and require reviewers/approval to protect `apply` and `destroy` runs.

Setting Azure credentials and repository variables (recommended)

If a service principal already exists, **do NOT commit credentials to source**. Instead create or supply a single JSON credential in the `--sdk-auth` format and store it as the repository secret `AZURE_CREDENTIALS`. The `azure/login@v1` action reads this JSON via its `creds` input and authenticates cleanly in CI.

{
  "clientId": "<APP_ID>",
  "clientSecret": "<PASSWORD>",
  "subscriptionId": "<SUBSCRIPTION_ID>",
  "tenantId": "<TENANT_ID>",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}

After adding the secrets and variables the PR workflow will produce plan output for review, and merges or manual triggers to `main` will run the protected deploy/destroy workflows. When a deploy/destroy job runs it will pause and require approval in the `production` environment before the apply/destroy step executes.
