resource "azurerm_subnet" "vnethealth-appnet" {
  name                 = "vnethealth-appnet"
  resource_group_name  = azurerm_resource_group.healthdataaerg1.name
  virtual_network_name = azurerm_virtual_network.vnethealth.name
  address_prefixes     = ["10.122.1.0/24"]

}

resource "azurerm_public_ip" "testvm-publicip" {
  name                = "testvm-publicip"
  resource_group_name = azurerm_resource_group.healthdataaerg1.name
  location            = azurerm_resource_group.healthdataaerg1.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "testvm-nic" {
  name                = "testvm-nic"
  location            = azurerm_resource_group.healthdataaerg1.location
  resource_group_name = azurerm_resource_group.healthdataaerg1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vnethealth-appnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.testvm-publicip.id
  }

}

resource "azurerm_windows_virtual_machine" "testvm" {
  name                = "testvm-machine"
  resource_group_name = azurerm_resource_group.healthdataaerg1.name
  location            = azurerm_resource_group.healthdataaerg1.location
  size                = "Standard_D4s_v3"
  admin_username      = "adminuser"
  admin_password = ".."
  network_interface_ids = [
    azurerm_network_interface.testvm-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}

