# Outputs básicos (actualizados del step 1)
output "proyecto_id" {
  description = "ID único del proyecto"
  value       = random_id.proyecto_id.hex
}

output "servidor_nombre" {
  description = "Nombre aleatorio del servidor"
  value       = random_pet.servidor_nombre.id
}

output "regiones_seleccionadas" {
  description = "Regiones seleccionadas aleatoriamente"
  value       = random_shuffle.regiones_disponibles.result
}

output "password_length" {
  description = "Longitud del password generado"
  value       = random_password.db_password.length
}

# Outputs avanzados con variables
output "proyecto_info" {
  description = "Información completa del proyecto"
  value = {
    id             = random_id.proyecto_id.hex
    nombre         = var.proyecto_nombre
    region         = var.region
    directorio     = "${var.proyecto_nombre}-${random_id.proyecto_id.hex}"
    backup_enabled = var.habilitar_backup
    created_at     = timestamp()
  }
}

# Output de lista de entornos
output "entornos_disponibles" {
  description = "Lista de todos los entornos configurados"
  value       = var.entornos
}

# Output de configuración por entorno
output "configuracion_entornos" {
  description = "Configuración detallada de cada entorno"
  value       = var.configuracion_entornos
}

# Output de aplicación
output "aplicacion_details" {
  description = "Detalles de la aplicación"
  value = {
    nombre     = var.aplicacion_config.nombre
    version    = var.aplicacion_config.version
    endpoint   = "https://${var.aplicacion_config.nombre}.${var.region}.example.com:${var.aplicacion_config.puerto}"
    database   = var.aplicacion_config.database
    features   = var.aplicacion_config.features
    ssl_enabled = var.aplicacion_config.ssl_enabled
  }
}

# Output sensible (no se muestra por defecto)
output "configuracion_completa" {
  description = "Configuración completa del sistema"
  sensitive   = true
  value = {
    proyecto    = var.proyecto_nombre
    id          = random_id.proyecto_id.hex
    region      = var.region
    entornos    = var.configuracion_entornos
    aplicacion  = var.aplicacion_config
    archivos_generados = [
      for env in var.entornos : "${var.proyecto_nombre}-${random_id.proyecto_id.hex}/config-${env}.yaml"
    ]
  }
}

# Output con funciones aplicadas
output "estadisticas" {
  description = "Estadísticas del proyecto"
  value = {
    total_entornos = length(var.entornos)
    total_features = length(var.aplicacion_config.features)
    cpu_total = sum([
      for env, config in var.configuracion_entornos : config.cpu * config.replicas
    ])
    entornos_alta_disponibilidad = [
      for env, config in var.configuracion_entornos : env
      if config.replicas > 1
    ]
    features_formateadas = join(", ", var.aplicacion_config.features)
    proyecto_uppercase = upper(var.proyecto_nombre)
    region_formatted = title(replace(var.region, "-", " "))
  }
}

# Output de URLs generadas
output "endpoints" {
  description = "Endpoints generados para cada entorno"
  value = {
    for env in var.entornos : env => {
      app_url = "https://${var.aplicacion_config.nombre}-${env}.${var.region}.example.com:${var.aplicacion_config.puerto}"
      db_url  = "${var.aplicacion_config.database.tipo}://${var.aplicacion_config.nombre}-${env}-db.${var.region}.example.com:${var.aplicacion_config.database.puerto}"
      admin_url = "https://admin-${var.aplicacion_config.nombre}-${env}.${var.region}.example.com"
    }
  }
}
