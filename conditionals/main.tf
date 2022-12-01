locals {
  is_zoned = true
  zone = "data"
}


resource "local_file" "defaultGateway" {
  filename = "defaultGateway"
  content = <<-EOF
      "General content"
%{ if local.is_zoned ~}
%{ if local.zone=="wal" ~}
      "jaeger-collector"
%{ else ~}
      "else worked"
%{ endif ~}
%{ endif ~}
EOF
}
