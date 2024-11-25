resource "azurerm_public_ip" "appgw-pip" {
  name                = var.appgw_pip_name
  resource_group_name = var.rg_name
  location            = var.rg_location
  allocation_method   = "Static"
}
resource "azurerm_web_application_firewall_policy" "waf-policy" {
  name                = var.waf-name
  resource_group_name = var.rg_name
  location            = var.rg_location

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {

    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}


resource "azurerm_application_gateway" "appgw-terraform" {
  name                              = var.appgw_name
  resource_group_name               = var.rg_name
  location                          = var.rg_location
  force_firewall_policy_association = true
  firewall_policy_id                = azurerm_web_application_firewall_policy.waf-policy.id

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-configuration"
    subnet_id = var.appgw_sub_id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw-pip.id
  }

  backend_address_pool {
    name = var.backend_pool_name
  }

  backend_http_settings {
    name                  = var.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = var.listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = var.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = var.listener_name
    backend_address_pool_name  = var.backend_pool_name
    backend_http_settings_name = var.http_setting_name
  }
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "appgw_backend" {
  network_interface_id    = var.nic_id
  ip_configuration_name   = "internal"
  backend_address_pool_id = tolist(azurerm_application_gateway.appgw-terraform.backend_address_pool).0.id
}