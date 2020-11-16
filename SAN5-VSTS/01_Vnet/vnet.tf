
resource "azurerm_virtual_network" "vnet" {
  name                = var.nome_vnet
  location            = azurerm_resource_group.rgvnet.location
  resource_group_name = azurerm_resource_group.rgvnet.name
  address_space       = ["${var.add_space}"]
  dns_servers         = ["${var.dnsp}", "${var.dnss}"]

  tags = {
    Ambiente                = "${var.tag_ambiente}"
    Aplicacao               = "${var.tag_app}"
    Responsavel             = "${var.tag_respo}"
    "Arquiteto Responsável" = "${var.tag_arquiteto}"
    Fornecedor              = "${var.tag_fornecedor}"
    Deploy                  = "Terraform"
  }
}

resource "azurerm_subnet" "subnetmgm" {
  name                 = var.subnet_mgm_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rgvnet.name
  address_prefixes     = ["${var.subnet_mgm}"]

  delegation {
    name  = "mysqldelegation"
    service_delegation {
      name    = "Microsoft.Sql/managedInstances"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action", "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_route_table" "rtmgm" {
  name                          = var.rt_mgm
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rgvnet.name
  disable_bgp_route_propagation = false


  tags = {
    Ambiente                = "${var.tag_ambiente}"
    Aplicacao               = "${var.tag_app}"
    Responsavel             = "${var.tag_respo}"
    "Arquiteto Responsável" = "${var.tag_arquiteto}"
    Fornecedor              = "${var.tag_fornecedor}"
    Deploy                  = "Terraform"
  }
}

resource "azurerm_subnet_route_table_association" "example" {
  subnet_id      = azurerm_subnet.subnetmgm.id
  route_table_id = azurerm_route_table.rtmgm.id
}

resource "azurerm_network_security_group" "nsgvet" {
  name                = var.nsg_name
  location            = azurerm_resource_group.rgvnet.location
  resource_group_name = azurerm_resource_group.rgvnet.name

  security_rule {
      access                      = "Allow"
      description                 = "Allow Azure Load Balancer inbound traffic"
      destination_address_prefix  = var.subnet_mgm
      destination_port_range      = "*"
      direction                   = "Inbound"
      name                        = "Microsoft.Sql-managedInstances_UseOnly_mi-healthprobe-in-10-161-1-0-26-v9"
      priority                    = 103
      protocol                    = "*"
      source_address_prefix       = "AzureLoadBalancer"
      source_port_range           = "*"
    }

  security_rule {
      access                      = "Allow"
      description                 = "Allow MI Supportability through Corpnet ranges"
      destination_address_prefix  = var.subnet_mgm
      destination_port_range      = ""
      destination_port_ranges     = ["9000", "9003"]
      direction                   = "Inbound"
      name                        = "Microsoft.Sql-managedInstances_UseOnly_mi-corppublic-in-10-161-1-0-26-v9"
      priority                    = 102
      protocol                    = "Tcp"
      source_address_prefix       = "CorpNetPublic"
      source_port_range           = "*"
    }

  security_rule {
      access                      = "Allow"
      description                 = "Allow MI Supportability"
      destination_address_prefix  = var.subnet_mgm
      destination_port_range      = ""
      destination_port_ranges     = ["1440","9000","9003"]
      direction                   = "Inbound"
      name                        = "Microsoft.Sql-managedInstances_UseOnly_mi-corpsaw-in-10-161-1-0-26-v9"
      priority                    = 101
      protocol                    = "Tcp"
      source_address_prefix       = "CorpNetSaw"
      source_port_range           = "*"
    }

  security_rule {
      access                      = "Allow"
      description                 = "Allow MI internal inbound traffic"
      destination_address_prefix  = var.subnet_mgm
      destination_port_range      = "*"
      direction                   = "Inbound"
      name                        = "Microsoft.Sql-managedInstances_UseOnly_mi-internal-in-10-161-1-0-26-v9"
      priority                    = 104
      protocol                    = "*"
      source_address_prefix       = var.subnet_mgm
      source_port_range           = "*"
    }

  security_rule {
      access                      = "Allow"
      description                 = "Allow MI internal outbound traffic"
      destination_address_prefix  = var.subnet_mgm
      destination_port_range      = "*"
      direction                   = "Outbound"
      name                        = "Microsoft.Sql-managedInstances_UseOnly_mi-internal-out-10-161-1-0-26-v9"
      priority                    = 101
      protocol                    = "*"
      source_address_prefix       = var.subnet_mgm
      source_port_range           = "*"
    }

  security_rule {
      access                      = "Allow"
      description                 = "Allow MI provisioning Control Plane Deployment and Authentication Service"
      destination_address_prefix  = var.subnet_mgm
      destination_port_range      = ""
      destination_port_ranges     = ["1438","1440","1452","9000","9003"]
      direction                   = "Inbound"
      name                        = "Microsoft.Sql-managedInstances_UseOnly_mi-sqlmgmt-in-10-161-1-0-26-v9"
      priority                    = 100
      protocol                    = "Tcp"
      source_address_prefix       = "SqlManagement"
      source_port_range           = "*"
    }

  security_rule {
      access                      = "Allow"
      description                 = "Allow MI services outbound traffic over https"
      destination_address_prefix  = "AzureCloud"
      destination_port_range      = ""
      destination_port_ranges     = ["12000","443"]
      direction                   = "Outbound"
      name                        = "Microsoft.Sql-managedInstances_UseOnly_mi-services-out-10-161-1-0-26-v9"
      priority                    = 100
      protocol                    = "Tcp"
      source_address_prefix       = var.subnet_mgm
      source_port_range           = "*"
    }

  security_rule {
      access                      = "Allow"
      description                 = "Allow access to data"
      destination_address_prefix  = var.subnet_mgm
      destination_port_range      = "1433"
      direction                   = "Inbound"
      name                        = "allow_tds_inbound"
      priority                    = 1000
      protocol                    = "Tcp"
      source_address_prefix       = "VirtualNetwork"
      source_port_range           = "*"
    }

  security_rule {
      access                      = "Allow"
      description                 = "Allow inbound geodr traffic inside the virtual network"
      destination_address_prefix  = var.subnet_mgm
      destination_port_range      = "5022"
      direction                   = "Inbound"
      name                        = "allow_geodr_inbound"
      priority                    = 1200
      protocol                    = "Tcp"
      source_address_prefix       = "VirtualNetwork"
      source_port_range           = "*"
    }

  security_rule {
      access                      = "Allow"
      description                 = "Allow inbound redirect traffic to Managed Instance inside the virtual network"
      destination_address_prefix  = var.subnet_mgm
      destination_port_range      = "11000-11999"
      direction                   = "Inbound"
      name                        = "allow_redirect_inbound"
      priority                    = 1100
      protocol                    = "Tcp"
      source_address_prefix       = "VirtualNetwork"
      source_port_range           = "*"
    }

  security_rule {
      access                      = "Allow"
      description                 = "Allow outbound geodr traffic inside the virtual network"
      destination_address_prefix  = "VirtualNetwork"
      destination_port_range      = "5022"
      direction                   = "Outbound"
      name                        = "allow_geodr_outbound"
      priority                    = 1200
      protocol                    = "Tcp"
      source_address_prefix       = var.subnet_mgm
      source_port_range           = "*"
    }

  security_rule {
      access                      = "Allow"
      description                 = "Allow outbound linkedserver traffic inside the virtual network"
      destination_address_prefix  = "VirtualNetwork"
      destination_port_range      = "1433"
      direction                   = "Outbound"
      name                        = "allow_linkedserver_outbound"
      priority                    = 1000
      protocol                    = "Tcp"
      source_address_prefix       = var.subnet_mgm
      source_port_range           = "*"
    }

  security_rule {
      access                      = "Allow"
      description                 = "Allow outbound redirect traffic to Managed Instance inside the virtual network"
      destination_address_prefix  = "VirtualNetwork"
      destination_port_range      = "11000-11999"
      direction                   = "Outbound"
      name                        = "allow_redirect_outbound"
      priority                    = 1100
      protocol                    = "Tcp"
      source_address_prefix       = var.subnet_mgm
      source_port_range           = "*"
    }

  security_rule {
      access                      = "Deny"
      description                 = "Deny all other inbound traffic"
      destination_address_prefix  = "*"
      destination_port_range      = "*"
      direction                   = "Inbound"
      name                        = "deny_all_inbound"
      priority                    = 4096
      protocol                    = "*"
      source_address_prefix       = "*"
      source_port_range           = "*"
    }

  security_rule {
      access                      = "Deny"
      description                 = "Deny all other outbound traffic"
      destination_address_prefix  = "*"
      destination_port_range      = "*"
      direction                   = "Outbound"
      name                        = "deny_all_outbound"
      priority                    = 4096
      protocol                    = "*"
      source_address_prefix       = "*"
      source_port_range           = "*"
    }

  tags = {
    Ambiente                = "${var.tag_ambiente}"
    Aplicacao               = "${var.tag_app}"
    Responsavel             = "${var.tag_respo}"
    "Arquiteto Responsável" = "${var.tag_arquiteto}"
    Fornecedor              = "${var.tag_fornecedor}"
    Deploy                  = "Terraform"
  }  
}

resource "azurerm_subnet_network_security_group_association" "nsgassociation" {
  subnet_id                 = azurerm_subnet.subnetmgm.id
  network_security_group_id = azurerm_network_security_group.nsgvet.id
}
