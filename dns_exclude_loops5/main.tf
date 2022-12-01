variable "additional_domains" {
    type = "list"
    default = ["wal.stg.az.eu.mediaecosystem.io", "stg.dentsuconnect.com" ]
}

variable "test_datasource" {
    type = "map"
    default = {
        "domains_to_exclude_dns" = [""]
    }
}

locals {
    additional_domains              = compact(distinct(split(",", join(",", var.additional_domains))))
    domains_to_exclude_dns          = lookup(var.test_datasource, "domains_to_exclude_dns", ["ignore"])
    additional_domains_needing_dns  = flatten([
        for additional_domain in local.additional_domains : [
            for domain_to_exclude_dns in local.domains_to_exclude_dns : additional_domain if additional_domain != domain_to_exclude_dns
        ]
    ])
}

output "additional_domains" {
    value = local.additional_domains
}

output "domains_to_exclude_dns" {
    value = local.domains_to_exclude_dns
}

output "additional_domains_needing_dns" {
  value = local.additional_domains_needing_dns
}




