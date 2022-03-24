terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.98.0"
    }
  }
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "rpecor"

# prefixed workspaces to support multiple environments in the future
    workspaces {
      prefix = "net-team-infra-"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  naming = "${var.projectName}-${var.env}"
  tags = {
    project     = var.projectName
    region      = var.location
    environment = var.env
  }
}

resource "azurerm_resource_group" "net-rg" {
  name     = "${local.naming}-rg"
  location = var.location

  tags = local.tags
}

resource "azurerm_virtual_network" "net-hub" {
  name                = "${local.naming}-hub-network"
  resource_group_name = azurerm_resource_group.net-rg.name
  address_space       = ["10.0.1.0/24"]
  location            = var.location

  tags = local.tags
}

# resource "azurerm_virtual_network_peering" "peer-h2s" {
#   name                      = "${local.naming}-peer-h2s"
#   resource_group_name       = azurerm_resource_group.example.name
#   virtual_network_name      = azurerm_virtual_network.net-hub.name
#   remote_virtual_network_id = data.terraform_remote_state.dev-team-infra-np.spoke_vnet_id
# }