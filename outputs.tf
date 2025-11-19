# Outputs básicos para consultar valores generados
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

# Output para verificar password (sin mostrar el valor real)
output "password_length" {
  description = "Longitud del password generado"
  value       = random_password.db_password.length
}
