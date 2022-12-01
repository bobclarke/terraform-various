  
locals {
    flag_map = {
        "dns_resolves_to_iigw" = "1"
    }

    dns_resolves_to_iigw  = lookup(local.flag_map, "dns_resolves_to_iigw", "0") == "true" || lookup(local.flag_map, "dns_resolves_to_iigw", "0") == "1" ? true : false
}

resource "null_resource" "test" {
    count = local.dns_resolves_to_iigw ? 1 : 0

    provisioner "local-exec" {
        command = "echo test"
      
    }  
}

data "kubernetes_service" "ingress" {
    count = local.dns_resolves_to_iigw ? 1 : 0
    metadata {
        name      = "nginx-ingress-controller"
        namespace = "ingress"
    }
    //depends_on  = [null_resource.test]
}

provider "kubernetes" {
    config_path    = "~/.kube/config"
    config_context = "eu-az-int-wal-admin"
}

