locals {
  
  external_broker_ports_string = "2100,2101,2102" 
  external_broker_ports_array  = split(",", local.external_broker_ports_string)

  tcp_config = <<-EOF
  tcp:
    match:
%{ for entry in local.external_broker_ports_array ~}  
      - port: ${entry}
        upstreamSvcName: tcp_upstream_svc00 
        upstreamSvcPort: 9101
%{ endfor ~} 

EOF

}

output "tcp_config" {
  value = local.tcp_config
}






