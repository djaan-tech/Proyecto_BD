-- =============================================================================
-- EJERCICIO 1: Integridad de Datos con Triggers PL/SQL
-- Autores: Rafa Oliver, Dani Perez, Dani Jan
-- =============================================================================

/*
-- Limpieza (descomentar si es necesario)
DROP TABLE Productes PURGE;
DROP TABLE LiniesComanda PURGE;
DROP TABLE LogsPreus PURGE;
DROP SEQUENCE seq_logs_preus;
*/

-- ============================================================================
-- DEFINICION DE TABLAS
-- ============================================================================

-- Tabla de productos
CREATE TABLE Productes (
    producte_id NUMBER PRIMARY KEY,
    nom VARCHAR2(100),
    preu NUMBER(10,2)
);

-- Tabla de lineas de pedido
CREATE TABLE LiniesComanda (
    id_linia NUMBER PRIMARY KEY,
    comanda_id NUMBER,
    producte_id NUMBER,
    unitats NUMBER
);

-- Tabla de registro de cambios de precios (auditoria)
CREATE TABLE LogsPreus (
    id_log NUMBER PRIMARY KEY,
    producte_id NUMBER,
    preu_antic NUMBER(10,2),
    preu_nou NUMBER(10,2),
    data_modificacio DATE DEFAULT SYSDATE
);

-- ============================================================================
-- SECUENCIA PARA AUTO-INCREMENTO
-- ============================================================================

CREATE SEQUENCE seq_logs_preus
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

-- ============================================================================
-- TRIGGER 1: Validar unidades por linea de pedido
-- Regla de negocio: No se permiten mas de 100 unidades por linea de pedido
-- ============================================================================

CREATE OR REPLACE TRIGGER validar_unitats
BEFORE INSERT ON LiniesComanda
FOR EACH ROW
BEGIN
    IF :NEW.unitats > 100 THEN
        RAISE_APPLICATION_ERROR(
            -20001, 
            'No es poden inserir mes de 100 unitats per linia de comanda.'
        );
    END IF;
END;
/

-- ============================================================================
-- TRIGGER 2: Registro automatico de cambios de precio
-- Proposito: Crea un registro de auditoria cuando se actualizan precios de productos
-- ============================================================================

CREATE OR REPLACE TRIGGER log_preu_producte
BEFORE UPDATE OF preu ON Productes
FOR EACH ROW
WHEN (OLD.preu != NEW.preu)
BEGIN
    INSERT INTO LogsPreus (
        id_log, 
        producte_id, 
        preu_antic, 
        preu_nou, 
        data_modificacio
    )
    VALUES (
        seq_logs_preus.NEXTVAL, 
        :OLD.producte_id, 
        :OLD.preu, 
        :NEW.preu, 
        SYSDATE
    );
END;
/

-- ============================================================================
-- CREACION DEL ESQUEMA COMPLETADA
-- Ejecutar test_data.sql a continuacion para insertar datos de prueba y verificar
-- ============================================================================
