resource "azurerm_virtual_network" "vnet-terraform" {
  name                = var.vnet_name
  address_space       = var.vnet_cidr
  location            = var.rg_location
  resource_group_name = var.rg_name
}

resource "azurerm_subnet" "sub-vms" {
  name                 = var.sub_vm_name
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet-terraform.name
  address_prefixes     = var.sub_vm_cidr
}

resource "azurerm_subnet" "sub-ilb" {
  name                 = var.sub_ilb_name
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet-terraform.name
  address_prefixes     = var.sub_ilb_cidr
}

resource "azurerm_subnet" "sub-db" {
  name                 = var.sub_db_name
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet-terraform.name
  address_prefixes     = var.sub_db_cidr
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet" "sub-files" {
  name                 = var.sub_files_name
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet-terraform.name
  address_prefixes     = var.sub_files_cidr
}

resource "azurerm_public_ip" "pip-terraform" {
  name                = var.pip_name
  resource_group_name = var.rg_name
  location            = var.rg_location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "nic-terraform" {
  name                = var.nic_name
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub-vms.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-terraform.id
  }
}


resource "azurerm_network_security_group" "nsg-terraform" {
  name                = var.nsg_name
  location            = var.rg_location
  resource_group_name = var.rg_name

  dynamic "security_rule" {
    for_each = var.nsg_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }

}
