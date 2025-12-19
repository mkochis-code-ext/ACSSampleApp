locals {
  sku_tier_lower               = lower(var.sku_tier)
  requires_v2_features         = contains(["standard_v2", "waf_v2"], local.sku_tier_lower)
  public_frontend_is_enabled   = var.enable_public_frontend || local.requires_v2_features
  private_ip_allocation_method = (local.requires_v2_features || var.private_ip_address != null) ? "Static" : "Dynamic"
}

resource "azurerm_public_ip" "appgw_pip" {
  count               = local.public_frontend_is_enabled ? 1 : 0
  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_application_gateway" "appgw" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "frontend-port-80"
    port = 80
  }

  frontend_port {
    name = "frontend-port-443"
    port = 443
  }

  frontend_ip_configuration {
    name                          = "appgw-frontend-ip-private"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = local.private_ip_allocation_method
    private_ip_address            = var.private_ip_address
  }

  dynamic "frontend_ip_configuration" {
    for_each = local.public_frontend_is_enabled ? [1] : []
    content {
      name                 = "appgw-frontend-ip-public"
      public_ip_address_id = azurerm_public_ip.appgw_pip[0].id
    }
  }

  backend_address_pool {
    name  = "acs-backend-pool"
    fqdns = var.backend_fqdns
  }

  backend_http_settings {
    name                                = "acs-backend-http-settings"
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
    probe_name                          = "acs-health-probe"
  }

  ssl_policy {
    policy_type = var.ssl_policy_type
    policy_name = var.ssl_policy_name
  }

  http_listener {
    name                           = "acs-listener-private"
    frontend_ip_configuration_name = "appgw-frontend-ip-private"
    frontend_port_name             = "frontend-port-443"
    protocol                       = "Https"
    ssl_certificate_name           = var.ssl_certificate_name != "" ? var.ssl_certificate_name : "appgw-ssl-cert"
  }

  dynamic "http_listener" {
    for_each = local.public_frontend_is_enabled ? [1] : []
    content {
      name                           = "acs-listener-public"
      frontend_ip_configuration_name = "appgw-frontend-ip-public"
      frontend_port_name             = "frontend-port-443"
      protocol                       = "Https"
      ssl_certificate_name           = var.ssl_certificate_name != "" ? var.ssl_certificate_name : "appgw-ssl-cert"
    }
  }

  request_routing_rule {
    name                       = "acs-routing-rule-private"
    rule_type                  = "Basic"
    http_listener_name         = "acs-listener-private"
    backend_address_pool_name  = "acs-backend-pool"
    backend_http_settings_name = "acs-backend-http-settings"
    priority                   = 100
  }

  dynamic "request_routing_rule" {
    for_each = local.public_frontend_is_enabled ? [1] : []
    content {
      name                       = "acs-routing-rule-public"
      rule_type                  = "Basic"
      http_listener_name         = "acs-listener-public"
      backend_address_pool_name  = "acs-backend-pool"
      backend_http_settings_name = "acs-backend-http-settings"
      priority                   = 110
    }
  }

  probe {
    name                                      = "acs-health-probe"
    protocol                                  = "Https"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    match {
      status_code = ["200-399", "401", "404"]
    }
  }

  # Self-signed certificate for demo purposes
  # In production, use a proper certificate
  dynamic "ssl_certificate" {
    for_each = var.ssl_certificate_name == "" ? [1] : []
    content {
      name     = "appgw-ssl-cert"
      data     = var.ssl_certificate_data
      password = var.ssl_certificate_password
    }
  }
}
