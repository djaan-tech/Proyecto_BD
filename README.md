# Proyecto de Desarrollo Avanzado de Oracle Database

### Tecnicas Avanzadas de Base de Datos: PL/SQL, Triggers, Almacenamiento Multimedia y Procesamiento XML

---

![Oracle](https://img.shields.io/badge/Oracle-Database-F80000?logo=oracle&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.x-3776AB?logo=python&logoColor=white)
![PL/SQL](https://img.shields.io/badge/PL%2FSQL-Advanced-F80000)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

---

## Resumen del Proyecto

Este proyecto demuestra las capacidades avanzadas de Oracle Database desarrolladas en equipo, showcaseando habilidades profesionales de desarrollo de bases de datos incluyendo:

| Competencia Principal         | Aplicacion                                    |
| ----------------------------- | --------------------------------------------- |
| **PL/SQL Triggers**           | Aplicacion de integridad de datos y auditoria |
| **Almacenamiento BLOB**       | Gestion de archivos binarios multimedia       |
| **Procesamiento XML**         | XMLType, XQuery y generacion XML de datos     |
| **Integracion Python-Oracle** | Conectividad de base de datos con LOB         |

---

## Miembros del Equipo

| Miembro         | Rol                   | Contribuciones                             |
| --------------- | --------------------- | ------------------------------------------ |
| **Rafa Oliver** | Arquitecto de Datos   | Diseno de esquema, PL/SQL triggers, XQuery |
| **Dani Perez**  | Desarrollador Backend | Integracion Python, operaciones LOB        |
| **Dani Jan**    | QA y Documentacion    | Pruebas, scripts de validacion, docs       |

---

## Habilidades Demostradas

### Ingenieria de Base de Datos

- **Desarrollo de Triggers PL/SQL** — Triggers a nivel de fila y sentencia
- **Validacion de Datos** — Aplicacion de reglas de negocio a nivel de base de datos
- **Registro de Auditoria** — Seguimiento automatico de cambios en datos
- **Gestion de Secuencias** — Secuencias Oracle para claves auto-incrementadas

### Tipos de Datos y Almacenamiento

- **Operaciones BLOB** — Almacenamiento y recuperacion de archivos binarios (imagenes, audio)
- **XMLType** — Almacenamiento y manipulacion nativa de XML
- **Manejo de LOB** — Streaming de grandes objetos desde Python

### Tecnologias de Consulta

- **XQuery** — Consultas XML con predicados y funciones
- **Funciones XML SQL** — XMLElement, XMLAgg, XMLForest, XMLAttributes

### Integracion Python

- **python-oracledb** — Driver oficial de Oracle para Python
- **Gestion de Transacciones** — Manejo de commit/rollback
- **Streaming LOB** — Transferencia eficiente de datos binarios

---

## Estructura del Proyecto

```
Act2BD_TeamProject/
├── README.md                          # Documentacion del proyecto
├── docs/
│   └── DIAGRAMA_ER.png               # (Opcional) Diagrama Entidad-Relacion
├── src/
│   ├── ejercicio1/
│   │   ├── schema.sql                 # Tablas, triggers, secuencias
│   │   ├── test_data.sql              # Datos de prueba
│   │   └── validate_logs.py           # Script Python de validacion
│   └── ejercicio2/
│       ├── schema.sql                 # Tablas multimedia y XML
│       ├── xquery_queries.sql         # Ejemplos de consultas XQuery
│       └── multimedia_tools.py         # Script Python para carga LOB
└── assets/
    └── archivos/
        ├── sample_image.jpg            # Imagen de prueba para BLOB
        ├── sample_audio.mp3           # Audio de prueba para BLOB
        └── sample_data.xml            # Documento XML de prueba
```

---

## Ejercicio 1: Integridad de Datos con Triggers

### Enunciado del Problema

Implementar reglas de negocio a nivel de base de datos para garantizar la consistencia de datos y crear un registro automatico de auditoria para cambios de precios.

### Solucion Implementada

```
+-------------------+      +-------------------+      +-------------------+
|    Productes      |      |  LiniesComanda    |      |    LogsPreus      |
+-------------------+      +-------------------+      +-------------------+
| producte_id (PK)  |      | id_linia (PK)     |      | id_log (PK)       |
| nom               |      | comanda_id        |      | producte_id (FK)  |
| preu              |      | producte_id (FK)  |----->| preu_antic        |
+-------------------+      | unitats           |      | preu_nou          |
                          +-------------------+      | data_modificacio   |
                                |                   +-------------------+
                                v
                    +---------------------------+
                    | TRIGGER: validar_unitats  |
                    | BEFORE INSERT             |
                    | Rechaza si unitats > 100  |
                    +---------------------------+

+-------------------------------------------------------------+
|              TRIGGER: log_preu_producte                     |
|              BEFORE UPDATE OF preu                          |
|              Registra automaticamente cambios en LogsPreus  |
+-------------------------------------------------------------+
```

### Codigo Principal

```sql
-- Trigger para aplicar regla de negocio
CREATE OR REPLACE TRIGGER validar_unitats
BEFORE INSERT ON LiniesComanda
FOR EACH ROW
BEGIN
  IF :NEW.unitats > 100 THEN
    RAISE_APPLICATION_ERROR(-20001,
      'No es poden inserir mes de 100 unitats per linia de comanda.');
  END IF;
END;
/

-- Trigger para registro automatico de auditoria
CREATE OR REPLACE TRIGGER log_preu_producte
BEFORE UPDATE OF preu ON Productes
FOR EACH ROW
WHEN (OLD.preu != NEW.preu)
BEGIN
  INSERT INTO LogsPreus (id_log, producte_id, preu_antic, preu_nou, data_modificacio)
  VALUES (seq_logs_preus.NEXTVAL, :OLD.producte_id, :OLD.preu, :NEW.preu, SYSDATE);
END;
/
```

---

## Ejercicio 2: Gestion Multimedia y XML

### Enunciado del Problema

Almacenar archivos binarios (imagenes, audio) y documentos XML en Oracle, y consultar datos XML usando XQuery.

### Solucion Implementada

```
+--------------------------------------------------------------+
|                      Oracle Database                         |
+--------------------------------------------------------------+
|  +-----------------+  +-----------------+  +---------------+ |
|  |ImatgesProducte  |  | AudiosComanda   |  | DocumentsXML  | |
|  +-----------------+  +-----------------+  +---------------+ |
|  |producte_id (PK) |  | comanda_id (PK) |  | id (PK)       | |
|  | descripcio      |  | audio (BLOB)    |  | xml_data      | |
|  | imatge (BLOB)   |  | durada_segons   |  |  (XMLType)    | |
|  | format          |  |                 |  |               | |
|  +-----------------+  +-----------------+  +---------------+ |
|         |                  |                    |            |
+--------------------------------------------------------------+
|         |                  |                    |            |
|         v                  v                    v            |
|   [Imagenes Binarias]  [Archivos Audio]     [Documentos XML] |
|        JPG, PNG             MP3                  .xml        |
```

### Funcion de Generacion XML

```sql
CREATE OR REPLACE FUNCTION xml_producte
RETURN XMLTYPE IS
  v_xml XMLTYPE;
BEGIN
  SELECT XMLElement("Productes",
    XMLAgg(
      XMLElement("Producte",
        XMLForest(p.PRODUCTE_ID AS "Id", p.NOM AS "Nom", p.PREU AS "Preu"),
        XMLElement("Imatges",
          XMLAgg(
            XMLElement("Imatge",
              XMLAttributes(i.FORMAT AS "format"),
              i.descripcio
            )
          )
        )
      )
    )
  )
  INTO v_xml
  FROM PRODUCTES p
  LEFT JOIN IMATGESPRODUCTE i ON p.PRODUCTE_ID = i.PRODUCTE_ID
  GROUP BY p.PRODUCTE_ID, p.NOM, p.PREU;

  RETURN v_xml;
END;
/
```

### Ejemplos XQuery

```sql
-- Buscar productos con imagenes JPG
SELECT id, XMLQuery(
  'for $p in /Productes/Producte
   where $p/Imatges/Imatge[@format="jpg"]
   return $p/Nom'
  PASSING xml_data RETURNING CONTENT) AS nombre_producto
FROM DocumentsXML
WHERE XMLExists('/Productes/Producte/Imatges/Imatge[@format="jpg"]' PASSING xml_data);

-- Buscar productos con mas de una imagen
SELECT id, XMLQuery(
  'for $p in /Productes/Producte
   where count($p/Imatges/Imatge) > 1
   return $p/Nom'
  PASSING xml_data RETURNING CONTENT) AS nombre_producto
FROM DocumentsXML
WHERE XMLExists('/Productes/Producte[count(Imatges/Imatge) > 1]' PASSING xml_data);
```

---

## Stack Tecnico

| Tecnologia               | Version | Proposito                  |
| ------------------------ | ------- | -------------------------- |
| **Oracle Database**      | 21c+    | Motor de base de datos     |
| **Oracle SQL Developer** | Latest  | IDE de base de datos       |
| **Python**               | 3.x     | Desarrollo de aplicaciones |
| **python-oracledb**      | Latest  | Conectividad Oracle-Python |

---

## Como Empezar

### Requisitos Previos

- Oracle Database (local o remoto)
- Python 3.7+
- Oracle SQL Developer (opcional)

### Instalacion

```bash
# 1. Instalar driver Oracle para Python
pip install oracledb

# 2. Configurar conexion a base de datos
# Actualizar DSN en scripts Python:
# dsn = "192.168.56.101:1521/FREEPDB1"
# user = "SYSTEM"
# password = "oracle"
```

### Ejecutar Ejercicio 1

```bash
# Ejecutar esquema en SQL Developer
src/ejercicio1/schema.sql

# Ejecutar script Python de validacion
python src/ejercicio1/validate_logs.py
```

### Ejecutar Ejercicio 2

```bash
# Ejecutar esquema en SQL Developer
src/ejercicio2/schema.sql

# Ejecutar script de carga multimedia
python src/ejercicio2/multimedia_tools.py
```

---

## Resultados y Salidas

### Salida Ejercicio 1

```
Conectados a Base de datos.
Logs Precios: [25-03-2026 12:40:00] El producto 1 ha cambiado de 85€ a 90€.

Logs Precios: [25-03-2026 12:40:01] El producto 1 ha cambiado de 90€ a 95€.

# Trigger bloquea correctamente inserts invalidos (>100 unidades)
ORA-20001: No es poden inserir mes de 100 unitats per linia de comanda.
```

### Salida Ejercicio 2

```
Conectados a Base de datos.
IMG subida a BD con exito.
MP3 subido a BD con exito.
XML subido a BD con exito.
Tamanos de imagenes:
- 15234 bytes
Tamanos de audios:
- 8192 bytes
```

---

## Resultados de Aprendizaje

A traves de este proyecto, el equipo demostro exitosamente:

1. **Integridad de Base de Datos** — Uso de triggers para aplicar reglas de negocio a nivel de datos
2. **Registros de Auditoria** — Creacion de mecanismos automaticos de registro para cumplimiento
3. **Almacenamiento Multimedia** — Manejo de objetos binarios grandes en Oracle
4. **Integracion XML** — Almacenamiento, generacion y consulta de XML en bases de datos relacionales
5. **Pensamiento Full-Stack** — Combinacion de SQL, PL/SQL y Python para soluciones completas

---

## Licencia

Este proyecto fue desarrollado con propositos educativos como parte del curso de Base de Datos SIMM.

---
