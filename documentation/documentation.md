# 🚀 Proyecto ELT con AWS Glue, Amazon S3 y Amazon Redshift

Este proyecto demuestra el desarrollo completo de un flujo **ETL (Extract, Transform, Load)** en la nube utilizando servicios administrados de **AWS**, con el objetivo de practicar **data wrangling, catalogación, transformación y carga de datos** para analítica.

La arquitectura integra **Amazon S3** como capa de almacenamiento, **AWS Glue** como motor de catalogación, limpieza y transformación de datos (ETL/ELT), y **Amazon Redshift** como data warehouse analítico.

---

## 🧩 Arquitectura General

La arquitectura sigue un enfoque **ETL**, donde los datos en bruto se extraen de un almacén, luego se transforman, permitiendo trazabilidad y flexibilidad en el procesamiento y por último se cargan en un destino.

**Flujo general del proyecto:**

1. **Amazon S3**
   - Almacenamiento de los archivos fuente (`.json`)
   - Datos con valores nulos, duplicados y variaciones de esquema para pruebas de data wrangling

2. **AWS Glue**
   - Crawlers para inferencia de esquemas y creación del **Data Catalog**
   - Jobs visuales (sin código) para:
     - Eliminación de filas nulas
     - Eliminación de duplicados
     - Limpieza y estandarización de datos
   - Transformaciones previas antes de la carga analítica

3. **Amazon Redshift**
   - Recepción de los datos transformados desde Glue
   - Almacenamiento estructurado para consultas analíticas
   - Validación del esquema final y consistencia de datos

---

## 🔄 Implementación End-to-End del Proyecto
En esta sección se detallan los pasos ejecutados a lo largo de todo el ciclo del proyecto, desde la ingesta de datos hasta su carga final para análisis.

---

### 🪣 Paso A: Configuración de Amazon S3 (Buckets y archivos de origen)

En esta etapa se prepara la capa de almacenamiento que actuará como fuente de datos del proyecto.

#### 📂 Bucket de Amazon S3

* Se utiliza un bucket previamente creado para el proyecto.

* Nombre del bucket: ``` bucket-data-source ```

#### 📄 Archivos de datos

* Dentro del bucket se cargan los archivos que serán consumidos por el proceso ETL.

* Para este proyecto se utiliza un archivo de prueba en formato JSON, el cual simula datos de ventas.

Archivo utilizado: ``` sales_test.json ```

Este archivo representa el origen de datos bruto (raw data) y será consumido posteriormente por los servicios de integración y transformación definidos en las siguientes etapas del proyecto.

---

### 🔐 Paso B: Creación del rol IAM para la ejecución del proyecto

En esta etapa se define el rol de seguridad que permitirá la comunicación entre los distintos servicios de AWS utilizados en el proyecto, aplicando el principio de mínimo privilegio.

#### 🎯 Objetivo del rol

El rol será utilizado principalmente por AWS Glue, que actúa como el servicio orquestador del flujo ETL. Desde Glue se requiere acceso a:

* Amazon S3 (lectura de datos de origen y escritura de resultados)

* Amazon Redshift (carga de datos transformados)

* Catálogo de datos y jobs de Glue

Por este motivo, **Glue es el servicio principal (líder)** que asume este rol durante la ejecución del proyecto.

#### 🧾 Detalles del rol IAM

* Nombre del rol: ``` rol-project-s3-glue-redshift ```
* Servicio que asume el rol (Trusted Entity): **AWS Glue**

#### 📜 Políticas de permisos asignadas

Para efectos del proyecto y pruebas, se asignan las siguientes políticas administradas por AWS:

* AWSGlueServiceRole

* PoliticaGluePersonalizada ➡️ [Link de recurso](https://github.com/BrayanR03/Proyecto-Pipeline-E2E-AWS/blob/main/assets/PoliticaGluePersonalizada.json)

> ⚠️ Nota:
En un entorno productivo, estas políticas personalizadas son más restrictivas, priorizando el cumplimiento del **Principio del mínimo Privilegio** y una correcta integración entre servicios.

---

### 🧪 Paso C: AWS Glue – Crawler, Data Catalog y Visual ETL

En esta etapa se prepara el entorno de metadatos y transformación que permitirá trabajar los datos almacenados en Amazon S3 de forma estructurada.

#### 📌 Consideración clave inicial

Los archivos almacenados en Amazon S3 (en este caso archivos JSON) no poseen un esquema relacional explícito que pueda ser utilizado directamente para procesos ETL.

Por este motivo, es necesario **inferir previamente el esquema de los datos**, para luego poder:

* Catalogarlos

* Transformarlos

* Cargarlos a un destino analítico (Amazon Redshift)

#### 🔍 Uso del AWS Glue Crawler

Para resolver lo anterior, se utiliza un AWS Glue Crawler, el cual:

* Analiza los datos en su origen (S3)

* Infiere automáticamente su estructura (columnas, tipos de datos)

* Registra el esquema como metadatos dentro del AWS Glue Data Catalog

> ⚠️ Importante:
La base de datos del Data Catalog NO almacena datos, únicamente metadatos.
Los datos reales permanecen siempre en Amazon S3.

---

#### 🗂️ Pasos iniciales de configuración

##### i) **Creación de la base de datos en Glue Data Catalog**

Se crea una base de datos lógica para organizar los metadatos del proyecto.

* Nombre de la base de datos: ``` db_project_s3_glue_redshift ```

##### **ii) Creación del Crawler**

Se configura un crawler apuntando al bucket y ruta donde se encuentran los archivos fuente en S3.

* Nombre del crawler: ``` crawler_project_s3_glue_redshift ```
* Origen de datos: **Amazon S3 (bucket del proyecto)**, ingresamos al bucket **``` bucket-data-source ```** y seleccionamos **``` sales_test.json ```**
* Selccionamos IAM role: **Rol creado anteriormente -> ``` rol-project-s3-glue-redshift ```**
* Base de datos destino: **Base de datos db_project_s3_glue_redshift en el Data Catalog**
* **Next o Siguiente** y le damos a **Create Crawler**
> 📝 Nota importante:
Las tablas dentro del Data Catalog se crean automáticamente al ejecutar el crawler, en base al esquema inferido.

##### **iii) Ejecución y validación**

* Se ejecuta el crawler

* Se espera a que finalice correctamente

* Se verifica que:

   * La tabla haya sido creada en la base de datos ``` db_project_s3_glue_redshift ```

   * El esquema inferido sea coherente con los datos de origen

---

### 🛠️ Paso C (Continuación): Creación del Visual ETL en AWS Glue

Como segundo punto dentro de esta etapa, se procede a la creación del Visual ETL Job en AWS Glue Studio, el cual permitirá diseñar el flujo de transformación de datos de forma gráfica.

---

#### 🎨 Visual ETL en AWS Glue Studio

Para este proyecto se utiliza Visual ETL, el cual es ideal para:

* Procesos ETL simples a medianos

* Flujos de transformación claros y controlados

* Casos donde se busca minimizar el uso de código

> 📌 Nota técnica:
Para procesos ETL más complejos, con múltiples dependencias o alta orquestación, se recomienda evaluar servicios como Amazon EMR o AWS Step Functions, integrando varios servicios de AWS.

---

#### 🧩 Fases del Visual ETL

Dentro del Visual ETL, el flujo de trabajo se organiza en tres fases principales, cada una representada por distintos tipos de nodos:

1. **Sources (Orígenes)**
Definen desde dónde se leen los datos.

2. **Transforms (Transformaciones)**
Permiten limpiar, enriquecer y modificar los datos.

3. **Targets (Objetivos)**
Definen el destino final de los datos procesados.

📍 Todos los nodos pueden agregarse desde el ícono “+” ubicado en el workspace del Visual ETL.

---

#### ****🔌 Fase 1: Nodo de Origen (Source)****

**i) AWS Glue Data Catalog**

Se selecciona el nodo **AWS Glue Data Catalog**, el cual permite conectarse directamente a la tabla creada previamente mediante la ejecución del crawler.

Este nodo:

* Utiliza los metadatos almacenados en Glue Data Catalog

* Apunta físicamente a los datos almacenados en Amazon S3

##### ⚠️ Consideraciones importantes para la previsualización de datos

En caso de no poder previsualizar los datos del origen, se deben verificar los siguientes puntos:

1. **Rol de IAM del Job**

   * Ir a Job details del Visual ETL

   * En la sección IAM Role, seleccionar el rol creado en el **Paso B**: ``` rol-project-s3-glue-redshift ```

2. **Refrescar el entorno**

   * Si el rol no aparece inmediatamente, basta con refrescar la página

   * Al hacerlo, el nodo AWS Glue Data Catalog se eliminará automáticamente

   * Se debe volver a agregar el nodo después de seleccionar el rol correcto

3. **Selección de base de datos y tabla**

   * En la opción Database, seleccionar: ``` db_project_s3_glue_redshift ```
   * En la opción **Table**, seleccionar la tabla creada por el crawler

Una vez completados estos pasos, los datos podrán **previsualizarse correctamente** dentro del Visual ETL.


#### ****🔌🔄 Fase 2: Transformación (Data Wrangling)****

Una vez configurado correctamente el origen de datos, se procede a la fase de transformación, donde se aplican buenas prácticas de data wrangling para asegurar la calidad, consistencia y compatibilidad de los datos antes de su carga al destino final.

**ii) Eliminación de filas completamente nulas**

Como primera transformación, se eliminan aquellas filas que contienen valores nulos en todos sus campos, lo cual suele indicar registros inválidos o ruido en el dataset.

* Nodo utilizado: **Remove Null Rows**

* Ubicación: sección **Transform**

* Conexión: 
   ```sql
   AWS Glue Data Catalog  →  Remove Null Rows
   ```
Al previsualizar los datos después de aplicar este nodo, se observa que las filas completamente nulas ya no aparecen, confirmando que el proceso de limpieza va por buen camino.

**iii) Eliminación de filas duplicadas**

Siguiendo las buenas prácticas de calidad de datos, el siguiente paso consiste en eliminar **registros duplicados**, considerando la fila completa como unidad de comparación.

* Nodo utilizado: **Drop Duplicates**

* Ubicación: sección **Transform**

* Conexión:
   ```sql
   Remove Null Rows  →  Drop Duplicates
   ```
Luego de aplicar este nodo, la previsualización de datos muestra que los registros duplicados han sido correctamente eliminados.

**iv) Transformaciones con SQL (normalización y columnas calculadas)**

Para realizar transformaciones más flexibles y rápidas, se utiliza el nodo SQL Query, el cual permite aplicar lógica de negocio mediante SQL directamente sobre el flujo de datos.

Este nodo se conecta al paso anterior:
   ```sql
   Drop Duplicates  →  SQL Query
   ```

Objetivos de este paso:

* Reemplazar valores nulos en columnas específicas

* Normalizar datos numéricos

* Crear columnas calculadas

Query utilizada:
```sql
SELECT 
    order_id,
    order_date,
    COALESCE(customer,'NN') as customer,
    product,
    category,
    COALESCE(quantity, 0) AS quantity,
    COALESCE(unit_price, 0) AS unit_price,
    region,
    COALESCE(quantity * unit_price, 0) AS total_sales
FROM myDataSource
WHERE order_id is not null and order_date is not null
ORDER BY order_id ASC;
```
> 📌 Nota importante:
**myDataSource** hace referencia al nombre del nodo anterior, es decir, el nodo **Drop Duplicates**, el cual actúa como la tabla fuente para esta consulta.

**v) Alineación de tipos de datos (Change Schema)**

Este paso es crítico dentro del proceso ETL, debido que garantiza la compatibilidad entre el esquema del origen transformado en Glue y el esquema definido en la tabla destino en Amazon Redshift.

* Nodo utilizado: **Change Schema**

* Ubicación: sección **Transform**

* Conexión:
   ```sql
      SQL Query  →  Change Schema
   ```
* Columnas convetidas (Tipo de dato original -> Tipo de dato convertido):
   ```sql
      order_date (string) -> order_date (date)
      unit_price (double) -> unit_price (decimal)
      total_sale (double) -> total_sale (decimal)
   ```
**¿Por qué es tan importante este paso?**

Si los tipos de datos no se alinean correctamente:

* Las columnas con tipos incompatibles en Redshift quedarán como NULL

* Glue creará columnas adicionales con nombres y tipos distintos

* El esquema final en Redshift se romperá, perdiendo trazabilidad y control del modelo de datos

* Los nuevos tipos de datos son compatibles finalmente para la tabla destino en Redshift

* ⚠️ Algunos campos quedarán en NULL por la naturaleza de los datos, esto permitirá analizarlos en Redshift.

Con el nodo **Change Schema**, se transforman explícitamente los tipos de datos del flujo para que coincidan exactamente con los definidos en la tabla destino de Redshift, asegurando una carga limpia y consistente.


#### ****🔌🔄 Fase 3: Destino (Target)****

**vi) Configuración del destino: Amazon Redshift (Target)**

Como **penúltimo paso** en la elaboración del **Visual ETL** en **AWS Glue**, se procede a configurar el **nodo de destino (Target)** llamado **Amazon Redshift**.
Este nodo permitirá cargar los datos transformados hacia un **Data Warehouse** previamente creado en **Amazon Redshift**, utilizando una conexión segura definida explícitamente para Glue.

Antes de configurar este nodo dentro del Visual ETL, es necesario realizar los siguientes **sub-pasos previos**:

#### a) Creación del Data Warehouse en Amazon Redshift Serverless

Amazon Redshift es un servicio serverless, donde AWS administra la mayor parte de la infraestructura, permitiéndonos enfocarnos únicamente en el modelo de datos y las consultas.

##### **1. Creación del Workgroup (Grupo de Trabajo)**

Desde el servicio **Amazon Redshift**, seleccionamos **Crear grupo de trabajo (Workgroup)** y configuramos únicamente los campos más relevantes:

* Nombre del grupo de trabajo: ```wk-project-s3-glue-redshift```

En el apartado **Redes y seguridad**, configuramos:

* IP address type: IPv4

* VPC: VPC por defecto de AWS

* Security Group: grupo de seguridad por defecto

* Subnets:

   Redshift requiere al menos 3 subredes para alta disponibilidad.
   La VPC por defecto ya incluye 3 subredes, por lo que se dejan seleccionadas automáticamente.

Se dejan los demás valores por defecto y se continúa.

##### **2. Creación del Namespace (credenciales)**

El **Namespace** define las credenciales y el acceso lógico a la base de datos.

* Nombre del Namespace: ```ns-project-s3-glue-redshift```

* Se selecciona **Personalizar** credenciales del usuario administrador

* Seleccionamos **Agregar manualmente la contraseña del administrador**

* En **Contrasña de usuario administrador** ingresamos manualmente (solo para prácticas): ```12345Rafael#```

> ⚠️ En un entorno productivo, lo recomendado es permitir que AWS Secrets Manager genere y administre las credenciales.

##### **3. Rol de IAM para Redshift (acceso a S3)**

Aquí surge una duda común:
**¿Este rol es el mismo que el rol de Glue?**

* 👉 No. Es un rol distinto.

Este rol permite que Redshift acceda directamente a S3 para leer y escribir datos. Asimismo, el rol lo crearemos directamente en IAM y luego lo asociaremos a Redshift

Configuración del rol:

* Nombre: ```AmazonRedsfhit-Rol-S3-Project```

* Política personalizada:

   * Nombre: ```PoliticaRedshiftPersonalizada.json``` 
   ```bash
   {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Statement1",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::bucket-data-source"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::bucket-data-source/*"
        }
    ]
   }
   ```
* Se crea un rol  y se asigna al Namespace.

> ⏳ Se debe esperar a que el Workgroup y el Namespace se creen correctamente. Una vez creados, aparecerán listados en el panel principal de Redshift.

#### b) Creación de la conexión Glue → Redshift (JDBC)

Este paso es crítico, debido que permite que AWS Glue pueda conectarse a Redshift para escribir los datos del ETL.

Existen **dos formas** de crear esta conexión:

❌ Opción 1: UI de Glue (NO recomendada)

Aunque se puede crear una conexión desde Glue → Data Connections, esta opción suele generar errores, debido que:

* La conexión termina asociándose a la VPC

* Glue requiere una Subnet específica, no solo la VPC

Esto provoca errores de validación al ejecutar el job 😅

✅ Opción 2: AWS CloudShell (RECOMENDADA)

Desde AWS CloudShell, se ejecuta el siguiente comando para crear la conexión correctamente:
```bash
aws glue create-connection \
  --connection-input '{
    "Name": "glue-redshift-connection",
    "ConnectionType": "JDBC",
    "Description": "Glue connection to Redshift Serverless",
    "ConnectionProperties": {
      "JDBC_CONNECTION_URL": "<URL_JDBC_DEL_WORKSPACE>",
      "USERNAME": "admin",
      "PASSWORD": "<PASSWORD_DEL_NAMESPACE>",
      "JDBC_ENFORCE_SSL": "true"
    },
    "PhysicalConnectionRequirements": {
      "SubnetId": "<SUBNET_DEL_WORKSPACE_ZONA_DISPONIBILIDAD_2a>",
      "SecurityGroupIdList": ["<SECURITY_GROUP_DEL_WORKSPACE>"],
      "AvailabilityZone": "us-east-2a"
    }
  }'
```
📌 Todos estos valores se obtienen desde los detalles del Workgroup en Redshift. Además, les recomiendo utilizar la zona de disponibilida **a**.

#### c) Creación del VPC Endpoint para S3 (Gateway)

Para que Glue pueda leer desde S3 y escribir en Redshift **sin errores de red**, es necesario crear un **VPC Endpoint** de tipo **Gateway** para S3.

Pasos:

1. Ir a VPC → PrivateLink y Lattice → Endpoints

2. Crear un nuevo endpoint con:

   * Nombre: endpoint-glue-s3-project-glue-redshift

   * Tipo: Servicios de AWS

   * Servicio: ```com.amazonaws.us-east-2.s3``` (tipo Gateway)

   * VPC: VPC por defecto

   * Route Tables: tabla principal de la VPC

   * Policy: Full Access

Esto soluciona errores como:
```text
InvalidInputException - VPC S3 endpoint validation failed for SubnetId...
Could not find S3 endpoint or NAT gateway...
```
📌 Este error indica que la subnet privada no tenía acceso a S3, lo cual es obligatorio para Glue.

#### d) Creación de la tabla destino en Redshift

Con Redshift, la conexión y la red correctamente configuradas, se procede a crear la tabla destino.

1. Acceder a **Datos de consulta** en Amazon Redshift

2. Conectarse al Workgroup usando **Federated User** (Lado izquierdo aparecera un menú con **Serverless: nombre_workspace_definido**).
   Después, click derecho y **Create connection**

3. Ubicación del esquema:
```java
Workgroup
  └── native databases
      └── dev
          └── public
```
Query para crear la tabla destino:
```sql
CREATE TABLE sales
(
    order_id INT,
    order_date DATE,
    customer TEXT,
    product TEXT,
    category TEXT,
    quantity INT,
    unit_price DECIMAL(10,2),
    region TEXT,
    total_sales DECIMAL(10,2)
);
```
Se ejecuta la consulta y la tabla queda creada correctamente.

📌 Es fundamental que el esquema coincida exactamente con el esquema final definido en Glue (especialmente después del nodo **Change Schema**).

**VII. Configuración del nodo Amazon Redshift y ejecución del ETL**

Ahora bien, una vez realizada la configuración previa en **Amazon Redshift**, tales como la creación del **Workspace**, **Namespace**, **la conexión entre AWS Glue y Redshift**, así como la configuración del **endpoint dentro de la VPC**, procederemos a configurar el nodo elegido en el paso VI, denominado **“Amazon Redshift”**, el cual se encuentra dentro de los nodos de tipo Target.

En el apartado de configuración del nodo, específicamente en **“Redshift access type”**, seleccionaremos la opción recomendada por AWS:

* **Direct data connection – recommended**

En el siguiente apartado, **“Redshift connection”**, elegiremos el conector previamente creado entre Glue y Redshift, el cual en este caso se denomina:

* ```glue-redshift-connection```

Una vez seleccionado el tipo de acceso y el conector de Redshift, procederemos a elegir **el esquema por defecto** que nos brinda la base de datos / Data Warehouse de Redshift:

* Schema: ```public```

Posteriormente, seleccionaremos la tabla creada anteriormente:

* Tabla destino: ```sales```

Adicionalmente, en la primera ejecución del proceso ETL, el apartado **“Handling of data and target data”** se encontrará configurado por defecto en **APPEND**, lo que indica que cada vez que se ejecute el ETL se insertarán todos los datos, existan o no previamente, permitiendo duplicados.

Sin embargo, la opción recomendada es **MERGE**, debido que:

* Evita la inserción de registros duplicados

* Actualiza la información existente

* Funciona como un **UPSERT (UPDATE + INSERT)**

* Luego, por defecto se seleccionarpa **Choose keys and simple actions**, donde elegiremos en **Matching keys** la columna que representará la clave primaria
  en la tabla **sales**, en este caso, se elige la columna **order_id**.

Finalmente, guardamos la configuración del **Visual ETL**, seleccionamos **Run** y se iniciará el proceso ETL. El estado de la ejecución puede verificarse en el apartado **“Runs”**, donde el estado cambiará de **Running** a **Succeeded**.

Para validar que el proceso ETL se ejecutó correctamente, nos dirigimos al **Editor de consultas SQL de Redshift** y ejecutamos la siguiente consulta:
```sql
SELECT * FROM sales
```
Si los datos se muestran correctamente, se confirma que el proceso ETL se ejecutó de manera exitosa y que la información se encuentra almacenada en Amazon Redshift.
