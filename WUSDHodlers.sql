-- WUSD constants --
WITH
  Constants AS (
    SELECT
      0xA04C86c411320444d4A99d44082e057772E8cF96 AS CONTRACT_ADDRESS,
      6 AS DECIMALS
  ),
  TransferBalances AS (
    SELECT
      "to" AS holder_address,
      SUM(value / POW(10, DECIMALS)) AS balance
    FROM
      erc20_polygon.evt_transfer tr
      LEFT JOIN Constants poly ON poly.CONTRACT_ADDRESS = tr.contract_address
    WHERE
      tr.contract_address IN (
        SELECT
          CONTRACT_ADDRESS
        FROM
          Constants
      )
    GROUP BY
      "to"
    UNION ALL
    SELECT
      "from" AS holder_address,
      - SUM(value / POW(10, DECIMALS)) AS balance
    FROM
      erc20_polygon.evt_transfer tr
      LEFT JOIN Constants poly ON poly.CONTRACT_ADDRESS = tr.contract_address
    WHERE
      tr.contract_address IN (
        SELECT
          CONTRACT_ADDRESS
        FROM
          Constants
      )
    GROUP BY
      "from"
  )
SELECT
  holder_address,
  SUM(balance) AS total_balance
FROM
  TransferBalances
GROUP BY
  holder_address
HAVING
  SUM(balance) > 0
ORDER BY
  total_balance DESC
LIMIT
  100
