
locals {
  file_name = "test-file"
}


resource "null_resource" "test" {
  count = 1

  triggers = {
    issuer_sha1 = sha1(local_file.test-file.content),
    file = local.file_name
  }

  provisioner "local-exec" {
    command = "echo creating ${local.file_name}"

  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo destroying ${self.triggers.file}"
  }

  depends_on = [
    local_file.test-file,
  ]
}


resource "local_file" "test-file" {
  filename = local.file_name
  content = <<-EOF
This is a test file
EOF
}