-- Token Unlock Schedule - Next 90 Days
-- Shows each upcoming unlock event with date, project, token, amount and live USD value
-- Pulling from hardcoded schedule joined with real-time price data from prices.usd

WITH unlock_schedule AS (
    SELECT 'Arbitrum' AS project, 'ARB' AS symbol, TIMESTAMP '2026-07-10 00:00:00' AS unlock_date, 92000000 AS tokens_unlocked
    UNION ALL SELECT 'Optimism',  'OP',   TIMESTAMP '2026-07-15 00:00:00', 38500000
    UNION ALL SELECT 'Aptos',     'APT',  TIMESTAMP '2026-07-18 00:00:00', 24000000
    UNION ALL SELECT 'Sui',       'SUI',  TIMESTAMP '2026-07-20 00:00:00', 64000000
    UNION ALL SELECT 'Worldcoin', 'WLD',  TIMESTAMP '2026-07-22 00:00:00', 15000000
    UNION ALL SELECT 'Celestia',  'TIA',  TIMESTAMP '2026-07-25 00:00:00', 30000000
    UNION ALL SELECT 'StarkNet',  'STRK', TIMESTAMP '2026-07-28 00:00:00', 55000000
    UNION ALL SELECT 'Sei',       'SEI',  TIMESTAMP '2026-07-30 00:00:00', 28000000
    UNION ALL SELECT 'dYdX',      'DYDX', TIMESTAMP '2026-08-01 00:00:00', 112000000
    UNION ALL SELECT 'Blur',      'BLUR', TIMESTAMP '2026-08-05 00:00:00', 47000000
    UNION ALL SELECT 'Arbitrum',  'ARB',  TIMESTAMP '2026-08-08 00:00:00', 88000000
    UNION ALL SELECT 'Optimism',  'OP',   TIMESTAMP '2026-08-12 00:00:00', 41000000
    UNION ALL SELECT 'Aptos',     'APT',  TIMESTAMP '2026-08-15 00:00:00', 22000000
    UNION ALL SELECT 'Sui',       'SUI',  TIMESTAMP '2026-08-18 00:00:00', 59000000
    UNION ALL SELECT 'Worldcoin', 'WLD',  TIMESTAMP '2026-08-22 00:00:00', 13000000
    UNION ALL SELECT 'Celestia',  'TIA',  TIMESTAMP '2026-08-25 00:00:00', 27000000
    UNION ALL SELECT 'StarkNet',  'STRK', TIMESTAMP '2026-08-28 00:00:00', 49000000
    UNION ALL SELECT 'Sei',       'SEI',  TIMESTAMP '2026-09-01 00:00:00', 31000000
    UNION ALL SELECT 'dYdX',      'DYDX', TIMESTAMP '2026-09-05 00:00:00', 105000000
    UNION ALL SELECT 'Blur',      'BLUR', TIMESTAMP '2026-09-08 00:00:00', 44000000
    UNION ALL SELECT 'Arbitrum',  'ARB',  TIMESTAMP '2026-09-10 00:00:00', 76000000
),

-- Latest price per token from the last 2 hours
latest_prices AS (
    SELECT
        symbol,
        price,
        ROW_NUMBER() OVER (PARTITION BY symbol ORDER BY minute DESC) AS rn
    FROM prices.usd
    WHERE
        symbol IN ('ARB', 'OP', 'APT', 'SUI', 'WLD', 'TIA', 'STRK', 'SEI', 'DYDX', 'BLUR')
        AND blockchain IS NOT NULL
        AND minute >= NOW() - INTERVAL '2' HOUR
)

SELECT
    u.unlock_date,
    u.project,
    u.symbol,
    u.tokens_unlocked,
    ROUND(p.price, 4)                               AS token_price_usd,
    ROUND(u.tokens_unlocked * COALESCE(p.price, 0), 2) AS unlock_value_usd
FROM unlock_schedule u
LEFT JOIN latest_prices p
    ON p.symbol = u.symbol
    AND p.rn = 1
ORDER BY u.unlock_date ASC
