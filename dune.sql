-- table for fiat backing coins --
WITH erc20_fiat_stable_contracts_eth AS (
SELECT
    contract_address,
    decimals,
    symbol
FROM tokens.erc20
WHERE blockchain = 'ethereum'
AND contract_address IN (
    (0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48) /* USDC */,
    (0xdAC17F958D2ee523a2206206994597C13D831ec7) /* USDT */,
    (0x4Fabb145d64652a948d72533023f6E7A623C7C53) /* BUSD */,
    (0x8E870D67F660D95d5be530380D0eC0bd388289E1) /* PAX */,
    (0x056fd409e1d7a124bd7017459dfea2f387b6d5cd) /* GUSD */,
    (0x1c48f86ae57291f7686349f12601910bd8d470bb) /* USDK */,
    (0xdF574c24545E5FfEcb9a659c229253D4111d87e1) /* HUSD */,
    (0x59D9356E565Ab3A36dD77763Fc0d87fEaf85508C) /* USDM */,
    (0xb6667b04Cb61Aa16B59617f90FFA068722Cf21dA) /* WUSD */,
    (0x0000000000085d4780b73119b644ae5ecd22b376) /* TUSD */,
    (0x6c3ea9036406852006290770bedfcaba0e23a0e8) /* PYUSD */,
    (0xc5f0f7b66764f6ec8c8dff7ba683102295e16409 /* FDUSD */
)
)
),

-- table for collatoral backing coins --
erc20_colat_stable_contracts_eth AS (
SELECT
    contract_address,
    decimals,
    symbol
FROM tokens.erc20
WHERE blockchain = 'ethereum'
AND contract_address IN (
    (0x6b175474e89094c44da98b954eedeac495271d0f) /* DAI */,
    (0x5f98805A4E8be255a32880FDeC7F6728C6568bA0) /* LUSD */,
    (0x99D8a9C45b2ecA8864373A26D1459e3Dff1e17F3) /* MIM */,
    --(0x57ab1ec28d129707052df4df418d58a2d46d5f51) /* sUSD */,
    (0x70e8de73ce538da2beed35d14187f6959a8eca96) /* XSGD */,
    --(0x196f4727526eA7FB1e17b2071B3d8eAA38486988) /* RSV */,
    (0x865377367054516e17014ccded1e7d814edc9ce4) /* DOLA */,
    (0xb0b195aefa3650a6908f15cdac7d92f8a5791b0b) /* BOB */,
    (0x8d6cebd76f18e1558d4db88138e2defb3909fad6) /* MAI */,
    (0x0a5e677a6a24b2f1a2bf4f3bffc443231d2fdec8) /* USX */,
    (0x1B84765dE8B7566e4cEAF4D0fD3c5aF52D3DdE4F) /* nUSD */,
    (0xdf3ac4F479375802A821f7b7b46Cd7EB5E4262cC) /* eUSD */,
    (0xd7C9F0e536dC865Ae858b0C0453Fe76D13c3bEAc) /* XAI */,
    (0xe2f2a5C287993345a840Db3B0845fbC70f5935a5) /* mUSD */,
    (0xf939E0A03FB07F59A73314E73794Be0E57ac1b4E) /* crvUSD */,
    (0x6c3ea9036406852006290770BEdFcAbA0e23A0e8) /* PyUSD */,
    (0x4591DBfF62656E7859Afe5e45f6f47D3669fBB28) /* mkUSD */,
    (0x40D16FC0246aD3160Ccc09B8D0D3A2cD28aE6C2f) /* GHO */
)
),

-- table for algorithm backing coins --
erc20_algo_stable_contracts_eth AS (
SELECT
    contract_address,
    decimals,
    symbol
FROM tokens.erc20
WHERE blockchain = 'ethereum'
AND contract_address IN (
    (0xa47c8bf37f92aBed4A126BDA807A7b7498661acD) /* UST */,
    (0x853d955acef822db058eb8505911ed77f175b99e) /* FRAX */,
    (0x0c10bf8fcb7bf5412187a595ab97a3609160b5c6) /* USDD */,
    (0x956F47F50A910163D8BF957Cf5846D573E7f87CA) /* FEI */,
    (0xBC6DA0FE9aD5f3b0d58160288917AA56653660E9) /* ALUSD */
    --('0x674C6Ad92Fd080e4004b2312b45f796a192D27a0'), --USDN */
)
)
--,

--erc20_wusd_eth (category,contract_address,decimals,symbol) AS (
--VALUES
--    ('Fiat-collateralized', 0xb6667b04Cb61Aa16B59617f90FFA068722Cf21dA, 6, 'WUSD')) /* WUSD */


SELECT
    'Fiat-collateralized' AS category,
    contract_address,
    decimals,
    symbol
FROM erc20_fiat_stable_contracts_eth


--UNION ALL

--SELECT 'Fiat-collateralized' AS category,contract_address,decimals,symbol
--FROM erc20_wusd_eth

UNION ALL

SELECT
    'Crypto over-Collateralized' AS category,
    contract_address,
    decimals,
    symbol
FROM erc20_colat_stable_contracts_eth


UNION ALL

SELECT
    'Algorithmic' AS category,
    contract_address,
    decimals,
    symbol
FROM erc20_algo_stable_contracts_eth

-- WITH erc20_WUSD_contracts_eth AS (
-- SELECT
--     contract_address,
--     decimals,
--     symbol
-- FROM tokens.erc20
-- WHERE blockchain = 'ethereum'
-- AND contract_address IN (
--     (0xb6667b04Cb61Aa16B59617f90FFA068722Cf21dA) /* WUSD */
-- )
-- )

-- SELECT 
--     'Fiat-collateralized' AS category, contract_address, 
--     decimals, 
--     symbol
-- FROM erc20_WUSD_contracts_eth;

