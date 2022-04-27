variable "envwhitelistmap" {
    type = "map"
    default = {
        "ips" = "[ 10.48.49.170/32  213.115.111.36/32  213.27.137.74/32  41.184.210.202/32 ]"
    }
}

locals {
   //a = substr(var.envwhitelistmap.ips, 1, length(var.envwhitelistmap.ips) - 2) 

   
   //envwhitelist = regexall("\\d+.\\d+.\\d+.\\d+/\\d+", var.envwhitelistmap.ips)
   rendered_config = templatefile("${path.module}/config/istio.aks.yaml", { ip_addrs = var.envwhitelistarry } )
}

/*
output "envwhitelist_rendered" {
    //value = local.rendered_config
    //value = local.envwhitelist
}
*/

