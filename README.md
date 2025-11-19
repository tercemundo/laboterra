

## Orden de Ejecución

Cuando ejecutás `terraform apply`, Terraform analiza las dependencias entre recursos y los crea en el siguiente orden:[1]

### 1. Recursos Aleatorios (random.tf)

**random_id.proyecto_id**: Genera un ID único hexadecimal de 8 bytes (16 caracteres) que se usa como identificador del proyecto.[1]

**random_password.db_password**: Crea una contraseña segura de 16 caracteres con mayúsculas, minúsculas, números y caracteres especiales para la base de datos.[1]

**random_pet.servidor_nombre**: Genera un nombre aleatorio tipo "servidor-adjective-animal" con dos palabras separadas por guiones (ej: "servidor-happy-dolphin").[1]

**random_uuid.session_id**: Crea un UUID único para identificar la sesión.[1]

**random_shuffle.regiones_disponibles**: Selecciona 2 regiones al azar de una lista de 4 opciones (us-east-1, us-west-2, eu-west-1, ap-southeast-1).[1]

### 2. Archivos Locales (local.tf)

**local_file.directorio_info**: Crea un archivo `README.md` dentro del directorio `proyecto-{ID}/` con toda la información del proyecto (ID, nombre del servidor, session ID, regiones y timestamp).[1]

**local_file.config_json**: Genera un archivo `config.json` con la configuración del proyecto en formato JSON, incluyendo credenciales de base de datos, regiones y datos del proyecto.[1]

**local_file.init_script**: Crea un script bash ejecutable `init.sh` que inicializa la estructura de carpetas (logs, data, backups) y genera un log de inicio.[1]

### 3. Recursos de Ejecución (null.tf)

**null_resource.setup_proyecto**: Ejecuta el script `init.sh` dándole permisos de ejecución, creando las carpetas necesarias y registrando el inicio en el log.[1]

**null_resource.mostrar_info**: Muestra en la terminal un resumen visual con emojis del proyecto creado (ID, nombre, longitud del password, regiones y directorio).[1]

### 4. Outputs (outputs.tf)

Al finalizar, Terraform muestra en pantalla los valores generados: proyecto_id, servidor_nombre, regiones_seleccionadas y password_length (sin revelar la contraseña completa por seguridad).[1]

## Resultado Final

Después de ejecutar `terraform apply`, tendrás un directorio llamado `proyecto-{ID}/` con la siguiente estructura:[1]

- **README.md**: Documentación del proyecto
- **config.json**: Configuración en JSON
- **init.sh**: Script de inicialización
- **logs/**: Carpeta con startup.log
- **data/**: Carpeta para datos
- **backups/**: Carpeta para respaldos

Los providers configurados (local, random y null) permiten crear recursos locales, generar valores aleatorios y ejecutar comandos en tu máquina sin necesidad de conectarte a un proveedor cloud.[1]

[1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/21265984/1d09c688-34e6-41e1-898e-b0ac5c8595da/terraform.txt)
