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

resource "azurerm_resource_group" "rgvnet" {
  name     = "${var.rg_vnet}-${var.project}-${var.env_proj}"
  location = var.location

  tags = {
    Ambiente                = "${var.tag_ambiente}"
    Aplicacao               = "${var.tag_app}"
    Responsavel             = "${var.tag_respo}"
    "Arquiteto Responsável" = "${var.tag_arquiteto}"
    Fornecedor              = "${var.tag_fornecedor}"
    Deploy                  = "Terraform"
  }
}

resource "azurerm_log_analytics_workspace" "logworkspace" {
  name                = "${var.workspace_name}-${var.rg_vnet}"
  location            = azurerm_resource_group.rgvnet.location
  resource_group_name = azurerm_resource_group.rgvnet.name
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
