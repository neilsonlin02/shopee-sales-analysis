from pathlib import Path
folder = Path.home() / "Downloads" / "蝦皮訂單"
#print(folder)
#print(folder.exists())

excel_files = sorted(folder.glob("*.xlsx"))
#print(excel_files)
#print(len(excel_files))

for file_path in excel_files:
    print(file_path.name)