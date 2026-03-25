-- =============================================================================
-- EJEMPLOS XQUERY: Ejercicio 2
-- Autores: Rafa Oliver, Dani Perez, Dani Jan
-- =============================================================================

-- ============================================================================
-- DATOS XML DE EJEMPLO PARA PRUEBAS
-- ============================================================================

INSERT INTO DocumentsXML(id, xml_data) VALUES (
    6,
    XMLType(
        '<Productes>
           <Producte>
             <Id>1</Id>
             <Nom>Auriculars</Nom>
             <Preu>90</Preu>
             <Imatges>
               <Imatge format="jpg">Foto frontal</Imatge>
             </Imatges>
           </Producte>
           <Producte>
             <Id>2</Id>
             <Nom>Monitor</Nom>
             <Preu>150</Preu>
             <Imatges>
               <Imatge format="jpg">Foto frontal</Imatge>
               <Imatge format="jpg">Foto lateral</Imatge>
               <Imatge format="png">Foto posterior</Imatge>
             </Imatges>
           </Producte>
           <Producte>
             <Id>3</Id>
             <Nom>Camera web</Nom>
             <Preu>45</Preu>
             <Imatges>
               <Imatge/>
             </Imatges>
           </Producte>
         </Productes>'
    )
);

COMMIT;

-- ============================================================================
-- XQUERY 1: Buscar productos con imagenes JPG
-- Usa XMLExists para filtrado y XMLQuery para extraccion de datos
-- ============================================================================

SELECT 
    id,
    XMLQuery(
        'for $p in /Productes/Producte
         where $p/Imatges/Imatge[@format="jpg"]
         return $p/Nom'
        PASSING xml_data
        RETURNING CONTENT
    ) AS nombre_producto
FROM DocumentsXML
WHERE XMLExists(
    '/Productes/Producte/Imatges/Imatge[@format="jpg"]'
    PASSING xml_data
);

-- ============================================================================
-- XQUERY 2: Buscar productos con mas de una imagen
-- Demuestra el uso de la funcion count() en XQuery
-- ============================================================================

SELECT 
    id,
    XMLQuery(
        'for $p in /Productes/Producte
         where count($p/Imatges/Imatge) > 1
         return $p/Nom'
        PASSING xml_data
        RETURNING CONTENT
    ) AS nombre_producto
FROM DocumentsXML
WHERE XMLExists(
    '/Productes/Producte[count(Imatges/Imatge) > 1]'
    PASSING xml_data
);

-- ============================================================================
-- ADICIONAL: Ver contenido XML completo
-- ============================================================================

SELECT id, xml_data.getClobVal() AS xml_content FROM DocumentsXML;
