# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.10.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform"
  location = "westus2"
}

# resource "azurerm_cdn_frontdoor_profile" "frontdoor" {
#   name                = "fd-terraform"
#   resource_group_name = azurerm_resource_group.rg.name
#   sku_name            = "Standard_AzureFrontDoor"

#   tags = {
#     environment = "Production"
#   }
# }


resource "azurerm_virtual_network" "vnet-terraform" {
  name                = "vnet-terraform"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "sub-vms" {
  name                 = "sub-vms"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-terraform.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "sub-ilb" {
  name                 = "sub-ilb"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-terraform.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "sub-db" {
  name                 = "sub-db"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-terraform.name
  address_prefixes     = ["10.0.4.0/24"]
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
  name                 = "sub-files"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-terraform.name
  address_prefixes     = ["10.0.5.0/24"]
}

resource "azurerm_public_ip" "pip-terraform" {
  name                = "pip-terraform"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "nic-terraform" {
  name                = "nic-terraform"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub-vms.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-terraform.id
  }
}

resource "azurerm_linux_virtual_machine" "vm-terraform" {
  name                = "vm-terraform"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2s"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.nic-terraform.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}


resource "azurerm_network_security_group" "nsg-vms" {
  name                = "nsg-vms"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "nsg-vms" {
  name                        = "ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg-vms.name
}

resource "azurerm_subnet_network_security_group_association" "nsg-vms" {
  subnet_id                 = azurerm_subnet.sub-vms.id
  network_security_group_id = azurerm_network_security_group.nsg-vms.id
}


resource "azurerm_network_security_group" "nsg-db" {
  name                = "nsg-db"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "nsg-db" {
  name                        = "MySQL"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg-db.name
}

resource "azurerm_subnet_network_security_group_association" "nsg-db" {
  subnet_id                 = azurerm_subnet.sub-db.id
  network_security_group_id = azurerm_network_security_group.nsg-db.id
}


resource "azurerm_private_dns_zone" "pv-dns" {
  name                = "dbterraform.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "pvlink-dns" {
  name                  = "vnet-terraform"
  private_dns_zone_name = azurerm_private_dns_zone.pv-dns.name
  virtual_network_id    = azurerm_virtual_network.vnet-terraform.id
  resource_group_name   = azurerm_resource_group.rg.name
}

resource "azurerm_mysql_flexible_server" "db-terraform" {
  name                   = "db-terraform"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  administrator_login    = "CloudUSer"
  administrator_password = "y?PF6>@gxxhsuwCLuT,"
  backup_retention_days  = 7
  delegated_subnet_id    = azurerm_subnet.sub-db.id
  private_dns_zone_id    = azurerm_private_dns_zone.pv-dns.id
  sku_name               = "B_Standard_B1ms"
  version                = "8.0.21"
  depends_on             = [azurerm_private_dns_zone_virtual_network_link.pvlink-dns]
}