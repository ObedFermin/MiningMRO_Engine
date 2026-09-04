/* ======================================================================================
   PROYECTO   : Mining MRO Analytics Engine
   MODULO     : 04_stored_procedures
   OBJETO     : audit.sp_insert_mro_audit_log
   ESTANDAR   : ANSI SQL / T-SQL 2022
   DESCRIPCION: Procedimiento transaccional con aislamiento ACID para persistir hallazgos
                de auditoría forense en audit.tb_log_anomalias_mro.
   ====================================================================================== */

CREATE OR ALTER PROCEDURE audit.sp_insert_mro_audit_log
    @ebeln           VARCHAR(20),
    @ebelp           INT,
    @tipo_descalce   VARCHAR(50),
    @fuga_usd        DECIMAL(18,2),
    @estado_revision VARCHAR(20) = 'PENDIENTE'
AS
BEGIN
    SET NOCOUNT ON;

    -- Manejo transaccional defensivo
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validación de parámetros de entrada
        IF @ebeln IS NULL OR @ebelp IS NULL OR @tipo_descalce IS NULL
        BEGIN
            THROW 50001, 'Error: Parámetros clave no pueden ser nulos al registrar anomalía.', 1;
        END;

        -- Inserción del registro auditado
        INSERT INTO audit.tb_log_anomalias_mro (
            ebeln,
            ebelp,
            tipo_descalce,
            fuga_usd,
            fecha_deteccion,
            estado_revision
        )
        VALUES (
            @ebeln,
            @ebelp,
            @tipo_descalce,
            @fuga_usd,
            SYSDATETIME(),
            @estado_revision
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Reversa atómica si ocurre cualquier conflicto
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        -- Propagación estandarizada de la excepción
        THROW;
    END CATCH;
END;