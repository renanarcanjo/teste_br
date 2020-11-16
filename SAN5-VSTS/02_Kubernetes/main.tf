terraform {
    required_version = ">= 0.12"
    required_providers {
        azurerm = ">=2.21"
    }
}
provider "azurerm" {
  version = "~> 2.21"
  features {}
}

resource "azurerm_resource_group" "rgaks" {
  name          = "${var.rg_main}-${var.project}-${var.env_proj}"
  location      = var.location
}

resource "azurerm_container_registry" "acr" {
  name                      = var.cr_name
  location                  = azurerm_resource_group.rgaks.location
  resource_group_name       = azurerm_resource_group.rgaks.name
  sku                       = "Standard"
  admin_enabled             = false
  depends_on                = [azurerm_resource_group.rgaks]
}

resource "azurerm_log_analytics_workspace" "logworkspace" {
  name                = "${var.workspace_name}-${var.project}-${var.env_proj}"
  location            = azurerm_resource_group.rgaks.location
  resource_group_name = azurerm_resource_group.rgaks.name
  sku                 = "Free"

  tags = {
    Ambiente                = "${var.tag_ambiente}"
    Aplicacao               = "${var.tag_app}"
    Responsavel             = "${var.tag_respo}"
    "Arquiteto Responsável" = "${var.tag_arquiteto}"
    Fornecedor              = "${var.tag_fornecedor}"
    Deploy                  = "Terraform"
  }
}
