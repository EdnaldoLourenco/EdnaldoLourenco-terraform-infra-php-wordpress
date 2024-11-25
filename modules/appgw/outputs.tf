output "appgw_public_ip" {
  value = azurerm_public_ip.appgw-pip.ip_address
}
