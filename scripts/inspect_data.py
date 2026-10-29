import pandas as pd

orders_df = pd.read_csv(
    "/Users/nelson/Documents/shopee-sales-analysis/data/orders_combined.csv",
    encoding="utf-8-sig",dtype="string",)
#print("讀入資料尺寸：", orders_df.shape)

#print("資料總列數：", len(orders_df))
#print("訂單編號缺失列數：", orders_df["訂單編號"].isna().sum())
#print("不同訂單編號數：", orders_df["訂單編號"].nunique())

#print("包含來源檔案的重複列數：", orders_df.duplicated().sum())
content_df = orders_df.drop(columns=["來源檔案"])
#print("不含來源檔案的重複列數：", content_df.duplicated().sum())

repeated_rows = orders_df[orders_df["訂單編號"].duplicated(keep=False)]
sample_order_id = repeated_rows["訂單編號"].iloc[0]
sample_order = orders_df[orders_df["訂單編號"] == sample_order_id]
#print(sample_order.T.to_string())

same_item_rows = repeated_rows.duplicated(
    subset=["訂單編號", "商品ID", "規格ID"],
    keep=False,)
#print("相同訂單、商品與規格的明細列數：", same_item_rows.sum())
#print("商品ID缺失列數：", orders_df["商品ID"].isna().sum())
#print("規格ID缺失列數：", orders_df["規格ID"].isna().sum())

#print("訂單狀態分布：")
#print(orders_df["訂單狀態"].value_counts(dropna=False))

#print(orders_df["退貨 / 退款狀態"].value_counts(dropna=False))
#print(orders_df["退貨數量"].value_counts(dropna=False))

return_rows = orders_df[orders_df["退貨 / 退款狀態"] == "已同意申請"]
#print("已同意申請的明細列數：", len(return_rows))
#print("已同意申請的不同訂單數：", return_rows["訂單編號"].nunique())

return_check = pd.crosstab(
    orders_df["退貨 / 退款狀態"].fillna("未填寫"),
    orders_df["退貨數量"],)
#print(return_check)

order_amount_counts = orders_df.groupby("訂單編號")["商品總價"].nunique(
    dropna=False)
print("商品總價不一致的訂單數：",(order_amount_counts > 1).sum(),)
print("商品總價缺失列數：", orders_df["商品總價"].isna().sum())