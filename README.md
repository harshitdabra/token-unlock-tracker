# Token Unlock Tracker

SQL queries and dashboard built on [Dune Analytics](https://dune.com/harshit_dabra/token-unlock-tracker) to track upcoming token unlock events across 10 major crypto projects for the next 90 days.

Live dashboard: https://dune.com/harshit_dabra/token-unlock-tracker

## Projects Tracked

ARB, OP, APT, SUI, WLD, TIA, STRK, SEI, DYDX, BLUR

## Queries

| File | Description |
|------|-------------|
| 01_token_unlock_schedule_next_90_days.sql | Daily unlock events with dates, token amounts, and live USD values |
| 02_token_unlock_value_by_project.sql | Aggregated totals per project with % share of upcoming supply |
| 03_monthly_token_unlock_volume.sql | Month-by-month unlock volume summary (Jul, Aug, Sep 2026) |

## Tech Stack

- DuneSQL (Trino dialect)
- prices.usd for live token price data
- Visualizations: bar charts, donut chart

## About

Built by [Harshit Dabra](https://dune.com/harshit_dabra).
