locals {
  dns_ttl                                     = "300"
  azure_location                              = "westeurope"
  cache_enabled                               = "false"
  platform_domain                             = "spanwaf.dentsu.app"
  frontend_name                               = "wildcard-${replace(local.platform_domain, ".", "-")}"
  backend_pools_send_receive_timeout_seconds  = "30"
  enabled                                     = 1
  resource_group_name                         = "spanwaf-dev-rg"
  name                                        = "spanwaf"
}

//===================================================================
// AFD
//===================================================================
resource "azurerm_frontdoor" "fd" {
  count                                        = local.enabled ? 1 : 0
  name                                         = local.name
  resource_group_name                          = local.resource_group_name
  enforce_backend_pools_certificate_name_check = false
  backend_pools_send_receive_timeout_seconds   = local.backend_pools_send_receive_timeout_seconds

  frontend_endpoint {
    name                              = local.name
    host_name                         = "${local.name}.azurefd.net"
    custom_https_provisioning_enabled = false
  }

  routing_rule {
    name               = replace(local.platform_domain, ".", "-")
    accepted_protocols = ["Http"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = [local.frontend_name]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = replace(local.platform_domain, ".", "-")
      cache_enabled       = local.cache_enabled
    }
  }

  backend_pool {
    name = replace(local.platform_domain, ".", "-")
    backend {
      enabled     = "true"
      host_header = ""
      address     = "10.1.1.10"
      http_port   = 80
      //https_port  = 443
    }

    load_balancing_name = "http-lb"
    health_probe_name   = "http-probe"
  }


  // Backend Pool Load Balancing
  backend_pool_load_balancing {
    name                            = "http-lb"
    sample_size                     = "4"
    successful_samples_required     = "2"
    additional_latency_milliseconds = "0"
  }

  // Backend Pool Health Probe
  backend_pool_health_probe {
    name                = "http-probe"
    path                = "/"
    protocol            = "Http"
    interval_in_seconds = "255"
  }

  lifecycle {
    ignore_changes = [
      location,
    ]
  }

  depends_on = [
    azurerm_dns_cname_record.dns_record_frontdoor,
    azurerm_dns_cname_record.dns_record_frontdoor_add,
  ]
}

// Generate the azure records for the environments
resource "azurerm_dns_cname_record" "dns_record_frontdoor" {
  count               = local.enabled ? 1 : 0
  name                = "*"
  zone_name           = local.platform_domain
  resource_group_name = local.dns_resource_group
  ttl                 = local.dns_ttl
  record              = "${local.name}.azurefd.net"
}


