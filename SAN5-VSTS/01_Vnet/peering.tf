resource "azurerm_virtual_network_peering" "vnet_peering"{
  name                        = var.peering_name
  resource_group_name         = azurerm_resource_group.rgvnet.location
  virtual_network_name        = var.nome_vnet
  remote_virtual_network_id   = var.dest_vnet_id
}

