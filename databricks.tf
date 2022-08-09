
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

resource "azurerm_network_security_group" "adbhealth-nsg" {
  name                = "adbhealth-nsg"
  location            = azurerm_resource_group.healthdataaerg1.location
  resource_group_name = azurerm_resource_group.healthdataaerg1.name
}

resource "azurerm_subnet_network_security_group_association" "adbhealthpublic-nsga" {
  subnet_id                 = azurerm_subnet.adbpublic.id
  network_security_group_id = azurerm_network_security_group.adbhealth-nsg.id
}

resource "azurerm_subnet_network_security_group_association" "adbhealthprivate-nsga" {
  subnet_id                 = azurerm_subnet.adbprivate.id
  network_security_group_id = azurerm_network_security_group.adbhealth-nsg.id
}

resource "azurerm_databricks_workspace" "databricksws" {
  name                = "databricks-health"
  resource_group_name = azurerm_resource_group.healthdataaerg1.name
  location            = azurerm_resource_group.healthdataaerg1.location
  sku                 = "premium"

  custom_parameters {
    virtual_network_id = azurerm_virtual_network.vnethealth.id
    public_subnet_name = "adbpublic"
    public_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.adbhealthpublic-nsga.id

    private_subnet_name = "adbprivate"
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.adbhealthprivate-nsga.id
  }
}


data "databricks_node_type" "smallest" {
  local_disk = true
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

resource "databricks_cluster" "shared_autoscaling" {
  cluster_name            = "Shared Autoscaling"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 120
  autoscale {
    min_workers = 1
    max_workers = 10
  }
}