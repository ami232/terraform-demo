terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Simple example: use an existing resource group (created elsewhere) and
# create an App Service plan and a Linux Web App in that RG.
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_service_plan" "plan" {
  name                = var.app_service_plan_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "app" {
  name                = var.web_app_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = false
    application_stack {
      python_version = "3.11"
    }
    app_command_line = "gunicorn --bind=0.0.0.0:8000 app:app"
  }

  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "FLASK_APP"                      = "app.py"
  }
}

output "web_app_url" {
  value       = "https://${azurerm_linux_web_app.app.default_hostname}"
  description = "URL of the deployed web app"
}

output "web_app_name" {
  value       = azurerm_linux_web_app.app.name
  description = "Name of the web app"
}

output "resource_group_name" {
  value       = data.azurerm_resource_group.rg.name
  description = "Resource group name (existing)"
}
