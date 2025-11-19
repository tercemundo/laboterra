## Precedencia de Variables en tu Proyecto

### terraform.tfvars SOBRESCRIBE a variables.tf

En tu caso específico, **`terraform.tfvars` tiene precedencia** sobre los valores `default` definidos en `variables.tf`.[2][3][1]

**Ejemplo concreto de tu configuración:**

```hcl
# variables.tf declara:
variable "proyecto_nombre" {
  default = "mi-proyecto"
}

# terraform.tfvars asigna:
proyecto_nombre = "terraform-advanced"

# Resultado final: "terraform-advanced" ✅
```

El valor de `terraform.tfvars` **gana** porque tiene mayor precedencia que el `default` de `variables.tf`.[4][1]

### Orden Completo de Precedencia

De **menor a mayor prioridad**:[3][4]

1. **`default` en variables.tf** → `"mi-proyecto"`
2. **Variables de entorno** → `export TF_VAR_proyecto_nombre="desde-env"`
3. **`terraform.tfvars`** → `proyecto_nombre = "terraform-advanced"`
4. **`-var-file`** → `terraform apply -var-file="prod.tfvars"`
5. **`-var` en CLI** → `terraform apply -var="proyecto_nombre=overridden"` (máxima prioridad)

## Qué Pasa Cuando Ejecutás `terraform apply`

### Fase 1: Validación de Variables

Terraform procesa las variables en este orden:[1]

**Variables con valor asignado** (de `terraform.tfvars`):
- `proyecto_nombre = "terraform-advanced"` ✅
- `instancias_count = 5` ✅ (cumple validación: entre 1 y 10)
- `habilitar_backup = true` ✅
- `region = "us-west-2"` ✅ (obligatoria, no tiene default)
- `entornos = ["dev", "stage", "prod", "demo"]` ✅
- `configuracion_entornos` y `aplicacion_config` ✅

**Importante**: La variable `region` **no tiene default** en `variables.tf`, entonces **debe** proporcionarse en `terraform.tfvars` o Terraform te la pedirá interactivamente.[1]

### Fase 2: Orden de Ejecución de Recursos

Basándome en el grafo de dependencias:[1]

**Paso 1 - Recursos Random (paralelos)**:
- `random_id.proyecto_id` → genera ID único (ej: `a3f8d92c1b4e7e2a`)
- `random_password.db_password` → crea contraseña de 16 caracteres
- `random_pet.servidor_nombre` → genera nombre (ej: `servidor-happy-dolphin`)
- `random_uuid.session_id` → crea UUID único
- `random_shuffle.regiones_disponibles` → selecciona 2 de 4 regiones

**Paso 2 - Archivos Locales (paralelos después de random)**:
- `local_file.directorio_info` → crea `proyecto-a3f8d92c1b4e7e2a/README.md`
- `local_file.config_json` → crea `proyecto-a3f8d92c1b4e7e2a/config.json`
- `local_file.init_script` → crea `proyecto-a3f8d92c1b4e7e2a/init.sh` (con permisos 0755)

**Paso 3 - Setup del Proyecto**:
- `null_resource.setup_proyecto` → ejecuta `init.sh`, crea carpetas (logs/, data/, backups/)

**Paso 4 - Mostrar Información**:
- `null_resource.mostrar_info` → imprime resumen del proyecto en terminal

**Paso 5 - Outputs**:
- Muestra `proyecto_id`, `servidor_nombre`, `regiones_seleccionadas` y `password_length`

### Fase 3: Resultado Final

Se crea la siguiente estructura:[1]

```
proyecto-a3f8d92c1b4e7e2a/
├── README.md          (con info del proyecto)
├── config.json        (configuración en JSON)
├── init.sh            (script ejecutable)
├── logs/
│   └── startup.log    (log de inicialización)
├── data/              (carpeta vacía)
└── backups/           (carpeta vacía)
```

## Punto Importante: Variables No Utilizadas

Tu archivo `terraform.tfvars` define muchas variables (`proyecto_nombre`, `instancias_count`, `configuracion_entornos`, etc.) **PERO** ningún recurso las está usando actualmente.  Tus recursos usan valores hardcodeados directamente (como `byte_length = 8`, `length = 16`, etc.).[1]

Para usar estas variables, deberías modificar tus recursos, por ejemplo:[1]

```hcl
# En lugar de:
resource "random_password" "db_password" {
  length = 16
}

# Podrías usar:
resource "random_password" "db_password" {
  length = var.instancias_count * 3  # usando la variable
}
```

En resumen: **`terraform.tfvars` sobrescribe `variables.tf`**, los archivos se ejecutan según dependencias (no alfabéticamente), y las variables están definidas pero no se usan en los recursos actuales.[5][2][1]

[1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/21265984/51c4ebef-b4c9-432d-a9cc-23531e06f4ca/terraform.txt)
[2](https://spacelift.io/blog/terraform-tfvars)
[3](https://wintelguy.com/2025/understanding-terraform-variable-precedence.html)
[4](https://www.linkedin.com/posts/anupam-kumar-03053964_iac-devops-cloudcomputing-activity-7344643224189222912-029a)
[5](https://discuss.hashicorp.com/t/order-of-run-tf-file/34998)
