
resource "azurerm_subnet" "vnethealth-subnet" {
  name                 = "vnethealth-subnet"
  resource_group_name  = azurerm_resource_group.healthdataaerg1.name
  virtual_network_name = azurerm_virtual_network.vnethealth.name
  address_prefixes     = ["10.122.3.0/24"]

  enforce_private_link_endpoint_network_policies = true

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

resource "azurerm_private_dns_zone" "healthprivatelink" {
  name                = "privatelink.azurehealthcareapis.com"
  resource_group_name = azurerm_resource_group.healthdataaerg1.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "healthprivatenetlink" {
  name                  = "healthprivatenetlink"
  resource_group_name   = azurerm_resource_group.healthdataaerg1.name
  private_dns_zone_name = azurerm_private_dns_zone.healthprivatelink.name
  virtual_network_id    = azurerm_virtual_network.vnethealth.id
}

resource "azurerm_private_dns_zone" "dicomprivatelink" {
  name                = "privatelink.dicom.azurehealthcareapis.com"
  resource_group_name = azurerm_resource_group.healthdataaerg1.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dicomprivatenetlink" {
  name                  = "dicomprivatenetlink"
  resource_group_name   = azurerm_resource_group.healthdataaerg1.name
  private_dns_zone_name = azurerm_private_dns_zone.dicomprivatelink.name
  virtual_network_id    = azurerm_virtual_network.vnethealth.id

}

resource "azurerm_private_endpoint" "health-endpoint" {
  name                = "health-endpoint"
  location            = azurerm_healthcare_workspace.healthdataservice.location
  resource_group_name = azurerm_resource_group.healthdataaerg1.name
  subnet_id           = azurerm_subnet.vnethealth-subnet.id

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.healthprivatelink.id,
                            azurerm_private_dns_zone.dicomprivatelink.id
                            ]
  }

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