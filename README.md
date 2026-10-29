# Shopee Sales Analysis

## Project Overview

This project analyzes 12 months of order data from my Shopee store, covering October 2025 to September 2026.

The goal is to understand sales performance and support practical store decisions while practicing the complete data analysis workflow: data preparation, SQL analysis, and visualization.

## Tools

| Tool | Use |
|---|---|
| Python and Pandas | Read, combine, inspect, and clean monthly order files |
| SQLite and SQL | Store prepared data and calculate business metrics |
| Tableau | Visualize sales performance and analysis results |

## Repository Structure

- `scripts/`: Python scripts for data preparation and validation.
- `sql/`: SQL queries for sales summaries, campaign comparisons, and restocking analysis.
- `data/`: Prepared data, product mapping files, and the SQLite database.
- `outputs/`: Exported CSV results from the analysis.

## Data Notes

The source data contains product-level order line items. One order can appear in multiple rows, so order counts use distinct order IDs.

Original order exports and the intermediate file containing buyer accounts are excluded from this repository. Order and buyer IDs in the prepared sales data have been recoded.
