select date, symbol, send_amount,sum(coalesce(send_amount, 0)) over(partition by symbol order by date) as cum_vol from query_3429936
-- query_3429936 = WUSDvolOverview
-- active address, WUSD burned/minted not available
