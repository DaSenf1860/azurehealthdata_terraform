resource "azurerm_resource_group" "healthdataaerg1" {
  name     = "healthdataaerg"
  location = "west europe"
}

resource "azurerm_network_security_group" "nsghealth" {
  name                = "nsghealth-security-group"
  location            = azurerm_resource_group.healthdataaerg1.location
  resource_group_name = azurerm_resource_group.healthdataaerg1.name
}

resource "azurerm_virtual_network" "vnethealth" {
  name                = "vnethealth-network"
  location            = azurerm_resource_group.healthdataaerg1.location
  resource_group_name = azurerm_resource_group.healthdataaerg1.name
  address_space       = ["10.122.0.0/22"]
  dns_servers         = ["10.122.0.4", "10.122.0.5"]


  tags = {
    environment = "Dev"
  }
}

resource "azurerm_subnet" "vnethealth-subnet" {
  name                 = "vnethealth-subnet"
  resource_group_name  = azurerm_resource_group.healthdataaerg1.name
  virtual_network_name = azurerm_virtual_network.vnethealth.name
  address_prefixes     = ["10.122.3.0/24"]

}

resource "azurerm_healthcare_workspace" "healthdataservice" {
  name                = "healthdataae"
  resource_group_name = azurerm_resource_group.healthdataaerg1.name
  location            = azurerm_resource_group.healthdataaerg1.location

}

resource "azurerm_healthcare_dicom_service" "dicomservice" {
  name         = "dicomae"
  workspace_id = azurerm_healthcare_workspace.healthdataservice.id
  location     = azurerm_healthcare_workspace.healthdataservice.location

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "None"
  }

  public_network_access_enabled = false

}

resource "azurerm_private_endpoint" "health-endpoint" {
  name                = "health-endpoint"
  location            = azurerm_healthcare_workspace.healthdataservice.location
  resource_group_name = azurerm_resource_group.healthdataaerg1.name
  subnet_id           = azurerm_subnet.vnethealth-subnet.id

  private_service_connection {
    name                           = "health-privateserviceconnection"
    private_connection_resource_id = azurerm_healthcare_workspace.healthdataservice.id
    is_manual_connection           = false

    subresource_names = ["healthcareworkspace"]
  }
}

data "azurerm_client_config" "myself" {
}

resource "azurerm_role_assignment" "dicomaccess" {
  scope                = azurerm_healthcare_dicom_service.dicomservice.id
  role_definition_name = "DICOM Data Owner"
  principal_id         = data.azurerm_client_config.myself.object_id

}