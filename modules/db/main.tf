resource "azurerm_mysql_flexible_server" "db-terraform" {
  name                   = var.db_name
  resource_group_name    = var.rg_name
  location               = var.rg_location
  administrator_login    = "CloudUSer"
  administrator_password = var.db-password
  backup_retention_days  = 7
  delegated_subnet_id    = var.sub_db_id
  private_dns_zone_id    = var.pv_dns_id
  sku_name               = var.db_sku_size
  version                = var.db_version
}