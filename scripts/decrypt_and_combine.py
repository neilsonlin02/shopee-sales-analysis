from pathlib import Path
from io import BytesIO
import msoffcrypto
import pandas as pd

folder = Path.home() / "Downloads" / "蝦皮訂單"
excel_files = sorted(folder.glob("*.xlsx"))

password = "******"

reference_columns = None
monthly_data = []
for file_path in excel_files:
    with open(file_path, "rb") as file:
        office_file = msoffcrypto.OfficeFile(file)
        office_file.load_key(password=password)

        decrypted_file = BytesIO()
        office_file.decrypt(decrypted_file, verify_integrity=True)

    df = pd.read_excel(decrypted_file)
    df["來源檔案"] = file_path.name
    monthly_data.append(df)
    #print(file_path.name, df.shape)

    if reference_columns is None:
        reference_columns = df.columns.tolist()

    if df.columns.tolist() != reference_columns:
        raise ValueError(f"{file_path.name} 的欄名或順序不一致，停止處理。")
combined_df = pd.concat(monthly_data, ignore_index=True)

rows_before = sum(len(df) for df in monthly_data)
rows_after = len(combined_df)

#print("合併前總列數：", rows_before)
#print("合併後總列數：", rows_after)

if rows_before != rows_after:
    raise ValueError("合併前後列數不一致，停止輸出。")

project_folder = Path(__file__).resolve().parent.parent
output_path = project_folder / "data" / "orders_combined.csv"

combined_df.to_csv(output_path, index=False, encoding="utf-8-sig")

print("已匯出：", output_path)