# Locals para cálculos complejos
locals {
  # Timestamp formateado
  timestamp_formatted = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
  
  # Configuración base de red
  base_cidr = "10.0.0.0/16"
  subnet_cidrs = {
    for i, env in var.entornos : env => cidrsubnet(local.base_cidr, 8, i)
  }
  
  # Tags comunes
  common_tags = {
    Proyecto    = var.proyecto_nombre
    ProyectoID  = random_id.proyecto_id.hex
    Region      = var.region
    Terraform   = "true"
    Timestamp   = local.timestamp_formatted
  }
  
  # Generar configuración de load balancer
  lb_config = {
    for env, config in var.configuracion_entornos : env => {
      backend_port = var.aplicacion_config.puerto
      health_check_path = "/health"
      instances = config.replicas
      target_groups = [
        for i in range(config.replicas) : "${var.aplicacion_config.nombre}-${env}-${i}"
      ]
    }
  }
  
  # Generar contenido de inventario directamente
  inventory_content = <<EOT
# Inventario de Ansible generado por Terraform
# Proyecto: ${var.proyecto_nombre}
# ID: ${random_id.proyecto_id.hex}

[all:vars]
ansible_user=ubuntu
proyecto_nombre=${var.proyecto_nombre}
proyecto_id=${random_id.proyecto_id.hex}
aplicacion_puerto=${var.aplicacion_config.puerto}
database_tipo=${var.aplicacion_config.database.tipo}

%{ for env in var.entornos ~}
[${env}]
%{ for i in range(var.configuracion_entornos[env].replicas) ~}
${var.aplicacion_config.nombre}-${env}-${i} ansible_host=10.0.${index(var.entornos, env)}.${10 + i} subnet=${local.subnet_cidrs[env]}
%{ endfor ~}

[${env}:vars]
env_name=${env}
cpu_limit=${var.configuracion_entornos[env].cpu}
memory_limit=${var.configuracion_entornos[env].memoria}
replicas=${var.configuracion_entornos[env].replicas}
subnet_cidr=${local.subnet_cidrs[env]}

%{ endfor ~}

[database]
%{ for env in var.entornos ~}
${var.aplicacion_config.nombre}-${env}-db ansible_host=10.0.${index(var.entornos, env)}.100 subnet=${local.subnet_cidrs[env]}
%{ endfor ~}

[loadbalancer]
%{ for env in var.entornos ~}
${var.aplicacion_config.nombre}-${env}-lb ansible_host=10.0.${index(var.entornos, env)}.200 subnet=${local.subnet_cidrs[env]}
%{ endfor ~}
EOT
}

# Archivo de inventario generado directamente
resource "local_file" "ansible_inventory" {
  filename = "${var.proyecto_nombre}-${random_id.proyecto_id.hex}/inventory/hosts.ini"
  content  = local.inventory_content
}

# Archivo de configuración de red
resource "local_file" "network_config" {
  filename = "${var.proyecto_nombre}-${random_id.proyecto_id.hex}/network.json"
  content = jsonencode({
    vpc_cidr = local.base_cidr
    subnets = local.subnet_cidrs
    tags = local.common_tags
    load_balancers = local.lb_config
  })
}

# Archivo de métricas y estadísticas
resource "local_file" "metrics_config" {
  filename = "${var.proyecto_nombre}-${random_id.proyecto_id.hex}/metrics.yaml"
  content = yamlencode({
    proyecto = {
      nombre = var.proyecto_nombre
      id = random_id.proyecto_id.hex
      timestamp = local.timestamp_formatted
    }
    estadisticas = {
      total_entornos = length(var.entornos)
      total_instancias = sum([for config in var.configuracion_entornos : config.replicas])
      cpu_total = sum([for config in var.configuracion_entornos : config.cpu * config.replicas])
      entornos_prod = length([for env, config in var.configuracion_entornos : env if config.replicas > 2])
    }
    features = var.aplicacion_config.features
    base_urls = {
      for env in var.entornos : env => "https://${var.aplicacion_config.nombre}-${env}.${var.region}.example.com"
    }
  })
}
