//===================================================================
// vars 
//===================================================================
variable "subscription_id" {
  default = "xyz"
}

variable "client_id" {
  default = "xyz"
}

variable "client_secret" {
  default = "xyz"
}

variable "tenant_id" {
  default = "xyz"
}

variable "admin_password" {
  default = "xyz"
}

//===================================================================
// Provider setup 
//===================================================================
provider "azurerm" {
  version = ">= 2.41.0"
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  features {
  }
}

//===================================================================
// Resource Group
//===================================================================
resource "azurerm_resource_group" "example" {
  name     = "spaniaz-dev-rg"
  location = "West Europe"
}

//===================================================================
// VNETs
//===================================================================
resource "azurerm_virtual_network" "pl-service-network" {
  name                = "pl-service-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_virtual_network" "pl-endpoint-network" {
  name                = "pl-endpoint-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

//===================================================================
// Subnets
//===================================================================
resource "azurerm_subnet" "pl-service-subnet" {
  name                 = "pl-service-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.pl-service-network.name
  address_prefixes     = ["10.0.1.0/24"]

  enforce_private_link_service_network_policies = true
}

resource "azurerm_subnet" "pl-endpoint-subnet" {
  name                 = "pl-endpoint-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.pl-endpoint-network.name
  address_prefixes     = ["10.0.1.0/24"]

  enforce_private_link_endpoint_network_policies = true
}

//===================================================================
// NSGs and NSG association
//===================================================================
resource "azurerm_network_security_group" "pl-service-nsg" {
  name                = "pl-service-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "all-ports"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "pl-service-nsg-assc" {
  subnet_id                 = azurerm_subnet.pl-service-subnet.id
  network_security_group_id = azurerm_network_security_group.pl-service-nsg.id
}

resource "azurerm_network_security_group" "pl-endpoint-nsg" {
  name                = "pl-endpoint-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "all-ports"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "pl-endpoint-nsg-assc" {
  subnet_id                 = azurerm_subnet.pl-endpoint-subnet.id
  network_security_group_id = azurerm_network_security_group.pl-endpoint-nsg.id
}

//===================================================================
// Load Balancers
//===================================================================
resource "azurerm_lb" "pl-service-lb" {
  name                = "pl-service-lb"
  sku                 = "Standard"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  frontend_ip_configuration {
    name                 = azurerm_public_ip.pl-service-lb-pip.name
    public_ip_address_id = azurerm_public_ip.pl-service-lb-pip.id
  }
}

resource "azurerm_lb" "pl-endpoint-lb" {
  name                = "pl-endpoint-lb"
  sku                 = "Standard"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  frontend_ip_configuration {
    name                 = azurerm_public_ip.pl-endpoint-lb-pip.name
    public_ip_address_id = azurerm_public_ip.pl-endpoint-lb-pip.id
  }
}

//===================================================================
// Pubic IPs for Load Balancers
//===================================================================
resource "azurerm_public_ip" "pl-service-lb-pip" {
  name                = "pl-service-lb-pip"
  sku                 = "Standard"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "pl-endpoint-lb-pip" {
  name                = "pl-endpoint-lb-pip"
  sku                 = "Standard"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
}

//===================================================================
// Backend pools and associations for Load Balancers
//===================================================================
resource "azurerm_lb_backend_address_pool" "pl-service-lb-pool" {
  resource_group_name = azurerm_resource_group.example.name
  loadbalancer_id     = azurerm_lb.pl-service-lb.id
  name                = "pl-service-lb-pool"
}

resource "azurerm_lb_backend_address_pool" "pl-endpoint-lb-pool" {
  resource_group_name = azurerm_resource_group.example.name
  loadbalancer_id     = azurerm_lb.pl-endpoint-lb.id
  name                = "pl-endpoint-lb-pool"
}

// For the service LB Associate the pool with the VM NIC
resource "azurerm_network_interface_backend_address_pool_association" "pl-service-lb-pool-assc" {
  network_interface_id    = azurerm_network_interface.pl-service-vm-nic.id
  ip_configuration_name   = "pl-service-vm-nic-config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pl-service-lb-pool.id
}

// For the endpoint LB Associate the pool with private_endpoint ip address
resource "azurerm_lb_backend_address_pool_address" "pl-service-lb-pool-addr" {
  name                    = "pl-service-lb-pool-addr"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pl-endpoint-lb-pool.id
  virtual_network_id      = azurerm_virtual_network.pl-endpoint-network.id
  ip_address              = tostring(azurerm_private_endpoint.pl-endpoint.private_service_connection.0.private_ip_address)
}


/*
resource "azurerm_network_interface_backend_address_pool_association" "pl-endpoint-lb-pool-assc" {
  network_interface_id    = azurerm_network_interface.pl-endpoint-vm-nic.id
  ip_configuration_name   = "pl-endpoint-vm-nic-config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pl-endpoint-lb-pool.id
}
*/

//===================================================================
// Load Balancer Probes
//===================================================================
resource "azurerm_lb_probe" "pl-service-lb-probe" {
  resource_group_name = azurerm_resource_group.example.name
  loadbalancer_id     = azurerm_lb.pl-service-lb.id
  name                = "ssh-running-probe"
  port                = "22"
}

resource "azurerm_lb_probe" "pl-endpoint-lb-probe" {
  resource_group_name = azurerm_resource_group.example.name
  loadbalancer_id     = azurerm_lb.pl-endpoint-lb.id
  name                = "ssh-running-probe"
  port                = "22"
}

//===================================================================
// Load Balancer Rules
//===================================================================
resource "azurerm_lb_rule" "pl-service-lb-rule" {
  resource_group_name = azurerm_resource_group.example.name
  loadbalancer_id                = azurerm_lb.pl-service-lb.id
  name                           = "pl-service-lb-rule"
  protocol                       = "Tcp"
  frontend_port                  = "22"
  backend_port                   = "22"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.pl-service-lb-pool.id
  frontend_ip_configuration_name = azurerm_public_ip.pl-service-lb-pip.name
  probe_id                       = azurerm_lb_probe.pl-service-lb-probe.id
}

resource "azurerm_lb_rule" "pl-endpoint-lb-rule" {
  resource_group_name = azurerm_resource_group.example.name
  loadbalancer_id                = azurerm_lb.pl-endpoint-lb.id
  name                           = "pl-endpoint-lb-rule"
  protocol                       = "Tcp"
  frontend_port                  = "22"
  backend_port                   = "22"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.pl-endpoint-lb-pool.id
  frontend_ip_configuration_name = azurerm_public_ip.pl-endpoint-lb-pip.name
  probe_id                       = azurerm_lb_probe.pl-endpoint-lb-probe.id
}

//===================================================================
// VMs
//===================================================================
resource "azurerm_virtual_machine" "pl-service-vm" {
  name                  = "pl-service-vm"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.pl-service-vm-nic.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "pl-service-vm-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "pl-service-vm"
    admin_username = "pluser"
    admin_password = var.admin_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_machine" "pl-endpoint-vm" {
  name                  = "pl-endpoint-vm"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.pl-endpoint-vm-nic.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "pl-endpoint-vm-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "pl-endpoint-vm"
    admin_username = "pluser"
    admin_password = var.admin_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "dev"
  }
}

//===================================================================
// NICs
//===================================================================
resource "azurerm_network_interface" "pl-service-vm-nic" {
  name                            = "pl-service-vm-nic"
  location                        = azurerm_resource_group.example.location
  resource_group_name             = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "pl-service-vm-nic-config"
    subnet_id                     = azurerm_subnet.pl-service-subnet.id
    private_ip_address_allocation = "Dynamic"
    //public_ip_address_id          = azurerm_public_ip.pl-service-vm-pip.id
  }
}

resource "azurerm_network_interface" "pl-endpoint-vm-nic" {
  name                            = "pl-endpoint-vm-nic"
  location                        = azurerm_resource_group.example.location
  resource_group_name             = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "pl-endpoint-vm-nic-config"
    subnet_id                     = azurerm_subnet.pl-endpoint-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pl-endpoint-vm-pip.id
  }
}

//===================================================================
// Pubic IPs for VM in endpoint subnet (for testing only)
//===================================================================
resource "azurerm_public_ip" "pl-endpoint-vm-pip" {
  name                = "pl-endpoint-vm-pip"
  sku                 = "Standard"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
}

//===================================================================
// PrivateLink Service
//===================================================================
resource "azurerm_private_link_service" "pl-service" {
  name                = "pl-service"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  auto_approval_subscription_ids              = [var.subscription_id]
  visibility_subscription_ids                 = [var.subscription_id]

  nat_ip_configuration {
    name      = azurerm_public_ip.pl-service-lb-pip.name
    primary   = true
    subnet_id = azurerm_subnet.pl-service-subnet.id
  }

  load_balancer_frontend_ip_configuration_ids = [
    azurerm_lb.pl-service-lb.frontend_ip_configuration.0.id,
  ]
}

//===================================================================
// PrivateEndpoint
//===================================================================
resource "azurerm_private_endpoint" "pl-endpoint" {
  name                = "pl-endpoint"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.pl-endpoint-subnet.id

  private_service_connection {
    name                           = "pl-endpoint"
    private_connection_resource_id = azurerm_private_link_service.pl-service.id
    is_manual_connection           = false
  }
}


//===================================================================
// Outputs
//===================================================================
output "pl-service-lb-pip" {
  value = azurerm_public_ip.pl-service-lb-pip.ip_address
}

output "pl-endpoint-lb-pip" {
  value = azurerm_public_ip.pl-endpoint-lb-pip.ip_address
}

output "pl-service-id" {
  value = azurerm_private_link_service.pl-service.id
}

output "pl-endpoint-ip" {
  value = azurerm_private_endpoint.pl-endpoint.private_service_connection.0.private_ip_address
}

output "pl-endpoint-nic" {
  value = azurerm_private_endpoint.pl-endpoint
}


output "pl-endpoint-test-vm" {
  value = azurerm_public_ip.pl-endpoint-vm-pip.ip_address
}



/*
resource "azurerm_private_link_service" "pl-service" {
  name                = "pl-service"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  //auto_approval_subscription_ids              = ["00000000-0000-0000-0000-000000000000"]
  //visibility_subscription_ids                 = ["00000000-0000-0000-0000-000000000000"]
  
  load_balancer_frontend_ip_configuration_ids = [azurerm_lb.pl-service-lb.frontend_ip_configuration.id]

  nat_ip_configuration {
    name                       = "primary"
    private_ip_address         = "10.5.1.17"
    private_ip_address_version = "IPv4"
    subnet_id                  = azurerm_subnet.example.id
    primary                    = true
  }
}
*/





//===================================================================
// Pubic IPs for VMs
//===================================================================
/*
resource "azurerm_public_ip" "pl-service-vm-pip" {
  name                = "pl-service-vm-pip"
  sku                 = "Standard"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
}
*/


//value = azurerm_private_endpoint.example.0.private_service_connection.0.private_ip_address


//output "pl-service-vm-pip" {
//  value = azurerm_public_ip.pl-service-vm-pip.ip_address
//}



//===================================================================
// Notes
//===================================================================
// load_balancer_frontend_ip_configuration_ids...
// A list of Frontend IP Configuration ID's from a Standard Load Balancer, 
// where traffic from the Private Link Service should be routed. 
// You can use Load Balancer Rules to direct this traffic to appropriate backend 
// pools where your applications are running.