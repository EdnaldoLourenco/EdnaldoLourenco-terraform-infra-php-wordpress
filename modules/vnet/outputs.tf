output "vm_public_ip" {
  value = azurerm_public_ip.pip-terraform.ip_address
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet-terraform.id
}

output "nic_id" {
  value = azurerm_network_interface.nic-terraform.id
}

output "sub_db_id" {
  value = azurerm_subnet.sub-db.id
}

output "sub_waf_id" {
  value = azurerm_subnet.sub-waf.id
}