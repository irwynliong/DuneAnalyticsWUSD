SELECT
    evt_block_time AS transaction_time,
    "from" AS sender,
    "to" AS recipient,
    value / POW(10, 6) AS amount,
    evt_tx_hash AS transaction_hash
FROM
    erc20_polygon.evt_transfer AS tr
WHERE
    tr.contract_address = {{crypto}}
    AND (
        "from" = {{wallet_address}}
        OR "to" = {{wallet_address}}
    )
ORDER BY
    evt_block_time DESC