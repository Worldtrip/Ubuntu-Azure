# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.nsgs.name}"
    }
    
    byte_length = 8
}
# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = "${azurerm_resource_group.nsgs.name}"
    location                    = "${var.loc}"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform Demo"
    }
}
resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              = "${var.loc}"
    resource_group_name   = "${azurerm_resource_group.nsgs.name}"
    network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "${var.vm.server-name}"
        admin_username = "azureuser"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAgGoPlW40iMimrPYPBihJTnqt7WgV0KzaPDWwrZeVp+Lbuhd7biM4RAQOuIFErQpMP7YCNME+rBQrHcPqd8SIiUZACaenE1Br5xpMckTnLI3JRGr5pBL6OuQS5y20LDSMuOwIpSqTj43ptCnf6hHpHbrKfnJgp8g4awwUQY3sT8tQ4JpWMbSsmdilfSihOSezUifk5Rf77PzAKelVDBcxQZE6kyw5oX5ubQ4cLHy3w6+th6BMPAhFuCszkakVLbRFUNWVf7CSu8p5dyL3u9xQwmxOeSM3YkLep10i5O7JEeH5jq4LGqJwBsdd+E7zvDVrxvtQ3GWE3A02PS+nNiCHgQ=="
        }
    }
    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

    tags = {
        environment = "Ubuntu Demo"
    }
}