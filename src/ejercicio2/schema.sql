-- =============================================================================
-- EJERCICIO 2: Gestion Multimedia y XML
-- Autores: Rafa Oliver, Dani Perez, Dani Jan
-- =============================================================================

/*
-- Limpieza (descomentar si es necesario)
DROP TABLE ImatgesProducte PURGE;
DROP TABLE AudiosComanda PURGE;
DROP TABLE DocumentsXML PURGE;
DROP FUNCTION xml_producte;
*/

-- ============================================================================
-- DEFINICION DE TABLAS
-- ============================================================================

-- Tabla de imagenes de productos (almacenamiento BLOB)
CREATE TABLE ImatgesProducte (
    producte_id NUMBER PRIMARY KEY,
    descripcio VARCHAR2(100),
    imatge BLOB,
    format VARCHAR2(100)
);

-- Tabla de audio de pedidos (almacenamiento BLOB)
CREATE TABLE AudiosComanda (
    comanda_id NUMBER PRIMARY KEY,
    audio BLOB,
    durada_segons NUMBER
);

-- Tabla de documentos XML (almacenamiento XMLType)
CREATE TABLE DocumentsXML (
    id NUMBER PRIMARY KEY,
    xml_data XMLTYPE
) TABLESPACE USERS;

-- ============================================================================
-- FUNCION PL/SQL: Generar catalogo XML a partir de datos relacionales
-- ============================================================================

CREATE OR REPLACE FUNCTION xml_producte
RETURN XMLTYPE IS
    v_xml XMLTYPE;
BEGIN
    SELECT 
        XMLElement("Productes",
            XMLAgg(
                XMLElement("Producte",
                    XMLForest(
                        p.PRODUCTE_ID AS "Id",
                        p.NOM AS "Nom", 
                        p.PREU AS "Preu"
                    ),
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

-- ============================================================================
-- VER: Catalogo XML generado
-- ============================================================================

-- SELECT xml_producte().getClobVal() AS xml_catalog FROM dual;

-- ============================================================================
-- CREACION DEL ESQUEMA COMPLETADA
-- Ejecutar xquery_queries.sql a continuacion para ver ejemplos de XQuery
-- ============================================================================
