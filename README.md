# 🧠 Repositorio: Despliegue Infraestructura en Azure con Terraform + Ansible

---

## 🎯 Objetivo del Laboratorio
Desplegar una **máquina virtual Ubuntu 24.04 en Azure**, configurarla con **Ansible para instalar Nginx**, y publicar un sitio web estático, todo bajo el enfoque de **Infraestructura como Código (IaC)** con buenas prácticas FinOps.

---

## 💡 ¿Qué aprenderás?
- Cómo definir y desplegar recursos en Azure usando **Terraform**.
- Cómo automatizar configuraciones usando **Ansible**.
- Cómo estructurar un laboratorio reproducible y económico.
- Cómo destruir la infraestructura para evitar cobros innecesarios.

---

## 🧪 Requisitos Previos

```markdown
- Cuenta activa de Azure (puede ser Free Tier)
- Azure CLI instalado y autenticado
- Terraform >= 1.6
- Ansible instalado en tu equipo o WSL
- Linux/macOS o WSL (recomendado) o Azure Cloud Shell
```

---

## 💸 Estimación de Costo
> ⚠️ Si ejecutas y destruyes la infraestructura en menos de 1 hora, el costo será menor a **$0.10 USD** usando el tamaño `Standard_B1s`.

---

## 📂 Estructura del Repositorio

```bash
terraform_ansible_nginx/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── ansible/
│   ├── inventory
│   ├── site.yml
│   └── templates/
│       └── index.html.j2
├── scripts/
│   ├── setup_ansible.sh
│   └── cleanup.sh
└── README.md
```

---

## 🧭 Orden de Ejecución Recomendado

```bash
# 1. Iniciar sesión en Azure
az login
az account set --subscription "TuSuscripción"

# 2. Desplegar Infraestructura con Terraform
cd terraform/
terraform init
terraform apply        # revisar y confirmar con 'yes'

# 3. Configurar con Ansible
cd ../ansible/
ansible-playbook site.yml -i inventory

# 4. Verificar acceso
terraform output public_ip
curl http://<IP_PUBLICA> o abre en navegador

# 5. Eliminar recursos
cd ../scripts/
./cleanup.sh
```

---

## 🔧 Terraform - `main.tf`
```hcl
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-demo"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-demo"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-demo"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id         = azurerm_public_ip.pip.id
  }
}

resource "azurerm_public_ip" "pip" {
  name                = "pip-demo"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-demo"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "osdisk"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  tags = var.tags
}
```

---

## 📦 Terraform - `variables.tf`
```hcl
variable "resource_group_name" {}
variable "location" {
  default = "eastus"
}
variable "admin_username" {
  default = "azureuser"
}
variable "admin_password" {}
variable "tags" {
  default = {
    autor    = "gmtech"
    proyecto = "terraform_ansible"
  }
}
```

---

## 📤 Terraform - `outputs.tf`
```hcl
output "public_ip" {
  value = azurerm_public_ip.pip.ip_address
}
```

---

## 🧾 Ansible - `inventory`
```ini
[web]
<REEMPLAZAR_CON_IP_PUBLICA> ansible_user=azureuser ansible_password=Password1234 ansible_connection=ssh ansible_python_interpreter=/usr/bin/python3
```

---

## 🛠 Ansible - `site.yml`
```yaml
---
- hosts: web
  become: yes
  tasks:
    - name: Instalar Nginx
      apt:
        name: nginx
        state: present
        update_cache: yes

    - name: Copiar página web personalizada
      template:
        src: templates/index.html.j2
        dest: /var/www/html/index.html

    - name: Asegurar que Nginx esté iniciado
      service:
        name: nginx
        state: started
        enabled: true
```

---

## 🌐 Plantilla HTML - `index.html.j2`
```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>¡Hola desde Ansible!</title>
</head>
<body>
  <h1>¡Sitio desplegado con Terraform y configurado con Ansible!</h1>
  <p>Instructor: Jose Garagorry</p>
</body>
</html>
```

---

## 🧰 Script - `scripts/setup_ansible.sh`
```bash
#!/bin/bash
sudo apt update
sudo apt install -y ansible sshpass
```

---

## 🗑 Script - `scripts/cleanup.sh`
```bash
#!/bin/bash
read -p "⚠️ Esto eliminará todos los recursos creados con Terraform. ¿Deseas continuar? (s/n): " confirm
if [[ "$confirm" != "s" ]]; then
  echo "❌ Cancelado."
  exit 1
fi
cd ../terraform/
terraform destroy
```

---

## 📚 Créditos y Autoría
**Jose Garagorry** — Instructor especialista en Cloud, Networking y Automatización

> Este laboratorio promueve el aprendizaje de herramientas de automatización modernas y prácticas seguras en la nube. Ideal para estudiantes, formadores y profesionales.
