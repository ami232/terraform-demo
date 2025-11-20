# Configure Terraform and required providers
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Use existing resource group (not managed by Terraform)
data "azurerm_resource_group" "rg" {
  name = "RESOURCE-GROUP-NAME"
}

# Create an App Service Plan with Spot instance
resource "azurerm_service_plan" "plan" {
  name                = "ASP-NAME"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1"
  
}

# Create a Linux Web App
resource "azurerm_linux_web_app" "app" {
  name                = "APP-NAME"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = false  # Must be false for F1 (Free) tier
    
    # Python runtime for Flask application
    application_stack {
      python_version = "3.11"
    }
    
    # Startup command for Flask app with Gunicorn
    app_command_line = "gunicorn --bind=0.0.0.0:8000 --timeout=600 app:app"
  }
  
  # Application settings
  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "FLASK_APP"                      = "app.py"
    "ENVIRONMENT"                    = "production"
  }
}

# Output the Web App URL
output "web_app_url" {
  value       = "https://${azurerm_linux_web_app.app.default_hostname}"
  description = "The URL of the deployed web application"
}

# Output the Web App name
output "web_app_name" {
  value       = azurerm_linux_web_app.app.name
  description = "The name of the web application"
}

# Output the resource group name (useful for scripting)
output "resource_group_name" {
  value       = data.azurerm_resource_group.rg.name
  description = "Resource group containing the web app"
}
