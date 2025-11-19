# Recurso null para ejecutar comandos de inicialización
resource "null_resource" "setup_proyecto" {
  # Triggers determinan cuándo recrear este recurso
  triggers = {
    proyecto_id = random_id.proyecto_id.hex
    timestamp   = timestamp()
  }
  
  # Provisioner local-exec ejecuta comandos localmente
  provisioner "local-exec" {
    command = <<EOT
      echo "🚀 Ejecutando setup del proyecto..."
      chmod +x proyecto-${random_id.proyecto_id.hex}/init.sh
      cd proyecto-${random_id.proyecto_id.hex}
      ./init.sh
      echo "✅ Setup completado para ${random_pet.servidor_nombre.id}"
    EOT
  }
  
  depends_on = [local_file.init_script]
}

# Recurso null para mostrar información
resource "null_resource" "mostrar_info" {
  provisioner "local-exec" {
    command = <<EOT
      echo ""
      echo "📊 INFORMACIÓN DEL PROYECTO:"
      echo "=========================="
      echo "🆔 ID: ${random_id.proyecto_id.hex}"
      echo "🏷️  Nombre: ${random_pet.servidor_nombre.id}"
      echo "🔐 Password generado: ${length(random_password.db_password.result)} caracteres"
      echo "🌍 Regiones: ${join(", ", random_shuffle.regiones_disponibles.result)}"
      echo "📁 Directorio: proyecto-${random_id.proyecto_id.hex}/"
      echo ""
    EOT
  }
  
  depends_on = [null_resource.setup_proyecto]
}
