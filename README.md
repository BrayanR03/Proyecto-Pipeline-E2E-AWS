# 🚀 Pipeline E2E Data Engineering Project - AWS

Este repositorio contiene un **proyecto completo de Data Engineering end-to-end**, donde se implementa un pipeline **ETL real en AWS**, integrando servicios clave del ecosistema cloud y siguiendo buenas prácticas de arquitectura, seguridad y data wrangling.

El objetivo principal de este proyecto es **demostrar, de forma práctica**, cómo diseñar, construir y ejecutar un flujo de datos desde un **Data Lake en S3** hasta un **Data Warehouse en Amazon Redshift**, utilizando **AWS Glue (Visual ETL)** como motor de transformación.

---

## 🧩 Arquitectura General

La arquitectura del proyecto está diseñada para un escenario real de analítica de datos en la nube:

- **Amazon S3** → Data Lake (datos fuente en formato JSON/CSV)
- **AWS Glue**
  - Crawlers para inferencia de esquemas
  - Data Catalog para gestión de metadatos
  - Visual ETL para transformaciones y orquestación
- **Amazon Redshift Serverless** → Data Warehouse
- **IAM** → Roles y permisos bajo el principio de mínimo privilegio
- **VPC + Endpoint a S3** → Conectividad privada y segura entre servicios

📌 El flujo evita dependencias innecesarias y prioriza servicios **serverless**, reduciendo complejidad operativa.

---

## 🔄 Flujo ETL (Extract, Transform, Load)

1. **Extract**
   - Los datos se almacenan inicialmente en Amazon S3.
   - AWS Glue Crawler infiere el esquema y crea las tablas en el Data Catalog.

2. **Transform**
   - Limpieza de datos:
     - Eliminación de filas completamente nulas
     - Eliminación de registros duplicados
   - Transformaciones mediante SQL en Glue:
     - Manejo de valores nulos con `COALESCE`
     - Creación de columnas calculadas
   - Ajuste de tipos de datos con `Change Schema` para asegurar compatibilidad con Redshift.

3. **Load**
   - Carga de datos en Amazon Redshift Serverless usando el nodo **Amazon Redshift (Target)**.
   - Estrategia de carga:
     - `MERGE` (UPSERT) para evitar duplicados y mantener consistencia.

---

## 🛠️ Tecnologías Utilizadas

- Amazon S3
- AWS Glue (Crawler, Data Catalog, Visual ETL)
- Amazon Redshift Serverless
- AWS IAM
- Amazon VPC (Endpoint Gateway a S3)
- SQL (para transformaciones y modelado)

---

## 📂 Estructura del Repositorio

```text
├── documentation/        # Documentación detallada del proyecto
├── sql/                  # Queries SQL usadas en Redshift y Glue
├── assets/               # Datos de prueba (JSON)
├── architecture/         # Diagrama de arquitectura
└── README.md             # Descripción general del proyecto
```
---

## 📺 Recursos del Proyecto

* 🎥 YouTube (paso a paso del proyecto):
[Link Playlist](https://www.youtube.com/playlist?list=PLx9ZJhSt41bP1KCzRhpU0gHHe8bUkKKmq)

* 📄 Documentación completa del proceso:
Disponible en este repositorio dentro de la carpeta `/documentation`

Este proyecto está pensado como material educativo y de portafolio, enfocado en aprendizaje práctico y resolución de problemas reales en Data Engineering.

---

## Proyecto dictado en Bootcamp Gratuito CONOVATEC - Construcción de un pipeline de datos en Amazon Web Services (AWS)

* 🎦 Día #1 || Introducción, conceptos fundamentales de AWS, Amazon S3 y AWS IAM. || 16/03/2026
  [Youtube](https://www.youtube.com/watch?v=BTpAUE4Y-7g&t=6070s)
  [Linkedin](https://www.linkedin.com/feed/update/urn:li:activity:7439505255484215296/)
  
* 🎦 Día #2 || AWS Glue, Proceso ETL y Configuración Amazon Redshift || 17/03/2026
  [Youtube](https://www.youtube.com/watch?v=TcAOup8Fa7Y)
  [Linkedin](https://www.linkedin.com/feed/update/urn:li:activity:7440025523176697856/)

* 🎦 Día #3 || Amazon Redshift y Validación del Job ETL || 18/03/2026
  [Youtube](https://www.youtube.com/watch?v=hEuA1MMQ9Pk)
  [Linkedin](#-arquitectura-general)

---

## 👤 Autor

Brayan Neciosup |
Data & Cloud Engineering Jr. 📊

- 🌐 [Portafolio Web](https://bryanneciosup626.wixsite.com/brayandataanalitics)
- 💼 [LinkedIn](https://www.linkedin.com/in/brayan-rafael-neciosup-bola%C3%B1os-407a59246/)
- 📬 Contacto: brayanneciosup626@gmail.com
- 🎦 [Youtube](https://www.youtube.com/@brayanneciosup9873)
