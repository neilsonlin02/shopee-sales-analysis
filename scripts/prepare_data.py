import pandas as pd

data_df = pd.read_csv(
    "/Users/nelson/Documents/shopee-sales-analysis/data/data_columns_cleaned.csv",
    encoding="utf-8-sig",
    dtype={"商品ID": "string","規格ID": "string"},
    parse_dates=["訂單成立日期"])
#print(data_df.dtypes)

data_df["訂單編號"] = pd.factorize(data_df["訂單編號"])[0] + 1
#print(data_df["訂單編號"].head(10))

#print(data_df.loc[data_df["買家帳號"].isna()].T.to_string(max_colwidth=25))
data_df.loc[454, "買家帳號"] = "na1"
data_df.loc[2402, "買家帳號"] = "na2"
data_df["買家帳號"] = pd.factorize(data_df["買家帳號"])[0] + 1
data_df = data_df.rename(columns={"買家帳號": "買家ID"})
#print(data_df.loc[[454, 2402], ["訂單編號", "買家ID"]])

#print("訂單ID分布：")
#print(data_df["訂單編號"].value_counts().value_counts().sort_index())
#print("買家ID分布：")
#print(data_df["買家ID"].value_counts().value_counts().sort_index())

product_mapping = data_df[
    ["商品ID", "規格ID", "商品名稱", "商品選項名稱"]].drop_duplicates()
product_mapping.to_csv(
    "/Users/nelson/Documents/shopee-sales-analysis/data/product_mapping_draft.csv",
    index=False,encoding="utf-8-sig")
#用number編輯新名稱

product_mapping = pd.read_csv(
    "/Users/nelson/Documents/shopee-sales-analysis/data/product_mapping.csv",
    encoding="utf-8-sig",
    dtype={"商品ID": "string", "規格ID": "string"})
product_mapping["新商品ID"] = (
    pd.factorize(product_mapping["新商品名稱"])[0] + 1)
product_mapping["新規格ID"] = (
    pd.factorize(product_mapping["新商品選項名稱"])[0] + 1)
#print("總數\n",len(product_mapping),"\n獨特值數量：\n",product_mapping.nunique())

data_df = data_df.merge(
    product_mapping,
    on=["商品ID", "規格ID", "商品名稱", "商品選項名稱"],
    how="left",
    validate="many_to_one")
#print("合併後尺寸：", data_df.shape)
#print(data_df.isna().sum())

missing_location = data_df[
    data_df["城市"].isna() | data_df["行政區"].isna()]
#print(missing_location["寄送方式"].value_counts(dropna=False))

data_df["活動折扣"] = data_df["商品原價"] - data_df["商品活動價格"]
data_df = data_df.drop(columns=["商品活動價格"])
#print(data_df["活動折扣"].value_counts().sort_index())

data_df = data_df.drop(columns=[
    "商品ID", "規格ID", "商品名稱", "商品選項名稱"])
data_df = data_df.rename(columns={
    "新商品ID": "商品ID",
    "新規格ID": "規格ID",
    "新商品名稱": "商品名稱",
    "新商品選項名稱": "商品選項名稱"})
#print("新尺寸：", data_df.shape)

product_df = data_df[
    ["商品ID", "商品名稱", "規格ID", "商品選項名稱"]
    ].drop_duplicates()

sales_df = data_df.drop(columns=["商品名稱", "商品選項名稱"])

#print("商品規格表：", product_df.shape)
#print("訂單明細表：", sales_df.shape)

product_df.to_csv(
    "/Users/nelson/Documents/shopee-sales-analysis/data/products.csv",
    index=False,
    encoding="utf-8-sig")

sales_df.to_csv(
    "/Users/nelson/Documents/shopee-sales-analysis/data/sales.csv",
    index=False,
    encoding="utf-8-sig")