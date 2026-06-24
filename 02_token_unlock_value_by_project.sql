-- Token Unlock Value by Project - Aggregated
-- Rolls up all unlock events per project so we can rank which ones unlock the most tokens
-- Also shows pct of total so you know each project's share of upcoming supply

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
),

unlock_with_value AS (
    SELECT
        u.project,
        u.symbol,
        u.tokens_unlocked,
        COALESCE(p.price, 0)                        AS token_price_usd,
        u.tokens_unlocked * COALESCE(p.price, 0)   AS unlock_value_usd
    FROM unlock_schedule u
    LEFT JOIN latest_prices p
        ON p.symbol = u.symbol
        AND p.rn = 1
)

SELECT
    project,
    symbol,
    SUM(tokens_unlocked)                            AS total_unlock_tokens,
    ROUND(AVG(token_price_usd), 4)                  AS avg_token_price_usd,
    ROUND(SUM(unlock_value_usd), 2)                 AS total_unlock_value_usd,
    ROUND(
        100.0 * SUM(tokens_unlocked) /
        NULLIF(SUM(SUM(tokens_unlocked)) OVER (), 0),
        2
    )                                               AS pct_of_total_tokens
FROM unlock_with_value
GROUP BY project, symbol
ORDER BY total_unlock_tokens DESC
