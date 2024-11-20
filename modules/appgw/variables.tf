variable "appgw_name" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "rg_location" {
  type = string
}

variable "appgw_pip_name" {
  type = string
}

variable "waf-name" {
  type = string
}

variable "appgw_sub_id" {
  type = string
}

variable "backend_pool_name" {
  type = string
}
variable "backend_setting_name" {
  type = string
}
variable "http_setting_name" {
  type = string
}
variable "listener_name" {
  type = string
}
variable "frontend_ip_configuration_name" {
  type = string
}
variable "frontend_port_name" {
  type = string
}

variable "request_routing_rule_name" {
  type = string
}