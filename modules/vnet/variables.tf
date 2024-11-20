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

variable "sub_waf_name" {
  type = string
}

variable "sub_waf_cidr" {
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
        destination_port_ranges    = list(string)
        source_address_prefix      = string
        destination_address_prefix = string
      }
    )
  )
}

variable "rg_name" {
  type = string
}

variable "rg_location" {
  type = string
}