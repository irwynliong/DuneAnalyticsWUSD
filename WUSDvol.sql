WITH erc20_stable_contracts_eth AS (
SELECT
    *
FROM query_3427481
WHERE symbol = 'WUSD'
),
-- contract_address decimals symbol
data AS (
SELECT
    time,
    contract_address,
    SUM(CAST(amounts AS DOUBLE)) AS supply
FROM (
SELECT
    DATE_TRUNC('day', evt_block_time) AS time,
    eth.contract_address,
    -SUM(value/POW(10, decimals)) AS amounts
FROM erc20_ethereum.evt_Transfer AS tr
LEFT JOIN erc20_stable_contracts_eth AS eth ON eth.contract_address = tr.contract_address
WHERE tr.contract_address IN (
SELECT contract_address FROM erc20_stable_contracts_eth
)
AND "to" = 0x0000000000000000000000000000000000000000
GROUP BY 1,2

UNION ALL

SELECT
    DATE_TRUNC('day', evt_block_time) AS time,
    eth.contract_address,
    SUM(value/POW(10, decimals)) AS amounts
FROM erc20_ethereum.evt_Transfer AS tr
LEFT JOIN erc20_stable_contracts_eth AS eth ON eth.contract_address = tr.contract_address
WHERE tr.contract_address IN (
SELECT contract_address FROM erc20_stable_contracts_eth
)
AND "from" = 0x0000000000000000000000000000000000000000
GROUP BY 1,2

UNION ALL

SELECT
    DATE_TRUNC('day', evt_block_time) AS time,
    eth.contract_address,
    -SUM(value/POW(10, decimals)) AS amounts
FROM erc20_ethereum.evt_Transfer AS tr
LEFT JOIN erc20_stable_contracts_eth AS eth ON eth.contract_address = tr.contract_address
WHERE tr.contract_address IN (
SELECT contract_address FROM erc20_stable_contracts_eth
WHERE symbol = 'USDT'
)
AND "to" = 0xc6cde7c39eb2f0f0095f41570af89efc2c1ea828 -- what is this address?
GROUP BY 1,2

UNION ALL

SELECT
    DATE_TRUNC('day', evt_block_time) AS time,
    eth.contract_address,
    SUM(value/POW(10, decimals)) AS amounts
FROM erc20_ethereum.evt_Transfer AS tr
LEFT JOIN erc20_stable_contracts_eth AS eth ON eth.contract_address = tr.contract_address
WHERE tr.contract_address IN (
SELECT contract_address FROM erc20_stable_contracts_eth
WHERE symbol = 'USDT'
)
AND "from" = 0xc6cde7c39eb2f0f0095f41570af89efc2c1ea828
GROUP BY 1,2

---wusd---

UNION ALL

SELECT
    DATE_TRUNC('day', evt_block_time) AS time,
    eth.contract_address,
    -SUM(value/POW(10, decimals)) AS amounts
FROM erc20_ethereum.evt_Transfer AS tr
LEFT JOIN erc20_stable_contracts_eth AS eth ON eth.contract_address = tr.contract_address
WHERE tr.contract_address IN (
SELECT contract_address FROM erc20_stable_contracts_eth
WHERE symbol = 'WUSD'
)
AND "to" = 0x565bddE673A91BBaf13E9E08F3D023980e5a2F77 -- what is this address
GROUP BY 1,2

UNION ALL

SELECT
    DATE_TRUNC('day', evt_block_time) AS time,
    eth.contract_address,
    SUM(value/POW(10, decimals)) AS amounts
FROM erc20_ethereum.evt_Transfer AS tr
LEFT JOIN erc20_stable_contracts_eth AS eth ON eth.contract_address = tr.contract_address
WHERE tr.contract_address IN (
SELECT contract_address FROM erc20_stable_contracts_eth
WHERE symbol = 'WUSD'
)
AND "from" = 0x565bddE673A91BBaf13E9E08F3D023980e5a2F77
GROUP BY 1,2


--wusd----
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
CROSS JOIN erc20_stable_contracts_eth
) AS tt
GROUP BY time, contract_address
),

data_volume AS (
SELECT  
    DATE_TRUNC('day', evt_block_time) AS time,
    eth.contract_address,
    SUM(ABS(value/POW(10, decimals))) AS send_amount
FROM erc20_ethereum.evt_Transfer tr
LEFT JOIN erc20_stable_contracts_eth eth ON eth.contract_address = tr.contract_address
WHERE tr.contract_address IN (SELECT contract_address FROM erc20_stable_contracts_eth)
AND DATE(evt_block_time)  >= DATE(NOW()) - interval '2' YEAR
AND "from" != 0x0000000000000000000000000000000000000000
AND "to" != 0x0000000000000000000000000000000000000000
GROUP BY 1,2
),
-- exclude mint and burn, total volume of tokens sent per day for each contract address over the past two years
stable_over_time as (
select 
    time as date,
    contract_address,
    sum(coalesce(supply, 0)) over(partition by contract_address order by time) as TVL_eth
from data
)

SELECT
    *,
    AVG(velocity) OVER (partition by symbol ORDER BY date ASC ROWS BETWEEN 30 PRECEDING AND CURRENT ROW) as ma30_velocity
FROM (
select 
    date, 
    symbol,
    
    TVL_eth,
    
    send_amount,
    send_amount/TVL_eth AS velocity
from stable_over_time
left join data_volume ON date = time and stable_over_time.contract_address = data_volume.contract_address
left join erc20_stable_contracts_eth ON stable_over_time.contract_address = erc20_stable_contracts_eth.contract_address
)gg
WHERE date >= DATE(NOW()) - interval '1' YEAR