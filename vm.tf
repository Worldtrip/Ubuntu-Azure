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
    name                  = "${var.vm.server-name}"
    location              = "${var.loc}"
    resource_group_name   = "${azurerm_resource_group.nsgs.name}"
    network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
    #vm_size               = "Standard_DS1_v2"
    vm_size               = "Standard_B1ls"


    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
        #managed_disk_type = "Standard_LRS"
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
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDw9kiKt/rxHqgRid+Znynghie6kzM8tQyQGg3Ob+DwbUvPybWBJEUfBjM4q/u+sRCUjOJ5fyGDADPwdhbj2YHeF/RdnM9vHiSGET5/awAfbce6Q0Oy15gPJlXuIiw8gI/uGeNQkiLjn9QF3i+fB193lQ/KuUyKPYFdoLcbvxwY3/NSuDYUH63+TBocVhu5eJNM5tZtOiepVCnASbPyys/pjUgWPEimWSpEAQ7ANrRzbkXCjXrpoXkdkgA27KIxEJwFxj8ep40hQctVjonkyMr+/97O7PvH9KM6lbuv9CJnTfuZKvO9Gi/XD7Qb0YpqtU2NaAq5ERnRy0EldsHXXnez azureuser"
            #key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCe22IyvpC3l1/CWq8BgS78170SgI+4QZ3ZG83fQJcOSws+TXG59yn32uP30j5cQ2CRVyhMEsjuTF/0OAOt6zdRRVhNIlntycRIgy9EdKXWlcrM+UgFnIukQbPnSbaKT3sqDncBRUbzHd3lynZeWNndjFA/id0r9Gly6+PDPNtOIbLVFxraD7q8S73CcfnljqcVxCSKzSVK6skoyopryzTjnzar94L+QgV/5lURFQW900hY0ura08Z4RBUF/bYjjGAJAeG4FmOU+c03OQUjFo7JggFZqYF2iaJT5PQqchkRXrQgGoPZpmFghencdCHTCu68bhP/Xh0tTq5oDVJalEDT"
            #key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAu+JkHDSwIyMunDF+wtyR+66ClutTBX7xzUbq9yx9fc0WMeKIMTMNlu7GbPJ8B6TCrudB6RVst096SXJ3Uz220Jx7dy8I1peEEXVpn+znro9ygJAaBi5TRE6CCbX6s+FGgbvHq+T+CCh8FkB8eNs9g5Pp4kkOojl760is58ns22mhUC7+MOR8/7xtKjmO7Z89Z1aYPDUzMXax1xZ9jBV1gSfMkXWmFoqXZUdZjMcAEEfg3TbsDAdJvoaSJ/IYBAckWN6zMHmE7TLdijBDPiLBENOhc3mjsKtm/5oRs4xDMPJSx0DcC47W+AH0G2GO+/phHW3JwO1kUgMWpmRB+/emgw=="
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