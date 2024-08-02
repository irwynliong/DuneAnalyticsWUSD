with pool_tokens as(
    SELECT
        column1 as addr
    FROM
        unnest(array[0x83F20F44975D03b1b09e64809B757c47f942BEeA,0x9D39A5DE30e57443BfF2A8307A4256c8797A3497]) as t(column1)
),

pool_balance_changes as (
     SELECT
        date_trunc('hour', evt_block_time) as time,
        sum((
            CASE
                WHEN contract_address = 0x83F20F44975D03b1b09e64809B757c47f942BEeA
                THEN value / try_cast(1e18 as DOUBLE)
                ELSE 0
            END)
            *
            (CASE
                WHEN "to" = 0x167478921b907422f8e88b43c4af2b8bea278d3a then 1 else -1 
            END)) as sDAI,
        sum((
            case 
                when contract_address = 0x9D39A5DE30e57443BfF2A8307A4256c8797A3497
                then value / try_cast(1e18 as double)
                else 0
            end)
            *
            (case 
                when "to" = 0x167478921b907422f8e88b43c4af2b8bea278d3a then 1 else -1
            end)) as sUSDe
    FROM
        erc20_ethereum.evt_transfer
    WHERE
        contract_address in (SELECT addr from pool_tokens)
        AND
        ("to" = 0x167478921b907422f8e88b43c4af2b8bea278d3a
            OR
        "from" = 0x167478921b907422f8e88b43c4af2b8bea278d3a)
    group by 1
)




select 
    time,
    sum(sUSDe) over (order by time) as sUSDe,
    sum(sDAI) over (order by time) as sDAI,
    sum(sUSDe + sDAI) over (order by time) as total
from 
    pool_balance_changes
order by time desc