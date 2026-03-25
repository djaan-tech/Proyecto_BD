-- =============================================================================
-- DATOS DE PRUEBA: Ejercicio 1
-- Autores: Rafa Oliver, Dani Perez, Dani Jan
-- =============================================================================

-- ============================================================================
-- INSERTAR PRODUCTOS DE EJEMPLO
-- ============================================================================

INSERT INTO Productes VALUES (1, 'Auriculars', 85);
INSERT INTO Productes VALUES (2, 'Monitor', 150);
INSERT INTO Productes VALUES (3, 'Camera web', 45);

-- ============================================================================
-- INSERTAR LINEAS DE PEDIDO DE EJEMPLO
-- ============================================================================

INSERT INTO LiniesComanda VALUES (1, 101, 1, 50);
INSERT INTO LiniesComanda VALUES (2, 101, 1, 40);

-- ============================================================================
-- ACTUALIZAR PRECIO PARA PROBAR EL TRIGGER DE AUDITORIA
-- ============================================================================

-- Primer cambio de precio
UPDATE Productes SET preu = 90 WHERE producte_id = 1;

-- Segundo cambio de precio
UPDATE Productes SET preu = 95 WHERE producte_id = 1;

-- ============================================================================
-- VER REGISTRO DE CAMBIOS DE PRECIO
-- ============================================================================

SELECT 
    producte_id, 
    preu_antic, 
    preu_nou, 
    TO_CHAR(data_modificacio, 'DD-MM-YYYY HH24:MI:SS') AS data_canvi
FROM LogsPreus;

-- ============================================================================
-- PRUEBA DE VALIDACION: Este insert debe funcionar (50 < 100 unidades)
-- ============================================================================

INSERT INTO LiniesComanda VALUES (56, 102, 1, 50);
INSERT INTO LiniesComanda VALUES (40, 102, 1, 33);

-- ============================================================================
-- PRUEBA DE VALIDACION: Este insert debe FALLAR (>100 unidades)
-- Descomentar para probar la aplicacion del trigger:
-- INSERT INTO LiniesComanda VALUES (81, 101, 1, 303);
-- Error esperado: ORA-20001
-- ============================================================================
