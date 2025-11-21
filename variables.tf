
variable "resource_group_name" {
  description = "Name of the existing Resource Group (must already exist)"
  type        = string
  default     = "BCSAI2025-DEVOPS-STUDENTS-B"
}

variable "app_service_plan_name" {
  description = "Name for the App Service Plan"
  type        = string
  default     = "demo-asp-54353454235265"
}

variable "web_app_name" {
  description = "Name for the Web App (must be globally unique)"
  type        = string
  default     = "demo-webapp-54353454235265"
}
