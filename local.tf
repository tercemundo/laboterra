# Crear directorio del proyecto
resource "local_file" "directorio_info" {
  filename = "proyecto-${random_id.proyecto_id.hex}/README.md"
  content = <<EOT
# Proyecto: ${random_pet.servidor_nombre.id}

## Información del Proyecto
- **ID único**: ${random_id.proyecto_id.hex}
- **Servidor**: ${random_pet.servidor_nombre.id}
- **Session ID**: ${random_uuid.session_id.result}
- **Regiones seleccionadas**: ${join(", ", random_shuffle.regiones_disponibles.result)}
- **Fecha de creación**: ${timestamp()}

## Configuración
Este proyecto fue generado automáticamente con Terraform.
EOT
  
  depends_on = [random_id.proyecto_id]
}

# Archivo de configuración con datos aleatorios
resource "local_file" "config_json" {
  filename = "proyecto-${random_id.proyecto_id.hex}/config.json"
  content = jsonencode({
    proyecto = {
      id        = random_id.proyecto_id.hex
      nombre    = random_pet.servidor_nombre.id
      timestamp = timestamp()
    }
    database = {
      password = random_password.db_password.result
      host     = "${random_pet.servidor_nombre.id}.database.local"
    }
    regiones = random_shuffle.regiones_disponibles.result
    session  = random_uuid.session_id.result
  })
  
  depends_on = [random_id.proyecto_id]
}

# Script de inicialización
resource "local_file" "init_script" {
  filename = "proyecto-${random_id.proyecto_id.hex}/init.sh"
  content = <<EOT
#!/bin/bash
echo "Inicializando proyecto: ${random_pet.servidor_nombre.id}"
echo "ID del proyecto: ${random_id.proyecto_id.hex}"
echo "Configurando en regiones: ${join(", ", random_shuffle.regiones_disponibles.result)}"
mkdir -p logs data backups
echo "$(date): Proyecto inicializado" > logs/startup.log
EOT
  
  file_permission = "0755"
  depends_on = [random_id.proyecto_id]
}
