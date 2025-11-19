# Valores específicos para este entorno
proyecto_nombre    = "terraform-advanced"
instancias_count   = 5
habilitar_backup   = true
region            = "us-west-2"

# Lista personalizada
entornos = ["dev", "stage", "prod", "demo"]

# Configuración personalizada
configuracion_entornos = {
  dev = {
    cpu      = 1
    memoria  = "256Mi"
    replicas = 1
  }
  stage = {
    cpu      = 2
    memoria  = "512Mi"
    replicas = 2
  }
  prod = {
    cpu      = 8
    memoria  = "4Gi"
    replicas = 5
  }
  demo = {
    cpu      = 1
    memoria  = "128Mi"
    replicas = 1
  }
}

# Configuración de aplicación personalizada
aplicacion_config = {
  nombre      = "ecommerce-api"
  version     = "2.1.0"
  puerto      = 3000
  ssl_enabled = true
  database = {
    tipo    = "mysql"
    version = "8.0"
    puerto  = 3306
  }
  features = ["auth", "payments", "inventory", "analytics", "logging"]
}
