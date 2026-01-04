terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# =========================
# Resource Group
# =========================
resource "azurerm_resource_group" "rg" {
  name     = "rg-dhcp-ex2"
  location = "spaincentral"
}

# =========================
# Virtual Network
# =========================
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-dhcp"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# =========================
# Subnet
# =========================
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-dhcp"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

# =========================
# Public IP
# =========================
resource "azurerm_public_ip" "public_ip" {
  name                = "dhcp-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# =========================
# Network Security Group (SSH)
# =========================
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-dhcp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "*"
    destination_address_prefix = "*"
  }
}

# =========================
# Network Interface
# =========================
resource "azurerm_network_interface" "nic" {
  name                = "dhcp-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# =========================
# Associar NSG à NIC
# =========================
resource "azurerm_network_interface_security_group_association" "nsg_nic" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# =========================
# Linux VM (SSH, sem password)
# =========================
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-dhcp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1LvZQOCKLVNK8TZh8QbARSg5WxkMZ6Ox6W+kHHBsZPhU+J3GUoMGhIF928pw7MhYRNHNzPkGqNHpHJSmCprj9abvLcRZ92hdtLIy5lSfEntZ/1ejbiuC4v8Eo5TJFs+GG/7qCoWlCHFdPFklBf2L4onQaodgTBitoviUvXiWjytqXZijp0QzgLbjgp0YbDV+xYCuWHIqwGSLHbpp4OeTjLzokMkjs5uwxWPx11ugnCJ4xkSO8GwoPyNPFu/aH535JhYjqJO9WT7yAGxB9+zQy3ggNyWMZ3O1g29eLdOJ/IsBMppiTQLebmeYIOruGKMqlo5pvIRIlNM3HWjMQSFIhI1aDm07SnsKpef2PBi28WXbQLf2ukuliU1EC28XXSxfpYkQ5VkKFjszolt9J4gMlwU4BuXfahfZw14MMKs2zJm/xRBGWUUYpTbUbYOYXa0/Ioy43jqWQMoYGd96p9XFGuraK4GyYSLoN03ePQSfBZOOTmEW/oDrKMgEOIAVu/EfV1+Z9rPKSS0OywLmez2qoSSPmU6tUes2LVmtbvS1tIE6BkoxmcGnj3kaZ7lkYz7wh5MdMlNm+PFL5ekwBIpxKhaKDUKbx3WKCVaIfZnBJ/mAY7mBlb1gL0RM4I2dK/9IAxYvuoYSOq6qP2bRAF24TJyeTL9d2zRCU0BbNhvxdAQ== andre@AndrePC"
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

# =========================
# Output
# =========================
output "public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}
