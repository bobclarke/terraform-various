  
  
locals{
  default_namespace = "shared01-int-g1ds"
  
  namespace_override = "0"
  namespace = local.namespace_override == "0" ? local.default_namespace : local.namespace_override
}

output "namespace" {
  value = local.namespace
}





  
  

