# Vai buscar o Resource Group já existente
data "azurerm_resource_group" "rg" {
  name = "rg-dhcp-ex2"
}

# Vai buscar a VNet já existente
data "azurerm_virtual_network" "vnet" {
  name                = "vnet-dhcp"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Vai buscar a subnet já existente
data "azurerm_subnet" "subnet" {
  name                 = "subnet-dhcp"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

# NIC do cliente (IP por DHCP)
resource "azurerm_network_interface" "client_nic" {
  name                = "client-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Máquina virtual cliente
resource "azurerm_linux_virtual_machine" "client_vm" {
  name                = "vm-client"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  size                = "Standard_B1s"

  admin_username = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.client_nic.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
