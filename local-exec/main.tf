locals {
  kafkaGateway = "test.yaml"
}

resource "local_file" "kafkaGateway" {
  //count    = 0
  filename = local.kafkaGateway 

  content = <<-EOF
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: test-gateway
  namespace: default
spec:
  selector:
    istio: testgateay
  servers:
    - port:
        name: test 
        number: 10000
        protocol: TCP
      hosts:
        - "test"
EOF
}

resource "null_resource" "kafkaGateway" {
  count = 0

  triggers = {
    issuer_sha1 = sha1(local_file.kafkaGateway.content)
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${local.kafkaGateway} --validate=false"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f ${local.kafkaGateway}"
  }

  depends_on = [
    local_file.kafkaGateway,
  ]
}
