variable "envwhitelistmap" {
    type = "map"
    default = {
        "ips" = "[ 10.48.49.170/32  213.115.111.36/32  213.27.137.74/32  41.184.210.202/32 ]"
    }
}

locals {
   a = substr(var.envwhitelistmap.ips, 1, length(var.envwhitelistmap.ips) - 2) 
   envwhitelist = regexall("\\d+.\\d+.\\d+.\\d+/\\d+", var.envwhitelistmap.ips)
   rendered_config = templatefile("${path.module}/config/istio.aks.yaml", { ip_addrs = local.envwhitelist } )


   
}


output "envwhitelist_rendered" {
    value = local.rendered_config
    //value = local.envwhitelist
}



resource "helm_release" "istio-config" {
  count           = 1
  name            = "test-istio-config"
  chart           = "helmci01-chartmuseum/raw"
  namespace       = "default"
  wait            = true
  version         = "0.2.3"

  set {
    name          = "templates[0]"
    value         = templatefile("${path.module}/config/istio.aks.yaml", 
    { 
      enable_grafana = false
      privateIngress = false
      internal_ip    = false
      //ip_addrs       = local.internal_ip_enabled ? var.empty_array : var.envwhitelistarray 
      ip_addrs       = local.envwhitelist
    })
  }  

  //depends_on      = [helm_release.istio-operator]
}


