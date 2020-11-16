
 resource "azurerm_log_analytics_solution" "example" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.rgaks.location
  resource_group_name   = azurerm_resource_group.rgaks.name
  workspace_resource_id = azurerm_log_analytics_workspace.logworkspace.id
  workspace_name        = azurerm_log_analytics_workspace.logworkspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }

}

resource "azurerm_subnet" "subnet" {
  name                    = var.subnet_aks_name
  resource_group_name     = "${var.rg_vnet}-${var.project}-${var.env_proj}"
  address_prefixes        = ["${var.subnet_aks}"]
  virtual_network_name    = var.nome_vnet
  depends_on              = [azurerm_resource_group.rgaks]
}


resource "azurerm_network_security_group" "nsg" {
  name                = "aksnsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rgaks.name

  security_rule {
    name                       = "Allow_all_inbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule{
    name                       = "Allow_all_outbound"
    priority                   = 1100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsgassociation" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_kubernetes_cluster" "example" {
  name                = "${var.aksname}-${var.env_proj}"
  location            = azurerm_resource_group.rgaks.location
  resource_group_name = azurerm_resource_group.rgaks.name
  dns_prefix          = var.dnsprefix
  kubernetes_version  = "1.16.13"

  default_node_pool {
    name            = "system"
    node_count      = var.nodecount
    vm_size         = var.nodesize
    vnet_subnet_id  = azurerm_subnet.subnet.id
    type            = "VirtualMachineScaleSets"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Ambiente                = "${var.tag_ambiente}"
    Aplicacao               = "${var.tag_app}"
    Responsavel             = "${var.tag_respo}"
    "Arquiteto Responsável" = "${var.tag_arquiteto}"
    Fornecedor              = "${var.tag_fornecedor}"
    Deploy                  = "Terraform"
  }

  addon_profile {
    aci_connector_linux {
      enabled = false
    }

    azure_policy {
      enabled = false
    }

    http_application_routing {
      enabled = false
    }

    kube_dashboard {
      enabled = true
    }

    oms_agent {
      enabled = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.logworkspace.id
    }
  }
}

