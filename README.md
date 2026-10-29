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

## Sales Overview

**Business question:** How did sales change over the year, which products contributed most to sales, and how did sales and shipping choices vary by day type?

### Approach

- Analyzed orders from October 2025 to September 2026.
- Calculated sales from item transaction prices and quantities, and counted distinct order IDs to avoid double-counting orders with multiple line items.
- Compared monthly sales, order counts, average order value, and estimated return value.
- Compared campaign and regular days in SQL using daily averages, including days with no sales.
- Examined product-category sales shares and shipping-method shares. For the weekday/weekend comparison reported below, campaign dates are classified first; remaining dates are divided into Monday–Friday and Saturday–Sunday. This additional comparison was checked against the SQLite database; it is not included in the saved campaign-comparison SQL output.
- Used 36 campaign days, 237 non-campaign weekdays, and 92 non-campaign weekend days for the daily sales averages. The campaign calendar follows the store-defined rules used in this project, rather than a comprehensive official Shopee calendar.

### Key Findings

- Sales before returns totaled **NT$1,059,716** across **2,938 orders**, with an average order value of **NT$361**.
- Monthly sales peaked at **NT$119,507 in May 2026**, compared with an average of **NT$88,310 per month**.
- Campaign days recorded the highest average daily sales at **NT$4,113.92**, followed by non-campaign weekdays at **NT$2,817.63**. Non-campaign weekends had the lowest average at **NT$2,650.39**.
- **Shopee Pickup (64.5%)** and **Shopee Next-Day Pickup (27.8%)** were the two main shipping methods. Next-day pickup accounted for a larger share of non-campaign weekday orders (**35.2%**) than campaign-day (**22.5%**) or non-campaign weekend orders (**10.4%**). Other Shipping represented **6.8%** of campaign-day orders, compared with **3.3%** on non-campaign weekdays and **4.2%** on non-campaign weekends.
- **Monk Fruit Sweeteners**, including the commercial-use product, contributed **88.3% of total sales**, indicating a strong concentration in this product category.

Shipping percentages are based on distinct orders within each group. Sales shares are based on sales before returns. These results describe historical patterns rather than causal effects.

### Metric Definitions

- **Sales Before Returns:** Item sales after seller-funded campaign discounts, before returns and platform fees, excluding shipping. This metric is named `gross_sales` in the SQL outputs.
- **Average Order Value:** Sales before returns divided by distinct orders.
- **Estimated Return Value:** Returned quantities multiplied by item transaction prices. This is not a verified refund amount and is attributed to the original order date.

### Explore the Analysis

- [Interactive Sales Overview dashboard](https://public.tableau.com/app/profile/yang.sheng.lin/viz/ShopeeSalesOverview/SalesOverview)
- [Monthly sales SQL](sql/01_sales_summary.sql)
- [Campaign comparison SQL](sql/02_campaign_comparison.sql)
- [Monthly sales results](outputs/monthly_sales_summary.csv)
- [Campaign comparison results](outputs/campaign_comparison.csv)

## Business Case: Monk Fruit Sweetener Restocking

**Business question:** What practical replenishment rule could help the store prepare for sales during a three-day replenishment buffer?

### Business Context

The restocking analysis focuses on the product labeled 羅漢果糖 in the dataset, excluding the commercial-use product. It appeared in **2,687 distinct orders**, representing approximately **91.5% of all store orders**, making it the priority for stock planning. This product scope is narrower than the Monk Fruit Sweeteners category used in the sales overview.

Supplier replenishment usually arrives within two days, based on store experience. The analysis used a three-day buffer and compared two fulfillment scenarios: supplying all orders during the period, or allowing non-urgent orders on day three to wait until replenishment on day four.

### Approach

1. **Standardized product variants into stock units.** A 220g pack counts as one unit. Two 100g packs also count as one unit under the store's substitution practice; this is an operational equivalence, not equal weight.
2. **Built a complete daily calendar.** Included zero-sales days and separated quantities by shipping method and campaign type.
3. **Identified urgent orders.** Orders using **Shopee Next-Day Pickup** were classified as urgent.
4. **Compared 363 complete, overlapping three-day windows.** Calculated average, 95th-percentile (P95), and maximum stock requirements under both scenarios. P95 uses the nearest-rank method.
5. **Translated the results into a simple trial rule** using the supplier's carton sizes.

### Key Findings

- Recorded sales totaled **4,555 stock units** before returns. Urgent shipping accounted for **34.86%** of these units.
- Allowing day-three non-urgent orders to wait reduced the historical P95 requirement from **60 to 50 units**, a **16.7% reduction**.
- The maximum observed requirement fell from **74 to 63 units**.

| Three-day fulfillment scenario | Average units | P95 units | Maximum units |
|---|---:|---:|---:|
| Supply all orders | 37.37 | 60 | 74 |
| Days 1–2: all orders; day 3: urgent orders only | 29.31 | 50 | 63 |

### Proposed Trial Rule

After completing daily shipments, **order 256 × 220g packs when available stock is 64 stock units or fewer and no replenishment is already in transit**.

For 220g packs, the 64-unit trigger corresponds to half a large carton and exceeds the adjusted historical maximum of 63 units. Each large carton contains 128 packs, so the order quantity of 256 packs corresponds to two large cartons. Inventory comparisons use the stock-unit conversion described above.

This rule assumes that eligible non-urgent orders on day three can wait until day four and still meet their shipping deadlines.

### Limitations and Next Steps

- Past stockouts may have suppressed recorded sales, so observed sales may understate demand.
- The rolling windows overlap and are not independent observations.
- Daily checks can detect stock only after it has fallen below the trigger. Replenishment delays may also extend the period that available stock must cover.
- The rule has not been validated through a full inventory simulation. Historical P95 values do not guarantee future stock availability.

The next step is to track actual inventory, delivery lead times, and stockouts to evaluate and refine the rule.

### Explore the Analysis

- [Interactive Restocking Plan dashboard](https://public.tableau.com/app/profile/yang.sheng.lin/viz/restockinganalysis-workingdraft/MonkFruitSweetenerRestockingPlan)
- [Analysis table preparation SQL](sql/00_prepare_analysis_tables.sql)
- [Restocking analysis SQL](sql/03_restocking_analysis.sql)
- [Fulfillment scenario comparison](outputs/restocking_scenario_comparison.csv)
- [Daily sales and urgent shipping results](outputs/daily_demand_by_day_type.csv)
- [Detailed results by weekday and campaign window](outputs/three_day_stock_by_day_type.csv)

## Repository Structure

- `scripts/`: Python scripts for data preparation and validation.
- `sql/`: SQL queries for sales summaries, campaign comparisons, and restocking analysis.
- `data/`: Prepared data, product mapping files, and the SQLite database.
- `outputs/`: Exported CSV results from the analysis.


## Data and Reproducibility Notes

- The dataset contains **3,086 product-level order line items** across **2,938 distinct orders**. Multiple rows can belong to the same order.
- Original order exports and the intermediate file containing buyer accounts are excluded from this repository. Order and buyer IDs in the prepared sales data have been recoded. Recoding preserves record relationships and does not make the transaction-level data fully anonymous.
- Monthly sales results contain a `Total` row, which must be excluded when plotting monthly trends or summing monthly records. The campaign comparison contains both `All Campaign Days` and its component categories; these rows must not be summed together.
- SQL files preserve the saved analysis methods, while CSV outputs are snapshots. The overview's additional weekday/weekend and shipping breakdowns are not fully documented in those SQL files; calculation documentation remains a follow-up task.
- `00_prepare_analysis_tables.sql` creates the campaign calendar and daily restocking table after importing `sales` and `products`. Run it only when those two analysis tables do not already exist.
- Python scripts currently use local file paths, and the Excel decryption password is a placeholder. Running the preparation workflow requires private source files, path adjustments, and a locally supplied password. These inputs are not included in the repository.

## Future Work

- Document the Tableau calculated fields and the additional overview breakdowns.
- Validate the trial replenishment rule using actual inventory and supplier lead-time records.
- Explore shipping and regional purchasing patterns, followed by repeat-purchase behavior.
