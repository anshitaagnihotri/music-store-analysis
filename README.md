# Music Store Customer & Revenue Analysis (SQL)

Analysis of a digital music store using SQL on the Chinook database. The project answers 15 business questions about customers, the music catalogue, sales and revenue patterns.

## Business Problem

A digital music store wants to understand its customers, music catalogue, sales and revenue patterns so it can decide where to focus marketing, which catalogue to promote and which customers to retain.

## Dataset

- **Chinook database** (SQLite), source: https://github.com/lerocha/chinook-database
- File in this repo: `chinook.db`
- Size: 59 customers from 24 countries, 614 invoices, 3,503 tracks, 275 artists
- Period covered: January 2017 to December 2020
- Revenue is calculated as `invoice_line.unit_price * invoice_line.quantity`

## Database Setup

The database ships as a single SQLite file, so no import is needed.

1. Clone the repo: `git clone https://github.com/anshitaagnihotri/music-store-analysis.git`
2. Open the folder in VS Code.
3. Install the **SQLTools** and **SQLTools SQLite** extensions (SQLTools needs Node.js; enable `sqltools.useNodeRuntime`).
4. Add a new SQLite connection and point it to `chinook.db`.
5. Open `sql/03_analysis.sql`, select a query and run it with **Run on active connection**.

Alternative: run any query from the command line with `sqlite3 chinook.db < sql/03_analysis.sql`.

## Schema Overview

```
artist -> album -> track -> invoice_line -> invoice -> customer -> employee (support_rep_id)
track -> genre
track -> media_type
```

| Table | Purpose |
|---|---|
| customer | Customer details and country, linked to a support employee |
| invoice / invoice_line | Each bill and the tracks sold on it (price and quantity) |
| track / album / artist / genre | Music catalogue |
| employee | Support representatives |

## Business Questions

1. What is the total revenue?
2. Which countries generate the highest revenue?
3. Who are the top 10 customers by spending?
4. Which artists generate the highest revenue?
5. Which genres are most popular?
6. Which albums generate the highest sales?
7. Which tracks have been purchased most frequently?
8. What is the average customer spending?
9. Which customers have never made a purchase?
10. Which employees support the highest-value customers?
11. What percentage of revenue comes from each country?
12. Which genre generates the highest revenue?
13. What is the monthly or annual revenue trend?
14. Which artists have the largest number of tracks?
15. Which customers have spending above average?

## SQL Concepts Used

- Multi-table JOINs (up to 5 tables) and LEFT JOIN with NULL filtering
- Aggregation with GROUP BY
- Subqueries and CTEs
- CASE expressions
- Window functions (`RANK`, `LAG`, `SUM() OVER`)
- Ranking
- Date functions (`strftime`)
- String concatenation

## Queries

All queries, with a short insight under each one, are in [`sql/03_analysis.sql`](sql/03_analysis.sql).

## Key Findings

- **Total revenue is 4,709.43** across 614 invoices (average invoice about 7.67).
- **USA is the largest market** at 22.09% of revenue, then Canada (11.37%) and Brazil (9.08%). The top 3 countries make up about 42.5%.
- **Top customers are not from the biggest market.** The two highest spenders are from the Czech Republic (144.54 and 128.70). The top 10 customers make up about 23.7% of revenue.
- **Rock dominates the catalogue.** It accounts for about 55% of units sold and revenue (2,608.65), well ahead of Metal (612.81) and Alternative & Punk (487.08).
- **Top artists** are Queen (190.08) and Jimi Hendrix (185.13). The best-selling album is Jimi Hendrix's "Are You Experienced?" (185.13), and the most purchased track is "War Pigs" (31 purchases, more than double the next track).
- **Average customer spending is 79.82.** 25 of 59 customers spend above average and 13 of them are "High Value".
- **All 59 customers have purchased at least once.** There is no never-purchased segment.
- **Support reps are fairly balanced.** Jane Peacock supports the highest-value customers (1,731.51 from 21 customers), followed by Margaret Park (1,584.00) and Steve Johnson (1,393.92).
- **Revenue is flat year over year** (about 1,140 to 1,220 per year) and monthly revenue is volatile, with no clear seasonality.
- **A large catalogue does not guarantee sales.** Iron Maiden has the most tracks (213) but ranks only 20th by revenue.

## Recommendations

1. **Focus marketing on USA, Canada and Brazil**, which bring about 42% of revenue, and test small campaigns in mid-sized markets such as France and Germany.
2. **Run loyalty offers for the 25 above-average customers**, starting with the 13 High Value ones, since they are the most valuable accounts.
3. **Promote rock and metal bundles**, because these genres drive most sales. Test promotions for Latin and R&B/Soul to see if the smaller genres can grow.
4. **Feature proven hits and best-selling albums** (such as "War Pigs" and "Are You Experienced?") in recommendations and homepage placement.
5. **Fix the flat growth.** Revenue has not grown across four years, so the store should look at new acquisition channels and seasonal promotions, especially around the weak months.
6. **Review the catalogue of low performers.** Artists with many tracks but low revenue (for example Iron Maiden) may need better promotion or pricing.

## Conclusion

The store has a stable but non-growing business with a strong dependence on rock music and a handful of markets. Customer value is spread widely instead of concentrated in a few big spenders, and no customer is inactive. The best opportunities are retaining and rewarding the 25 above-average customers, growing the top markets and promoting the proven hits, while testing new channels to break the flat revenue trend.

## Project Structure

```
music-store-analysis/
├── chinook.db
├── sql/
│   └── 03_analysis.sql
├── README.md
└── .gitignore
```

## Tools

SQLite, SQL, VS Code (SQLTools), Git and GitHub.
