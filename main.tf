resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform"
  location = "westus2"
}

module "vnet" {
  source = "./modules/vnet"

  rg_name        = azurerm_resource_group.rg.name
  rg_location    = azurerm_resource_group.rg.location
  vnet_name      = var.vnet_name
  vnet_cidr      = var.vnet_cidr
  sub_vm_name    = var.sub_vm_name
  sub_vm_cidr    = var.sub_vm_cidr
  sub_ilb_name   = var.sub_ilb_name
  sub_ilb_cidr   = var.sub_ilb_cidr
  sub_db_name    = var.db_name
  sub_db_cidr    = var.sub_db_cidr
  sub_files_name = var.sub_files_name
  sub_files_cidr = var.sub_files_cidr
  pip_name       = var.pip_name
  nic_name       = var.nic_name
  nsg_name       = var.nsg_name
  nsg_rules      = var.nsg_rules

}


module "vm" {
  source = "./modules/vm"

  rg_name     = azurerm_resource_group.rg.name
  rg_location = azurerm_resource_group.rg.location
  nic_id      = module.vnet.nic_id
  vm_name     = var.vm_name
  vm_sku_size = var.vm_sku_size
  depends_on  = [module.vnet]

}

module "dns" {
  source = "./modules/dns"

  rg_name      = azurerm_resource_group.rg.name
  vnet_id      = module.vnet.vnet_id
  pv_dns_name  = var.pv_dns_name
  pv_link_name = var.pv_link_name
  depends_on   = [module.vnet]
}

module "db" {
  source = "./modules/db"

  rg_name     = azurerm_resource_group.rg.name
  rg_location = azurerm_resource_group.rg.location
  pv_dns_id   = module.dns.pv_dns_id
  sub_db_id   = module.vnet.sub_db_id
  db_name     = var.db_name
  db_sku_size = var.db_sku_size
  db_version  = var.db_version
  depends_on  = [module.vnet, module.dns]
}

# resource "azurerm_cdn_frontdoor_profile" "frontdoor" {
#   name                = "fd-terraform"
#   resource_group_name = azurerm_resource_group.rg.name
#   sku_name            = "Standard_AzureFrontDoor"

#   tags = {
#     environment = "Production"
#   }
# }