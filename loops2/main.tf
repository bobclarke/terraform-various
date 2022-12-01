


locals {
  start_port      = "2100"                                                // 2100
  num_brokers     = "3"                                                   // 3
  start_port_tr   = substr(local.start_port, 0, 3)                        // 210
  end_port        = format("%s%s",local.start_port_tr,local.num_brokers)  // 2103

  start_port_int  = parseint(local.start_port,10)
  end_port_int    = parseint(local.end_port,10)

  external_broker_ports_array = range(local.start_port_int,local.end_port_int)

  elements = [
    for element in local.external_broker_ports_array:
      element
  ]

}

output "result" {
  value = local.elements
}

