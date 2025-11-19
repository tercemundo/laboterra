# Generar ID único para el proyecto
resource "random_id" "proyecto_id" {
  byte_length = 8
}

# Generar password seguro
resource "random_password" "db_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

# Generar nombre de pet aleatorio
resource "random_pet" "servidor_nombre" {
  length    = 2
  separator = "-"
  prefix    = "servidor"
}

# Generar UUID
resource "random_uuid" "session_id" {}

# Seleccionar elemento aleatorio de una lista
resource "random_shuffle" "regiones_disponibles" {
  input = ["us-east-1", "us-west-2", "eu-west-1", "ap-southeast-1"]
  result_count = 2
}
