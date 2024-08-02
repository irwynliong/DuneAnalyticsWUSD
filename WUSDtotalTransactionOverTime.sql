WITH TransferData AS (
  SELECT
    date(DATE_TRUNC('{{time interval}}', evt_block_time)) AS dt,
    COUNT("from") as total_transactions
  FROM
    erc20_polygon.evt_transfer
  WHERE
    contract_address = 0xA04C86c411320444d4A99d44082e057772E8cF96
    AND evt_block_time >= CAST('2022-08-06' AS TIMESTAMP)
    AND "from" != 0x0000000000000000000000000000000000000000
    AND "to" != 0x0000000000000000000000000000000000000000
  GROUP BY 1
)
SELECT
  T.dt,
  T.total_transactions,
  SUM(T.total_transactions) OVER (ORDER BY T.dt ASC) AS cumulative_total_transactions
FROM TransferData T
ORDER BY T.dt DESC