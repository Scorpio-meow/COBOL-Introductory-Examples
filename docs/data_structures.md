# 銀行管理系統 - 資料結構說明文件

本文件詳細說明系統中使用的資料檔案格式與 COBOL 記錄結構（Record Layouts）。系統採用 **Line Sequential** 組織格式，即每行代表一筆紀錄，欄位依固定長度排列。

> [!WARNING]
> 本專案僅作為程式碼寫法範例展示，並未實作任何資料加密或安全防護機制（如身分證字號、電話、餘額與交易明細等敏感資訊均為明文儲存）。請勿直接將本專案套用於實際的生產系統或商業環境中。

---

## 1. 客戶資料檔 (CUSTOMER.SAM)

儲存客戶的基本身分資訊。每筆紀錄固定長度為 **110 位元組（Bytes）**。

### COBOL 結構定義
```cobol
FD  CUSTOMER-FILE.
01  CUSTOMER-RECORD.
    05  CUST-ID             PIC X(10).      *> 客戶唯一ID (靠左對齊，空格填補)
    05  CUST-ID-NUMBER      PIC X(10).      *> 身分證字號
    05  CUST-NAME           PIC X(30).      *> 客戶姓名
    05  CUST-ADDRESS        PIC X(50).      *> 客戶地址
    05  CUST-PHONE          PIC 9(10).      *> 客戶電話 (10位數字)
```

### 欄位詳細說明
| 欄位名稱 | COBOL 型態 | 長度 (Bytes) | 說明 |
| :--- | :--- | :---: | :--- |
| `CUST-ID` | `PIC X(10)` | 10 | 客戶唯一識別碼。系統會自動從 `000001` 開始遞增生成，不足 10 位在右側填補空格。 |
| `CUST-ID-NUMBER` | `PIC X(10)` | 10 | 中華民國身分證字號（如 `A123456789`）。 |
| `CUST-NAME` | `PIC X(30)` | 30 | 客戶姓名，支援中英文。中文字元在 UTF-8 環境下每個佔 3 位元組。 |
| `CUST-ADDRESS` | `PIC X(50)` | 50 | 客戶聯絡地址。 |
| `CUST-PHONE` | `PIC 9(10)` | 10 | 10 位數電話號碼（如手機號碼 `0912345678` 或含區碼市話）。 |

### 實際範例
```text
000001    A123456789QWE                           WERTY                                             0123456789
```
* `000001    `：客戶 ID（佔 10 欄位，後方 4 個空格）。
* `A123456789`：身分證字號（佔 10 欄位）。
* `QWE                           `：姓名（佔 30 欄位，後方填滿空格）。
* `WERTY                                             `：地址（佔 50 欄位，後方填滿空格）。
* `0123456789`：電話號碼（佔 10 欄位）。

---

## 2. 帳戶資料檔 (ACCOUNT.SAM)

儲存所有銀行帳戶的餘額與狀態。每筆紀錄固定長度為 **40 位元組（Bytes）**。

### COBOL 結構定義
```cobol
FD  ACCOUNT-FILE.
01  ACCOUNT-RECORD.
    05  ACC-NUMBER          PIC X(10).      *> 銀行帳號 (10位)
    05  ACC-CUST-ID         PIC X(10).      *> 關聯之客戶ID
    05  ACC-TYPE            PIC X(1).       *> 帳戶類型 (S/C)
        88  SAVINGS         VALUE "S".
        88  CHECKING        VALUE "C".
    05  ACC-BALANCE         PIC 9(10).      *> 帳戶餘額 (整數)
    05  ACC-OPEN-DATE       PIC X(8).       *> 開戶日期 (YYYYMMDD)
    05  ACC-STATUS          PIC X(1).       *> 帳戶狀態 (A/C/S)
        88  ACTIVE          VALUE "A".
        88  CLOSED          VALUE "C".
        88  SUSPENDED       VALUE "S".
```

### 欄位詳細說明
| 欄位名稱 | COBOL 型態 | 長度 (Bytes) | 說明 |
| :--- | :--- | :---: | :--- |
| `ACC-NUMBER` | `PIC X(10)` | 10 | 銀行帳號，由系統從 `0000000001` 開始自動遞增生成。 |
| `ACC-CUST-ID` | `PIC X(10)` | 10 | 該帳戶所屬客戶的 ID，對應 `CUSTOMER.SAM` 中的 `CUST-ID`。 |
| `ACC-TYPE` | `PIC X(1)` | 1 | 帳戶類型：<br>`S`：儲蓄帳戶 (Savings)<br>`C`：支票帳戶 (Checking) |
| `ACC-BALANCE` | `PIC 9(10)` | 10 | 帳戶餘額（最大可達 9,999,999,999 元）。 |
| `ACC-OPEN-DATE` | `PIC X(8)` | 8 | 開戶日期，格式為 `YYYYMMDD`（例如 `20250308`）。 |
| `ACC-STATUS` | `PIC X(1)` | 1 | 帳戶狀態：<br>`A`：啟用 (Active)<br>`C`：關閉 (Closed)<br>`S`：凍結 (Suspended) |

### 實際範例
```text
0000000004000001      S000050000020250308A
```
* `0000000004`：帳號為 4。
* `000001    `：客戶 ID 為 1。
* `S`：帳戶類型為儲蓄帳戶。
* `0000500000`：餘額為 500,000 元（以 0 補足前導位數）。
* `20250308`：開戶日期為 2025 年 3 月 8 日。
* `A`：帳戶狀態為啟用。

---

## 3. 交易紀錄檔 (TRANS.SAM)

儲存所有的存款、提款及轉帳交易紀錄。每筆紀錄固定長度為 **94 位元組（Bytes）**。

### COBOL 結構定義
```cobol
FD  TRANS-FILE.
01  TRANS-RECORD.
    05  TRANS-ID            PIC X(12).      *> 交易唯一ID
    05  TRANS-ACC-NUMBER    PIC X(10).      *> 交易帳號
    05  TRANS-DATE          PIC X(8).       *> 交易日期 (YYYYMMDD)
    05  TRANS-TIME          PIC X(6).       *> 交易時間 (HHMMSS)
    05  TRANS-TYPE          PIC X(1).       *> 交易型態 (D/W/T)
        88  DEPOSIT         VALUE "D".
        88  WITHDRAWAL      VALUE "W".
        88  TRANSFER        VALUE "T".
    05  TRANS-AMOUNT        PIC 9(7)V99.    *> 交易金額 (含2位小數)
    05  TRANS-PREV-BAL      PIC 9(7)V99.    *> 交易前餘額 (含2位小數)
    05  TRANS-NEW-BAL       PIC 9(7)V99.    *> 交易後餘額 (含2位小數)
    05  TRANS-DESCRIPTION   PIC X(30).      *> 交易說明描述
```

### 欄位詳細說明
| 欄位名稱 | COBOL 型態 | 長度 (Bytes) | 說明 |
| :--- | :--- | :---: | :--- |
| `TRANS-ID` | `PIC X(12)` | 12 | 交易 ID，系統自動遞增生成。 |
| `TRANS-ACC-NUMBER` | `PIC X(10)` | 10 | 該筆交易對應的銀行帳號。 |
| `TRANS-DATE` | `PIC X(8)` | 8 | 交易日期，格式為 `YYYYMMDD`。 |
| `TRANS-TIME` | `PIC X(6)` | 6 | 交易時間，格式為 `HHMMSS`。 |
| `TRANS-TYPE` | `PIC X(1)` | 1 | 交易型態：<br>`D`：存款 (Deposit)<br>`W`：提款 (Withdrawal)<br>`T`：轉帳 (Transfer) |
| `TRANS-AMOUNT` | `PIC 9(7)V99` | 9 | 交易金額。`V` 代表虛擬小數點，在檔案中不佔空間（例如儲存 `001000000` 代表 `10000.00`）。 |
| `TRANS-PREV-BAL` | `PIC 9(7)V99` | 9 | 交易前帳戶餘額（包含 2 位小數）。 |
| `TRANS-NEW-BAL` | `PIC 9(7)V99` | 9 | 交易後帳戶餘額（包含 2 位小數）。 |
| `TRANS-DESCRIPTION` | `PIC X(30)` | 30 | 交易說明描述（如「初始存款」、「櫃台存款」、「轉出至帳號: X」等）。 |

### 實際範例
```text
000000000009000000000120250308121544T000200000001500000001300000轉出至帳號: 0000000002     
```
* `000000000009`：交易 ID（12 位）。
* `0000000001`：交易帳號（10 位）。
* `20250308`：交易日期（8 位）。
* `121544`：交易時間 12 點 15 分 44 秒（6 位）。
* `T`：轉帳交易。
* `000200000`：交易金額 2,000.00 元（佔 9 位，`0002000` 整數，`00` 小數）。
* `001500000`：交易前餘額 15,000.00 元。
* `001300000`：交易後餘額 13,000.00 元。
* `轉出至帳號: 0000000002     `：轉帳說明描述（佔 30 位，剩餘長度空格補滿）。

---

## 4. 暫存帳戶檔 (TEMP-ACCOUNT.SAM)

結構與 `ACCOUNT.SAM` 完全相同（固定長度 40 位元組），主要用於暫存更新後的帳戶資料。在交易完成時，系統會將修改後的結果寫入此檔案，確認寫入完畢後，再使用 `CBL_RENAME_FILE` 重新命名並覆蓋 `ACCOUNT.SAM`，以確保資料的完整性與檔案安全。