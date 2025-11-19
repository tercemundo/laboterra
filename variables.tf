# Variable de string simple
variable "proyecto_nombre" {
  description = "Nombre base del proyecto"
  type        = string
  default     = "mi-proyecto"
}

# Variable numérica
variable "instancias_count" {
  description = "Número de instancias a crear"
  type        = number
  default     = 3
  
  validation {
    condition     = var.instancias_count >= 1 && var.instancias_count <= 10
    error_message = "El número de instancias debe estar entre 1 y 10."
  }
}

# Variable booleana
variable "habilitar_backup" {
  description = "Habilitar backup automático"
  type        = bool
  default     = true
}

# Variable de lista
variable "entornos" {
  description = "Lista de entornos disponibles"
  type        = list(string)
  default     = ["desarrollo", "testing", "produccion"]
}

# Variable de mapa
variable "configuracion_entornos" {
  description = "Configuración específica por entorno"
  type = map(object({
    cpu    = number
    memoria = string
    replicas = number
  }))
  default = {
    desarrollo = {
      cpu      = 1
      memoria  = "512Mi"
      replicas = 1
    }
    testing = {
      cpu      = 2
      memoria  = "1Gi"
      replicas = 2
    }
    produccion = {
      cpu      = 4
      memoria  = "2Gi"
      replicas = 3
    }
  }
}

# Variable de objeto complejo
variable "aplicacion_config" {
  description = "Configuración completa de la aplicación"
  type = object({
    nombre       = string
    version      = string
    puerto       = number
    ssl_enabled  = bool
    database = object({
      tipo     = string
      version  = string
      puerto   = number
    })
    features = list(string)
  })
  default = {
    nombre      = "webapp"
    version     = "1.0.0"
    puerto      = 8080
    ssl_enabled = true
    database = {
      tipo    = "postgresql"
      version = "13"
      puerto  = 5432
    }
    features = ["auth", "logging", "metrics"]
  }
}

# Variable sin valor por defecto (debe ser proporcionada)
variable "region" {
  description = "Región donde desplegar recursos"
  type        = string
  # Sin default - será solicitada o debe proporcionarse
}
