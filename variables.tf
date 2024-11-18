variable "vnet_name" {
  type = string
}

variable "vnet_cidr" {
  type = list(string)
}

variable "sub_vm_name" {
  type = string
}

variable "sub_vm_cidr" {
  type = list(string)
}

variable "sub_ilb_name" {
  type = string
}

variable "sub_ilb_cidr" {
  type = list(string)
}

variable "sub_db_name" {
  type = string
}

variable "sub_db_cidr" {
  type = list(string)
}

variable "sub_files_name" {
  type = string
}

variable "sub_files_cidr" {
  type = list(string)
}

variable "pip_name" {
  type = string
}

variable "nic_name" {
  type = string
}

variable "nsg_name" {
  type = string
}

variable "nsg_rules" {
  type = list(object
    (
      {
        name                       = string
        priority                   = number
        direction                  = string
        access                     = string
        protocol                   = string
        source_port_range          = string
        destination_port_range     = string
        source_address_prefix      = string
        destination_address_prefix = string
      }
    )
  )
}

variable "vm_name" {
  type = string
}
variable "vm_sku_size" {
  type = string
}

variable "pv_dns_name" {
  type = string
}
variable "pv_link_name" {
  type = string
}

variable "db_name" {
  type = string
}
variable "db_sku_size" {
  type = string
}

variable "db_version" {
  type = string
}

