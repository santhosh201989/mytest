terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.51.0"
    }
  }
}



provider "azurerm" {
  subscription_id = "43fbf665-8e3e-444d-b3d1-bacb42346ff2"
  client_id       = "455a8a10-bbed-437b-8717-d68989d00acf"
  client_secret   = "MM~8Q~CzzVByYvIgUdv-j7ocDZq.G2~fwY7nob.r"
  tenant_id       = "f7d729a0-ce3b-4e6b-ae9e-c2151e555467"
  features {}
}

resource "azurerm_resource_group" "hubrg" {
  name = var.RG_name
  location = var.loc_name
}

resource "azurerm_network_security_group" "hub-mgmt-nsg" {
  name                = var.hub-mgmt-nsg
  location            = var.loc_name
  resource_group_name = var.RG_name
}

resource "azurerm_network_security_group" "hub-untrust-nsg" {
  name                = var.hub-untrust-nsg
  location            = var.loc_name
  resource_group_name = var.RG_name
}

resource "azurerm_network_security_group" "hub-trust-nsg" {
  name                = var.hub-trust-nsg
  location            = var.loc_name
  resource_group_name = var.RG_name

  security_rule {
    name                       = "deny-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "hub-vnet" {
  name                = var.hub-vnet
  location            = var.loc_name
  resource_group_name = var.RG_name
  address_space       = ["192.168.0.0/24"]
  dns_servers         = ["192.168.0.249", "192.168.0.250"]




  tags = {
    environment = "Production"
  }

}

  resource "azurerm_subnet" "subnet1" {
  name                 = "snet-si-hub-mgmt-01"
  resource_group_name  = azurerm_resource_group.hubrg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = ["192.168.0.0/27"]
}

  resource "azurerm_subnet" "subnet2" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hubrg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = ["192.168.0.128/27"]
}

  resource "azurerm_subnet" "subnet3" {
  name                 = "snet-si-hub-untrust-01"
  resource_group_name  = azurerm_resource_group.hubrg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = ["192.168.0.64/27"]
}

  resource "azurerm_subnet" "subnet4" {
  name                 = "snet-si-hub-trust-01"
  resource_group_name  = azurerm_resource_group.hubrg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = ["192.168.0.96/27"]
}

resource "azurerm_subnet_network_security_group_association" "hub-untrust-nsg-snet-association" {
  subnet_id                 = azurerm_subnet.subnet3.id
  network_security_group_id = azurerm_network_security_group.hub-untrust-nsg.id
}

resource "azurerm_subnet_network_security_group_association" "hub-trust-nsg-snet-association" {
  subnet_id                 = azurerm_subnet.subnet4.id
  network_security_group_id = azurerm_network_security_group.hub-trust-nsg.id
}

