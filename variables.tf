variable "resource_group_name" {}
variable "location" {
  default = "eastus"
}
variable "admin_username" {
  default = "azureuser"
}
variable "admin_password" {}
variable "tags" {
  default = {
    autor    = "gmtech"
    proyecto = "terraform_ansible"
  }
}