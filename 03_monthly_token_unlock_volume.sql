-- Monthly Token Unlock Volume Summary
-- Groups all unlock events by month so we can see how much supply enters each month
-- Uses DATE_TRUNC which is the correct DuneSQL / Trino syntax for month bucketing
-- Useful for planning around months with especially heavy supply releases

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

-- Get the most recent token price for USD valuation
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
    -- DATE_TRUNC buckets each date into its month start (Trino/DuneSQL syntax)
    DATE_TRUNC('month', u.unlock_date)          AS unlock_month,
    COUNT(DISTINCT u.project)                   AS num_projects_unlocking,
    SUM(u.tokens_unlocked)                      AS total_tokens_unlocked,
    ROUND(SUM(u.tokens_unlocked * COALESCE(p.price, 0)), 2) AS total_unlock_value_usd
FROM unlock_schedule u
LEFT JOIN latest_prices p
    ON p.symbol = u.symbol
    AND p.rn = 1
GROUP BY DATE_TRUNC('month', u.unlock_date)
ORDER BY unlock_month ASC
