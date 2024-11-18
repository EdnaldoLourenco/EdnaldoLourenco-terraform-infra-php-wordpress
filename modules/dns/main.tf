resource "azurerm_private_dns_zone" "pv-dns" {
  name                = var.pv_dns_name
  resource_group_name = var.rg_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "pvlink-dns" {
  name                  = var.pv_link_name
  private_dns_zone_name = azurerm_private_dns_zone.pv-dns.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = var.rg_name
}
