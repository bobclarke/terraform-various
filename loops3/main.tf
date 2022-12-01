locals {
  external_broker_ports_string = "2100:00,2101:01,2102:02"
  external_broker_ports_array  = split(",", local.external_broker_ports_string)

  elements = [
    for element in local.external_broker_ports_array:
      element
  ]

  values    = <<-EOF
  tcp:
    match:
      - port: 2100
        upstreamSvcName: tcp_upstream_svc00 
        upstreamSvcPort: 9091
      - port: 2101
        upstreamSvcName: tcp_upstream_svc01
        upstreamSvcPort: 9091
      - port: 2102
        upstreamSvcName: tcp_upstream_svc01
        upstreamSvcPort: 9091
EOF
}

// Print out the result
output "result" {
  value = local.elements
}