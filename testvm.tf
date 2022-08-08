# resource "azurerm_subnet" "vnethealth-appnet" {
#   name                 = "vnethealth-appnet"
#   resource_group_name  = azurerm_resource_group.healthdataaerg1.name
#   virtual_network_name = azurerm_virtual_network.vnethealth.name
#   address_prefixes     = ["10.122.1.0/24"]

# }

# resource "azurerm_public_ip" "testvm-publicip" {
#   name                = "testvm-publicip"
#   resource_group_name = azurerm_resource_group.healthdataaerg1.name
#   location            = azurerm_resource_group.healthdataaerg1.location
#   allocation_method   = "Static"
# }

# resource "azurerm_network_interface" "testvm-nic" {
#   name                = "testvm-nic"
#   location            = azurerm_resource_group.healthdataaerg1.location
#   resource_group_name = azurerm_resource_group.healthdataaerg1.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.vnethealth-appnet.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id = azurerm_public_ip.testvm-publicip.id
#   }

# }

# resource "azurerm_linux_virtual_machine" "testvm" {
#   name                = "testvm-machine"
#   resource_group_name = azurerm_resource_group.healthdataaerg1.name
#   location            = azurerm_resource_group.healthdataaerg1.location
#   size                = "Standard_D4s_v3"
#   admin_username      = "adminuser"
#   network_interface_ids = [
#     azurerm_network_interface.testvm-nic.id,
#   ]

#   admin_ssh_key {
#     username   = "adminuser"
#     public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCMTGutW9eIRN3Q5PCYNdR3BYpnqr6vp9eXZK+tZS6QLWckJQ0tVoxMSGfhw2/47YoBCY/fx2LMwl3nxXJ/fDMaPkxTTRqo+YwT0ljfMefOxdR5v1FHZB9M3tVbC6maRXaJrupk0ePSi0xZBx3+mJJ7/rpMLg1i5mivW8vD6BRI6oK+rB3eXaxhSkJe1pcA+IhbPb52dO/Z1/W/TSqc3D298LWy0Vzq9UWgy/YDQlTkyO0Mk1VjuVjd8Jukt0W/Vl10jYZvp2Npytfeq0kDgy/4CbBZQBy1MgIAfgsE8wKHTx3ekavU8YaJoaI1vF0L73GctqCX0ohzgb8q7KQX18jN"
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "canonical"
#     offer     = "0001-com-ubuntu-server-focal"
#     sku       = "20_04-lts-gen2"
#     version   = "latest"
#   }
# }

