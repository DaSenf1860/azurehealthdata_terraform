resource "azurerm_resource_group" "healthdataaerg1" {
  name     = "healthdataaerg"
  location = "west europe"
}

resource "azurerm_virtual_network" "vnethealth" {
  name                = "vnethealth-network"
  location            = azurerm_resource_group.healthdataaerg1.location
  resource_group_name = azurerm_resource_group.healthdataaerg1.name
  address_space       = ["10.122.0.0/20"]

}
