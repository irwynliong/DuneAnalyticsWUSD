-- query_3894451 gives the token.erc20 data for WUSD and USDT
WITH constants AS (
SELECT
    *
FROM query_3894451
WHERE symbol = 'WUSD'
),

-- burned WUSD function --
data AS (
SELECT
    time,
    contract_address,
    SUM(CAST(amounts AS DOUBLE)) AS supply
FROM (
SELECT
    DATE_TRUNC('day', evt_block_time) AS time,
    c.contract_address,
    -SUM(value/POW(10, decimals)) AS amounts
FROM erc20_polygon.evt_transfer AS tr
LEFT JOIN constants AS c ON c.contract_address = tr.contract_address
WHERE tr.contract_address IN (
SELECT contract_address FROM constants
)
AND "to" = 0x0000000000000000000000000000000000000000
GROUP BY 1,2

UNION ALL

-- Minted WUSD function --
SELECT
    DATE_TRUNC('day', evt_block_time) AS time,
    c.contract_address,
    SUM(value/POW(10, decimals)) AS amounts
FROM erc20_polygon.evt_transfer AS tr
LEFT JOIN constants AS c ON c.contract_address = tr.contract_address
WHERE tr.contract_address IN (
SELECT contract_address FROM constants
)
AND "from" = 0x0000000000000000000000000000000000000000
GROUP BY 1,2

UNION ALL

-- USDT deployer --
SELECT
    DATE_TRUNC('day', evt_block_time) AS time,
    c.contract_address,
    -SUM(value/POW(10, decimals)) AS amounts
FROM erc20_polygon.evt_transfer AS tr
LEFT JOIN constants AS c ON c.contract_address = tr.contract_address
WHERE tr.contract_address IN (
SELECT contract_address FROM constants
WHERE symbol = 'USDT'
)
AND "to" = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F
GROUP BY 1,2

UNION ALL

SELECT
    DATE_TRUNC('day', evt_block_time) AS time,
    c.contract_address,
    SUM(value/POW(10, decimals)) AS amounts
FROM erc20_polygon.evt_transfer AS tr
LEFT JOIN constants AS c ON c.contract_address = tr.contract_address
WHERE tr.contract_address IN (
SELECT contract_address FROM constants
WHERE symbol = 'USDT'
)
AND "from" = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F
GROUP BY 1,2

UNION ALL

-- WUSD deployer --
SELECT
    DATE_TRUNC('day', evt_block_time) AS time,
    c.contract_address,
    -SUM(value/POW(10, decimals)) AS amounts
FROM erc20_polygon.evt_transfer AS tr
LEFT JOIN constants AS c ON c.contract_address = tr.contract_address
WHERE tr.contract_address IN (
SELECT contract_address FROM constants
WHERE symbol = 'WUSD'
)
AND "to" = 0x62e6C0d094e9d1fE0606b57379d76141D1e98cB7
GROUP BY 1,2

UNION ALL

SELECT
    DATE_TRUNC('day', evt_block_time) AS time,
    c.contract_address,
    SUM(value/POW(10, decimals)) AS amounts
FROM erc20_polygon.evt_transfer AS tr
LEFT JOIN constants AS c ON c.contract_address = tr.contract_address
WHERE tr.contract_address IN (
SELECT contract_address FROM constants
WHERE symbol = 'WUSD'
)
AND "from" = 0x62e6C0d094e9d1fE0606b57379d76141D1e98cB7
GROUP BY 1,2

UNION ALL

SELECT
    time,
    contract_address,
    NULL AS amounts
FROM (
    with weeks_seq as (
        SELECT sequence(DATE('2017-01-01'), DATE(NOW()), interval '1' DAY) AS time
    )
            
    SELECT 
        days.time
    FROM weeks_seq
    CROSS JOIN unnest(time) as days(time)
)
CROSS JOIN constants
) AS tt
GROUP BY time, contract_address
),

data_volume AS (
SELECT  
    DATE_TRUNC('day', evt_block_time) AS time,
    c.contract_address,
    SUM(ABS(value/POW(10, decimals))) AS send_amount
FROM erc20_polygon.evt_transfer tr
LEFT JOIN constants c ON c.contract_address = tr.contract_address
WHERE tr.contract_address IN (SELECT contract_address FROM constants)
AND DATE(evt_block_time)  >= DATE(NOW()) - interval '2' YEAR
AND "from" != 0x0000000000000000000000000000000000000000
AND "to" != 0x0000000000000000000000000000000000000000
GROUP BY 1,2
),

stable_over_time as (
select 
    time as date,
    contract_address,
    sum(coalesce(supply, 0)) over(partition by contract_address order by time) as TVL_poly
from data
)

SELECT
    *,
    AVG(velocity) OVER (partition by symbol ORDER BY date ASC ROWS BETWEEN 30 PRECEDING AND CURRENT ROW) as ma30_velocity
FROM (
SELECT
    date, 
    symbol,

    TVL_poly,
    
    send_amount,
    send_amount/TVL_poly AS velocity
from stable_over_time
left join data_volume ON date = time and stable_over_time.contract_address = data_volume.contract_address
left join constants ON stable_over_time.contract_address = constants.contract_address
)gg
WHERE date >= DATE(NOW()) - interval '1' YEAR