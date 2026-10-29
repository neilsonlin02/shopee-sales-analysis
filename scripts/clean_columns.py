import pandas as pd

data_df = pd.read_csv(
    "/Users/nelson/Documents/shopee-sales-analysis/data/orders_combined.csv",
    encoding="utf-8-sig",dtype="string")

columns_to_keep = [
    "訂單編號",
    "退貨 / 退款狀態",
    "買家帳號",
    "訂單成立日期",
    "商品總價",
    "買家總支付金額",
    "買家支付運費",
    "蝦皮補助運費",
    "蝦皮補貼金額",
    "蝦幣折抵",
    "銀行信用卡活動折抵",
    "賣家負擔優惠券",
    "賣家負擔蝦幣回饋券",
    "蝦皮負擔優惠券",
    "商品名稱",
    "商品ID",
    "商品選項名稱",
    "規格ID",
    "商品原價",
    "商品活動價格",
    "數量",
    "退貨數量",
    "城市",
    "行政區",
    "寄送方式",
    "付款方式",
    "來源檔案"]

analysis_df = data_df[columns_to_keep]
#print("資料原尺寸：", data_df.shape)
#print("篩選後資料尺寸：", analysis_df.shape)

numeric_columns = [
    "商品總價",
    "買家總支付金額",
    "買家支付運費",
    "蝦皮補助運費",
    "蝦皮補貼金額",
    "蝦幣折抵",
    "銀行信用卡活動折抵",
    "賣家負擔優惠券",
    "賣家負擔蝦幣回饋券",
    "蝦皮負擔優惠券",
    "商品原價",
    "商品活動價格",
    "數量",
    "退貨數量"]

for column in numeric_columns:
    analysis_df[column] = pd.to_numeric(
        analysis_df[column],
        errors="raise")
#print(analysis_df[numeric_columns].dtypes)

analysis_df["訂單成立日期"] = pd.to_datetime(
    analysis_df["訂單成立日期"],
    errors="raise")
#print(analysis_df["訂單成立日期"].dtype)

price_dif= analysis_df["商品原價"] - analysis_df["商品活動價格"]
#print("價差分布：\n", price_dif.value_counts().sort_index(),sep='')

discount_columns = [
    "蝦皮補貼金額",
    "蝦幣折抵",
    "銀行信用卡活動折抵",
    "賣家負擔優惠券",
    "賣家負擔蝦幣回饋券",
    "蝦皮負擔優惠券"]
#print("優惠欄位非零列數：")
#print((analysis_df[discount_columns] != 0).sum())

analysis_df = analysis_df.drop(columns=[
    "蝦皮補貼金額",
    "銀行信用卡活動折抵",
    "賣家負擔優惠券",
    "賣家負擔蝦幣回饋券"])
#print("新資料尺寸：", analysis_df.shape)
#print("欄位概況:\n", analysis_df.head(3).T.to_string(max_colwidth=15))

#print(pd.DataFrame({"NA數量": analysis_df.isna().sum(),"非NA數量": analysis_df.notna().sum()}))

missing_buyer_ids = analysis_df.loc[
    analysis_df["買家帳號"].isna(),"訂單編號"]

missing_buyer_data = analysis_df[
    analysis_df["訂單編號"].isin(missing_buyer_ids)]
#print(missing_buyer_data.T.to_string(max_colwidth=25))

analysis_df.to_csv(
    "/Users/nelson/Documents/shopee-sales-analysis/data/data_columns_cleaned.csv",
    index=False,
    encoding="utf-8-sig")