
variable "ingressVirtSvcHttpRetries" {
  default = "1"
}

locals {
  
  retries_map = {
    "ingress_virt_svc_http_retries" = "1"
  }

  retriesEnabled            = lookup(local.retries_map, "ingress_virt_svc_http_retries", 0) == "0" ? false : true
  retriesNumberOf           = lookup(local.retries_map, "ingress_virt_svc_http_retries", 0)

  #retriesEnabled            = var.ingressVirtSvcHttpRetries == "0" ? false : true
  #retriesNumberOf           = var.ingressVirtSvcHttpRetries
}


output "retriesEnabled" {
    value = local.retriesEnabled
}

output "retriesNumberOf" {
    value = local.retriesNumberOf
}




locals {
    flag_map = {
        "dns_resolves_to_iigw" = "1"
    }

    dns_resolves_to_iigw  = lookup(local.flag_map, "dns_resolves_to_iigw", "0") == "true" || lookup(local.flag_map, "dns_resolves_to_iigw", "0") == "1" ? true : false
}