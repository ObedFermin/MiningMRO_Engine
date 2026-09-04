USE Bunker_MRO;

-- 1. Ejecución de prueba con datos válidos
EXEC audit.sp_insert_mro_audit_log
    @ebeln = '4500100573',
    @ebelp = 20,
    @tipo_descalce = 'MAVERICK_BUYING',
    @fuga_usd = 334264.00,
    @estado_revision = 'EN_REVISION';

-- 2. Validar persistencia en la tabla de auditoría
SELECT TOP 5 * 
FROM audit.tb_log_anomalias_mro
ORDER BY id_anomalia DESC;