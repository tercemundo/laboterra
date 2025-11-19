# Crear múltiples archivos basados en entornos (reutilizando random_id de step1)
resource "local_file" "entorno_configs" {
  for_each = var.configuracion_entornos
  
  filename = "${var.proyecto_nombre}-${random_id.proyecto_id.hex}/config-${each.key}.yaml"
  content = yamlencode({
    entorno = each.key
    configuracion = each.value
    aplicacion = var.aplicacion_config
    metadata = {
      proyecto_id = random_id.proyecto_id.hex
      proyecto_nombre = var.proyecto_nombre
      region = var.region
      backup_habilitado = var.habilitar_backup
      timestamp = timestamp()
    }
  })
}

# Archivo principal de configuración
resource "local_file" "config_principal" {
  filename = "${var.proyecto_nombre}-${random_id.proyecto_id.hex}/application.json"
  content = jsonencode({
    aplicacion = var.aplicacion_config
    infraestructura = {
      proyecto_id = random_id.proyecto_id.hex
      proyecto_nombre = var.proyecto_nombre
      region = var.region
      entornos = var.entornos
      instancias_count = var.instancias_count
      backup_habilitado = var.habilitar_backup
    }
    configuracion_entornos = var.configuracion_entornos
    generado_en = timestamp()
  })
}

# Scripts para cada entorno
resource "local_file" "scripts_deploy" {
  count = length(var.entornos)
  
  filename = "${var.proyecto_nombre}-${random_id.proyecto_id.hex}/deploy-${var.entornos[count.index]}.sh"
  content = <<EOT
#!/bin/bash
# Script de deploy para ${var.entornos[count.index]}

echo "🚀 Desplegando ${var.aplicacion_config.nombre} v${var.aplicacion_config.version}"
echo "📍 Entorno: ${var.entornos[count.index]}"
echo "🌍 Región: ${var.region}"
echo "📦 Instancias: ${var.configuracion_entornos[var.entornos[count.index]].replicas}"
echo "💾 CPU: ${var.configuracion_entornos[var.entornos[count.index]].cpu}"
echo "🧠 Memoria: ${var.configuracion_entornos[var.entornos[count.index]].memoria}"
echo "🔧 Features: ${join(", ", var.aplicacion_config.features)}"

# Simular comandos de deploy
echo "⏳ Preparando deploy..."
sleep 1
echo "📋 Configurando ${var.aplicacion_config.database.tipo} ${var.aplicacion_config.database.version}"
echo "🔌 Puerto aplicación: ${var.aplicacion_config.puerto}"
echo "🔌 Puerto database: ${var.aplicacion_config.database.puerto}"
echo "🔒 SSL habilitado: ${var.aplicacion_config.ssl_enabled}"
%{ if var.habilitar_backup ~}
echo "💾 Configurando backup automático"
%{ endif ~}
echo "✅ Deploy completado para ${var.entornos[count.index]}"
EOT
  
  file_permission = "0755"
}
