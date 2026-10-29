# Data

This folder contains prepared data used for the Shopee sales analysis.

- `sales.csv`: Sales line items with recoded order, buyer, product, and variant IDs.
- `products.csv`: Product and variant reference table.
- `shopee.db`: SQLite database containing the prepared data and analysis tables.
- `product_mapping.csv`: Mapping between original product information and standardized names.
- `product_mapping_draft.csv`: Initial product mapping table before standardization.

The original order exports and the intermediate file containing buyer accounts are excluded from this repository.

Recoded IDs preserve relationships between records. The sales data retains transaction dates, amounts, and geographic information.
