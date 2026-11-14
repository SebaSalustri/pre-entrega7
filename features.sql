
WITH parametros AS (
    SELECT DATE '2025-01-01' AS fecha_corte
),

-- Compras anteriores a la fecha de corte
compras_validas AS (
    SELECT
        pedido_id,
        usuario_id,
        CAST(fecha AS DATE) AS fecha,
        CAST(monto AS DOUBLE) AS monto
    FROM compras
    CROSS JOIN parametros
    WHERE CAST(fecha AS DATE) < fecha_corte
),

-- Calcular Recency, Frequency y Monetary
rfm AS (
    SELECT
        u.usuario_id,

        DATE_DIFF(
            'day',
            MAX(c.fecha),
            p.fecha_corte
        ) AS recency,

        COUNT(DISTINCT c.pedido_id) AS frequency,

        COALESCE(SUM(c.monto), 0) AS monetary

    FROM usuarios u

    CROSS JOIN parametros p

    LEFT JOIN compras_validas c
        ON u.usuario_id = c.usuario_id

    GROUP BY u.usuario_id, p.fecha_corte
),

-- Generar los meses del periodo analizado
meses AS (
    SELECT mes
    FROM generate_series(
        DATE '2024-10-01',
        DATE '2024-12-01',
        INTERVAL '1 month'
    ) AS t(mes)
),

-- Calcular el gasto mensual por usuario
gasto_mensual AS (
    SELECT
        u.usuario_id,
        m.mes,

        COALESCE(SUM(c.monto), 0) AS gasto

    FROM usuarios u

    CROSS JOIN meses m

    LEFT JOIN compras_validas c
        ON u.usuario_id = c.usuario_id
        AND DATE_TRUNC('month', c.fecha) = m.mes

    GROUP BY u.usuario_id, m.mes
),

-- Calcular el promedio historico
tendencia AS (
    SELECT
        usuario_id,
        mes,
        gasto,

        AVG(gasto) OVER (
            PARTITION BY usuario_id
            ORDER BY mes
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND 1 PRECEDING
        ) AS promedio_historico

    FROM gasto_mensual
)

-- Tabla final de features
SELECT
    r.usuario_id,
    r.recency,
    r.frequency,
    ROUND(r.monetary, 2) AS monetary,

    ROUND(
        COALESCE(
            t.gasto - t.promedio_historico,
            0
        ),
        2
    ) AS trend

FROM rfm r

LEFT JOIN tendencia t
    ON r.usuario_id = t.usuario_id
    AND t.mes = DATE '2024-12-01'

ORDER BY r.usuario_id;
