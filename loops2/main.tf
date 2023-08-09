


locals {
  storage_acc_name = ["foo", "bar"]

  elements = [
    for element in local.storage_acc_name:
      element
  ]

}

output "result" {
  value = local.elements[0]
}

