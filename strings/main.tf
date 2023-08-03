locals {
  // Replace a substring
  old_platform_domain = "hive.az.eu-az-nft-wal.gdpdentsu.net"
  new_platform_domain = replace("${local.old_platform_domain}", "-wal", "-data")

  // Get a substring
  env = element(split("-", local.new_platform_domain ), 2)
}

output "old_platform_domain" {
  value = local.old_platform_domain
}

output "new_platform_domain" {
  value = local.new_platform_domain
}

output "env" {
  value = local.env
}


