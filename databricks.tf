
resource "azurerm_subnet" "adbpublic" {
  name                 = "adbpublic"
  resource_group_name  = azurerm_resource_group.healthdataaerg1.name
  virtual_network_name = azurerm_virtual_network.vnethealth.name
  address_prefixes     = ["10.122.10.0/23"]

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
                  "Microsoft.Network/virtualNetworks/subnets/join/action",
                  "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
                  "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
                ]
    }
  }
}

resource "azurerm_subnet" "adbprivate" {
  name                 = "adbprivate"
  resource_group_name  = azurerm_resource_group.healthdataaerg1.name
  virtual_network_name = azurerm_virtual_network.vnethealth.name
  address_prefixes     = ["10.122.12.0/23"]

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
                  "Microsoft.Network/virtualNetworks/subnets/join/action",
                  "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
                  "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
                ]
    }
  }
}

resource "azurerm_network_security_group" "adbpublic-nsg" {
  name                = "adbpublic-nsg"
  location            = azurerm_resource_group.healthdataaerg1.location
  resource_group_name = azurerm_resource_group.healthdataaerg1.name
}

resource "azurerm_network_security_group" "adbprivate-nsg" {
  name                = "adbprivate-nsg"
  location            = azurerm_resource_group.healthdataaerg1.location
  resource_group_name = azurerm_resource_group.healthdataaerg1.name
}

resource "azurerm_subnet_network_security_group_association" "adbpublic-nsga" {
  subnet_id                 = azurerm_subnet.adbpublic.id
  network_security_group_id = azurerm_network_security_group.adbpublic-nsg.id
}

resource "azurerm_subnet_network_security_group_association" "adbprivate-nsga" {
  subnet_id                 = azurerm_subnet.adbprivate.id
  network_security_group_id = azurerm_network_security_group.adbprivate-nsg.id
}

resource "azurerm_databricks_workspace" "databricksws" {
  name                = "databricks-health"
  resource_group_name = azurerm_resource_group.healthdataaerg1.name
  location            = azurerm_resource_group.healthdataaerg1.location
  sku                 = "premium"

  custom_parameters {
    virtual_network_id = azurerm_virtual_network.vnethealth.id
    public_subnet_name = "adbpublic"
    public_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.adbpublic-nsga.id

    private_subnet_name = "adbprivate"
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.adbprivate-nsga.id
  }
}