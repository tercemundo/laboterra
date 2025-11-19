## Nuevas Características de outputs.tf

### Outputs Básicos
Estos son simples y muestran valores directos de los recursos creados:[1]

**proyecto_id**: Muestra el ID único generado hexadecimal (ej: `a3f8d92c1b4e7e2a`)
**servidor_nombre**: Nombre aleatorio del servidor (ej: `servidor-happy-dolphin`)
**regiones_seleccionadas**: Lista de regiones elegidas aleatoriamente
**password_length**: Longitud del password (16)

### Outputs Avanzados con Estructuras Complejas

**proyecto_info** - Objeto compuesto que combina valores de múltiples fuentes:[1]
```hcl
{
  id = "a3f8d92c1b4e7e2a"
  nombre = "terraform-advanced"  # de terraform.tfvars
  region = "us-west-2"  # de terraform.tfvars
  directorio = "terraform-advanced-a3f8d92c1b4e7e2a"
  backup_enabled = true
  created_at = "2025-11-19T02:20:00Z"
}
```

**aplicacion_details** - Construye URLs dinámicas basadas en variables:[1]
```hcl
endpoint = "https://ecommerce-api.us-west-2.example.com:3000"
```

### Output Sensible (Seguridad)

**configuracion_completa** - Marcado como `sensitive = true`, lo que significa que NO se mostrará en la terminal cuando ejecutes `terraform apply`, pero estará disponible en el state:[1]
```bash
# Verlo requiere:
terraform output configuracion_completa
```

### Outputs con Funciones Aplicadas

**estadisticas** - Usa múltiples funciones de Terraform:[1]

**length()**: Cuenta elementos en listas
```hcl
total_entornos = length(var.entornos)  # Resultado: 4 (dev, stage, prod, demo)
```

**sum()**: Suma valores de un array calculado con `for`
```hcl
cpu_total = sum([
  for env, config in var.configuracion_entornos : config.cpu * config.replicas
])
# Calcula: (1×1) + (2×2) + (8×5) + (1×1) = 46 CPUs
```

**join()**: Une elementos de lista con un separador
```hcl
features_formateadas = join(", ", var.aplicacion_config.features)
# Resultado: "auth, payments, inventory, analytics, logging"
```

**upper()**: Convierte a mayúsculas
```hcl
proyecto_uppercase = upper(var.proyecto_nombre)
# Resultado: "TERRAFORM-ADVANCED"
```

**title()** y **replace()**: Combinados para formatear texto
```hcl
region_formatted = title(replace(var.region, "-", " "))
# "us-west-2" → "Us West 2"
```

**For con condicional**: Filtra elementos basándose en condiciones
```hcl
entornos_alta_disponibilidad = [
  for env, config in var.configuracion_entornos : env
  if config.replicas > 1
]
# Resultado: ["stage", "prod"]
```

### Output de URLs Generadas Dinámicamente

**endpoints** - Genera URLs para cada entorno usando `for`:[1]
```hcl
{
  dev = {
    app_url = "https://ecommerce-api-dev.us-west-2.example.com:3000"
    db_url = "mysql://ecommerce-api-dev-db.us-west-2.example.com:3306"
    admin_url = "https://admin-ecommerce-api-dev.us-west-2.example.com"
  }
  stage = { ... }
  prod = { ... }
  demo = { ... }
}
```

## Nuevas Características de funciones.tf

### Locals (Variables Calculadas)

Los `locals` son como variables intermedias que calculan valores reutilizables:[1]

**timestamp_formatted**: Formatea el timestamp con `formatdate()`
```hcl
formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
# Resultado: "2025-11-19 02:20:00 -03"
```

**subnet_cidrs**: Usa `cidrsubnet()` para calcular subredes automáticamente
```hcl
cidrsubnet("10.0.0.0/16", 8, 0)  # dev → 10.0.0.0/24
cidrsubnet("10.0.0.0/16", 8, 1)  # stage → 10.0.1.0/24
cidrsubnet("10.0.0.0/16", 8, 2)  # prod → 10.0.2.0/24
cidrsubnet("10.0.0.0/16", 8, 3)  # demo → 10.0.3.0/24
```

**common_tags**: Define tags estándar para todos los recursos
```hcl
{
  Proyecto = "terraform-advanced"
  ProyectoID = "a3f8d92c1b4e7e2a"
  Region = "us-west-2"
  Terraform = "true"
  Timestamp = "2025-11-19 02:20:00 -03"
}
```

**lb_config**: Genera configuración de load balancer con `for` y `range()`
```hcl
prod = {
  backend_port = 3000
  health_check_path = "/health"
  instances = 5
  target_groups = [
    "ecommerce-api-prod-0",
    "ecommerce-api-prod-1",
    "ecommerce-api-prod-2",
    "ecommerce-api-prod-3",
    "ecommerce-api-prod-4"
  ]
}
```

### Generación de Inventario Ansible

**inventory_content** - Usa **heredoc template** con interpolaciones avanzadas:[1]

```ini
# Resultado generado:
[dev]
ecommerce-api-dev-0 ansible_host=10.0.0.10 subnet=10.0.0.0/24

[dev:vars]
env_name=dev
cpu_limit=1
memory_limit=256Mi
replicas=1
subnet_cidr=10.0.0.0/24

[prod]
ecommerce-api-prod-0 ansible_host=10.0.2.10 subnet=10.0.2.0/24
ecommerce-api-prod-1 ansible_host=10.0.2.11 subnet=10.0.2.0/24
ecommerce-api-prod-2 ansible_host=10.0.2.12 subnet=10.0.2.0/24
ecommerce-api-prod-3 ansible_host=10.0.2.13 subnet=10.0.2.0/24
ecommerce-api-prod-4 ansible_host=10.0.2.14 subnet=10.0.2.0/24
```

### Archivos Generados con Locals

**ansible_inventory**: Crea archivo `hosts.ini` con el contenido del local
**network_config**: JSON con configuración de red calculada
**metrics_config**: YAML con estadísticas agregadas usando `sum()`[1]

## Funciones Clave Utilizadas

**Manipulación de Strings**: `upper()`, `lower()`, `title()`, `replace()`, `format()`, `formatdate()`[1]

**Operaciones de Listas**: `length()`, `join()`, `concat()`, `flatten()`, `index()`[1]

**Operaciones Numéricas**: `sum()`, `min()`, `max()`, `range()`[1]

**Codificación**: `jsonencode()`, `yamlencode()`, `base64encode()`[1]

**Red**: `cidrsubnet()`, `cidrhost()`, `cidrnetmask()`[1]

**Bucles**: `for` expressions con y sin condicionales[1]

**Templates**: Heredoc `<<EOT` con interpolaciones `%{ }` para condicionales e iteraciones[1]

## Resultado Final del `terraform apply`

Cuando ejecutás `terraform apply`, se genera:[1]

```
terraform-advanced-a3f8d92c1b4e7e2a/
├── README.md
├── config.json
├── init.sh
├── application.json          # NUEVO: Config principal
├── config-dev.yaml           # NUEVO: Config por entorno
├── config-stage.yaml
├── config-prod.yaml
├── config-demo.yaml
├── deploy-dev.sh             # NUEVO: Scripts de deploy
├── deploy-stage.sh
├── deploy-prod.sh
├── deploy-demo.sh
├── network.json              # NUEVO: Config de red
├── metrics.yaml              # NUEVO: Métricas
├── inventory/
│   └── hosts.ini            # NUEVO: Inventario Ansible
├── logs/
├── data/
└── backups/
```

La gran diferencia es que ahora **funciones.tf** y **outputs.tf** agregan **generación dinámica de configuraciones complejas** basadas en loops, cálculos y funciones, haciendo tu infraestructura muchísimo más flexible y escalable.[1]

[1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/21265984/6e10d6e7-65ac-429e-a00c-cb5a20dfaf52/terraform.txt)
