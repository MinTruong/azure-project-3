provider "azurerm" {
  tenant_id       = "${var.tenant_id}"
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  features {}
}
terraform {
  backend "azurerm" {
    storage_account_name = "storage209502"
    container_name       = "mycontainer"
    key                  = "key1"
    access_key           = "Uc8SVwd2MS7OqBcC+Tr6EV0iRIi2l+K2HMfRHftXSClM/AfHhsmhw5Fi6PxeKfUKzMgSx6pdrQjP+AStwEA0rA=="
  }
}

module "network" {
  source               = "./modules/network"
  address_space        = "${var.address_space}"
  location             = "${var.location}"
  virtual_network_name = "${var.virtual_network_name}"
  application_type     = "${var.application_type}"
  resource_type        = "NET"
  resource_group       = var.resource_group_name
  address_prefix_test  = var.address_prefix_test
}

module "nsg-test" {
  source              = "./modules/networksecuritygroup"
  location            = "${var.location}"
  application_type    = "${var.application_type}"
  resource_type       = "NSG"
  resource_group      = var.resource_group_name
  subnet_id           = "${module.network.subnet_id_test}"
  address_prefix_test = "${var.address_prefix_test}"
  depends_on = [
    module.network
  ]
}
module "appservice" {
  source           = "./modules/appservice"
  location         = "${var.location}"
  application_type = var.application_type
  resource_type    = "AppService"
  resource_group   = "${var.resource_group_name}"
}
module "publicip" {
  source           = "./modules/publicip"
  location         = "${var.location}"
  application_type = "${var.application_type}"
  resource_type    = "publicip"
  resource_group   = var.resource_group_name
}
module "vmlinux" {
  source            = "./modules/vm"
  location          = "${var.location}"
  application_type  = "${var.application_type}"
  resource_type     = "VMLinux"
  resource_group    = var.resource_group_name
  admin_username    = "agent"
  subnet_id         = "${module.network.subnet_id_test}"
  public_ip_address = "${module.publicip.public_ip_address_id}"
  
}