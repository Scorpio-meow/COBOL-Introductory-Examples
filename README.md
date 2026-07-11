# 銀行管理系統 (COBOL Bank Management System)

本專案是一個基於 COBOL 語言開發的簡易銀行管理系統。系統採用檔案型資料庫（Sequential Files）進行資料儲存，提供了客戶資料管理、帳戶開立、存款、提款、轉帳、餘額查詢及最近交易明細等多項功能。

> [!WARNING]
> 本專案僅作為程式碼寫法範例展示，並未實作任何資料加密或安全防護機制（如身分證字號、電話、餘額與交易明細等敏感資訊均為明文儲存）。請勿直接將本專案套用於實際的生產系統或商業環境中。


## 快速開始

### 環境需求
本系統建議在安裝有 GnuCOBOL 編譯器的環境下執行（例如 Windows Subsystem for Linux - WSL 中的 Debian/Ubuntu 系統）。

1. **安裝 GnuCOBOL**
   在 WSL/Linux 終端機執行以下命令安裝編譯器：
   ```bash
   sudo apt-get update
   sudo apt-get -y install gnucobol
   ```

2. **確認安裝**
   ```bash
   cobc --version
   ```

### 編譯與執行
1. **編譯程式碼**
   在專案根目錄下，使用 `cobc` 將 [BANK.cbl](./BANK.cbl) 編譯為可執行檔：
   ```bash
   cobc -x -free BANK.cbl -o BANK
   ```
   * `-x`：指示編譯器生成獨立的可執行檔。
   * `-free`：使用自由格式（Free Format）編譯 COBOL 原始碼。
   * `-o BANK`：指定輸出檔名為 `BANK`。

2. **執行程式**
   ```bash
   ./BANK
   ```

---

## 系統功能

本系統提供以下核心功能，可在主選單進行選擇：
1. **新增客戶資料**：生成唯一的 6 位數客戶 ID，記錄身分證字號、姓名、地址與電話。
2. **開立新帳戶**：驗證客戶 ID 是否存在，生成唯一的 10 位數帳號，支援儲蓄帳戶 (Savings) 與支票帳戶 (Checking)，並可設定初始存款。
3. **存款作業**：對指定帳戶進行存款，更新餘額並寫入交易紀錄。
4. **提款作業**：對指定帳戶進行提款（需檢查餘額是否足夠），更新餘額並寫入交易紀錄。
5. **轉帳作業**：支援兩個帳戶之間的資金轉移，扣除來源帳戶餘額、增加目標帳戶餘額，並分別記錄兩筆交易明細（轉出與轉入）。
6. **查詢餘額與交易明細**：顯示帳戶基本資訊、關聯客戶資訊，並透過環形緩衝區（Ring Buffer）技術讀取並顯示該帳戶最新的 5 筆交易紀錄。
9. **離開系統**：安全關閉所有開啟的檔案並退出。

---

## 資料檔案說明

系統的所有資料均儲存於同目錄下的 `.SAM`（Sequential Access Method）檔案中：
* [CUSTOMER.SAM](./CUSTOMER.SAM)：儲存客戶基本資料。
* [ACCOUNT.SAM](./ACCOUNT.SAM)：儲存帳戶與餘額資訊。
* [TRANS.SAM](./TRANS.SAM)：儲存所有交易歷史紀錄。
* [TEMP-ACCOUNT.SAM](./TEMP-ACCOUNT.SAM)：交易時使用的暫存帳戶檔，用於實現檔案更新。

詳細的欄位格式與資料結構說明，請參閱 [資料結構說明文件](./docs/data_structures.md)。

---

## 系統設計與實作細節

* **交易流水號與 ID 自動生成**：系統透過讀取現有檔案，找出最大 ID 值並加 1，以確保新建立的客戶 ID、帳號及交易 ID 具備唯一性。
* **安全檔案更新機制**：COBOL 在處理檔案修改時，會將更新後的資料寫入臨時檔案 [TEMP-ACCOUNT.SAM](./TEMP-ACCOUNT.SAM)，確認寫入無誤後，透過呼叫系統函數 `CBL_RENAME_FILE` 覆蓋原有的 [ACCOUNT.SAM](./ACCOUNT.SAM)，避免因程式異常中斷導致資料損毀。
* **最近交易記錄（Ring Buffer）**：為了快速顯示最近 5 筆交易，系統讀取整個交易檔，利用 `FUNCTION MOD` 將符合條件的交易循環寫入長度為 5 的陣列中，隨後按時間由舊到新輸出，節省記憶體空間並最佳化顯示效能。

---

## 相關文件

* [資料結構說明文件](./docs/data_structures.md)
* [系統操作與編譯指南](./docs/operation_manual.md)