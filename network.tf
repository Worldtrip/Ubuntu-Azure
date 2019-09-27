# Create virtual Network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "${var.loc}"
    resource_group_name = "${azurerm_resource_group.nsgs.name}"

    tags = {
        environment = "Ubuntu Demo"
    }
}

#Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = "${azurerm_resource_group.nsgs.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "myterraformnic" {
    name                = "myNIC"
    location            = "${var.loc}"
    resource_group_name = "${azurerm_resource_group.nsgs.name}"
    network_security_group_id = "${azurerm_network_security_group.nsgs.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
    }

    tags = {
        environment = "Ubuntu Demo"
    }
}