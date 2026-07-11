       *> ==============================================================
       *> IDENTIFICATION DIVISION (標誌部)
       *> 這是 COBOL 程式的起點，主要用來描述此程式相關訊息，包含了程式名、作者等。
       *> ==============================================================
        IDENTIFICATION DIVISION.
        PROGRAM-ID. BANK.
        AUTHOR. Scorpio-meow.
        DATE-WRITTEN. 2025-03-07.

       *> ==============================================================
       *> ENVIRONMENT DIVISION (環境部)
       *> 用於描述程式與外部環境的關係。它包含了 Configuration Section 和 Input-Output Section。
       *> ==============================================================
        ENVIRONMENT DIVISION.
        CONFIGURATION SECTION.
       *> Configuration Section 主要用於設定程式的執行環境，指定一些特定的系統資源。
        SOURCE-COMPUTER. PC.
        OBJECT-COMPUTER. PC.

        INPUT-OUTPUT SECTION.
        FILE-CONTROL.
       *> Input-Output Section 用來定義程式使用的檔案。
       *> File-Control 則指定邏輯檔案名稱與作業系統實體檔案的對應關係。
       *> SELECT 子句將邏輯檔案繫結到實體檔案。
       *> ORGANIZATION IS LINE SEQUENTIAL 代表這是每行一筆紀錄的循序檔案（純文字檔）。
            SELECT CUSTOMER-FILE ASSIGN TO "CUSTOMER.SAM"
                ORGANIZATION IS LINE SEQUENTIAL.
            SELECT ACCOUNT-FILE ASSIGN TO "ACCOUNT.SAM"
                ORGANIZATION IS LINE SEQUENTIAL.
            SELECT TRANS-FILE ASSIGN TO "TRANS.SAM"
                ORGANIZATION IS LINE SEQUENTIAL.
            SELECT TEMP-ACCOUNT-FILE ASSIGN TO "TEMP-ACCOUNT.SAM"
                ORGANIZATION IS LINE SEQUENTIAL.

       *> ==============================================================
       *> DATA DIVISION (數據部)
       *> 用於定義程式中使用的所有數據格式和變數。如果不在這邊宣告，程式將無法執行。
       *> ==============================================================
        DATA DIVISION.
        FILE SECTION.
       *> FILE SECTION (文件節) 用來定義輸入/輸出檔案的檔案描述元 (FD) 及相關變數。
        FD  CUSTOMER-FILE.
        01  CUSTOMER-RECORD.
       *> 變數定義包含：等級數 (01, 05 等具有從屬關係)、變數名稱、屬性定義 PIC。
       *> PIC X(10) 代表文數字屬性 (Alphanumeric)，長度為 10。
       *> PIC 9(10) 代表數字屬性，長度為 10。
            05  CUST-ID             PIC X(10).
            05  CUST-ID-NUMBER      PIC X(10).
            05  CUST-NAME           PIC X(30).
            05  CUST-ADDRESS        PIC X(50).
            05  CUST-PHONE          PIC 9(10).

        FD  ACCOUNT-FILE.
        01  ACCOUNT-RECORD.
            05  ACC-NUMBER          PIC X(10).
            05  ACC-CUST-ID         PIC X(10).
            05  ACC-TYPE            PIC X(1).
       *> 等級數 88 是特殊級別數，用來定義條件描述項（條件變數）。
       *> 當 ACC-TYPE 的值為 "S" 時，SAVINGS 條件成立，可用於簡化流程控制。
                88  SAVINGS         VALUE "S".
                88  CHECKING        VALUE "C".
            05  ACC-BALANCE         PIC 9(10).
            05  ACC-OPEN-DATE       PIC X(8).
            05  ACC-STATUS          PIC X(1).
                88  ACTIVE          VALUE "A".
                88  CLOSED          VALUE "C".
                88  SUSPENDED       VALUE "S".

        FD  TRANS-FILE.
        01  TRANS-RECORD.
            05  TRANS-ID            PIC X(12).
            05  TRANS-ACC-NUMBER    PIC X(10).
            05  TRANS-DATE          PIC X(8).
            05  TRANS-TIME          PIC X(6).
            05  TRANS-TYPE          PIC X(1).
                88  DEPOSIT         VALUE "D".
                88  WITHDRAWAL      VALUE "W".
                88  TRANSFER        VALUE "T".
       *> PIC 9(7)V99 代表浮點數屬性，7 位整數加上 2 位小數，共 9 位數。
       *> 符號 V 是虛擬小數點，並不佔用實際儲存空間，用於程式計算時保存小數。
            05  TRANS-AMOUNT        PIC 9(7)V99.
            05  TRANS-PREV-BAL      PIC 9(7)V99.
            05  TRANS-NEW-BAL       PIC 9(7)V99.
            05  TRANS-DESCRIPTION   PIC X(30).

        FD  TEMP-ACCOUNT-FILE.
        01  TEMP-ACCOUNT-RECORD     PIC X(40).

        WORKING-STORAGE SECTION.
       *> WORKING-STORAGE SECTION (工作節) 用於定義程式執行期間需要使用的中間變數與常數。
        01  FILE-STATUS-VARS.
            05  CUST-FILE-STATUS    PIC X(2).
                88  CUST-SUCCESS    VALUE "00".
            05  ACC-FILE-STATUS     PIC X(2).
                88  ACC-SUCCESS     VALUE "00".
            05  TRANS-FILE-STATUS   PIC X(2).
                88  TRANS-SUCCESS   VALUE "00".

        01  MENU-VARIABLES.
            05  MENU-CHOICE         PIC 9.
            05  CONTINUE-CHOICE     PIC X.

        01  ACCOUNT-VARIABLES.
            05  WS-ACCOUNT-NUMBER   PIC X(10).
            05  WS-TRANSACTION-AMT  PIC 9(10).
            05  WS-NEW-BALANCE      PIC 9(10).

        01  SYSTEM-VARIABLES.
            05  WS-DATE             PIC X(8).
            05  WS-TIME             PIC X(6).
            05  WS-TRANS-ID-NUM     PIC 9(12).

        01  SCREEN-VARIABLES.
            05  WS-ERROR-MESSAGE    PIC X(50).
            05  WS-TRANS-COUNT      PIC 9(2) VALUE 0.

        01  CUSTOMER-VARIABLES.
            05  WS-NEW-CUST-ID      PIC X(10).
            05  WS-NEXT-CUST-ID     PIC 9(10).
            05  WS-NEW-ACC-NUMBER   PIC X(10).
            05  WS-NEXT-ACC-NUMBER  PIC 9(10).
            05  WS-CUSTOMER-EXISTS  PIC X VALUE "N".
                88  CUSTOMER-EXISTS VALUE "Y".

       *> 陣列（表）定義：使用 OCCURS 語法定義重複的陣列項目（不能出現在 01 層級，須在子層級定義）。
        01  TRANS-RING-BUFFER.
            05  WS-TRANS-TOTAL      PIC 9(6) VALUE 0.
            05  WS-RING-IDX         PIC 9     VALUE 0.
            05  WS-RING-START       PIC 9     VALUE 1.
            05  WS-RING-I           PIC 9     VALUE 1.
            05  WS-RING-ENTRY OCCURS 5 TIMES.
                10  WS-RING-DATE    PIC X(8).
                10  WS-RING-TIME    PIC X(6).
                10  WS-RING-TYPE    PIC X(1).
                10  WS-RING-AMOUNT  PIC 9(7)V99.
                10  WS-RING-PREV    PIC 9(7)V99.
                10  WS-RING-NEW     PIC 9(7)V99.
                10  WS-RING-DESC    PIC X(30).

        01  TRANSFER-VARIABLES.
            05  WS-SOURCE-ACC-NUMBER   PIC X(10).
            05  WS-SOURCE-ACC-BALANCE  PIC 9(10).
            05  WS-SOURCE-CUST-NAME    PIC X(30).
            05  WS-TARGET-ACC-NUMBER   PIC X(10).
            05  WS-TARGET-ACC-BALANCE  PIC 9(10).
            05  WS-TARGET-CUST-NAME    PIC X(30).

       *> ==============================================================
       *> PROCEDURE DIVISION (過程部)
       *> 程式執行的實際入口點，包含了所有的邏輯處理，以一系列的語法建構。
       *> 程式語句可以換行，但必須以句號「.」作為段落與語句的結束符號。
       *> ==============================================================
        PROCEDURE DIVISION.
       *> 程式段 PERFORM 語句：用於呼叫指定的段落，簡化編碼使結構清晰。
        PERFORM 200-PROCESS-MENU.
        PERFORM 900-CLEANUP.
        STOP RUN.

        200-PROCESS-MENU.
       *> PERFORM UNTIL 迴圈結構：重覆執行程式段直到條件成立為止。
            PERFORM UNTIL MENU-CHOICE = 9
                DISPLAY " "
                DISPLAY "==============================="
                DISPLAY "      銀行管理系統選單         "
                DISPLAY "==============================="
                DISPLAY "1. 新增客戶資料"
                DISPLAY "2. 開立新帳戶"
                DISPLAY "3. 存款"
                DISPLAY "4. 提款"
                DISPLAY "5. 轉帳"
                DISPLAY "6. 查詢餘額"
                DISPLAY "9. 離開系統"
                DISPLAY "==============================="
       *> DISPLAY 語句：將資料輸出顯示。WITH NO ADVANCING 表示不換行。
                DISPLAY "請輸入您的選擇 (1-9): " WITH NO ADVANCING
       *> ACCEPT 語句：主要用於接收外部輸入資料，存入對應變數。
                ACCEPT MENU-CHOICE
                
       *> EVALUATE 語句：多分支條件判斷結構，相當於 switch-case。
                EVALUATE MENU-CHOICE
                    WHEN 1
                        PERFORM 300-ADD-CUSTOMER
                    WHEN 2
                        PERFORM 400-OPEN-ACCOUNT
                    WHEN 3
                        PERFORM 500-DEPOSIT
                    WHEN 4
                        PERFORM 600-WITHDRAW
                    WHEN 5
                        PERFORM 700-TRANSFER
                    WHEN 6
                        PERFORM 800-CHECK-BALANCE
                    WHEN 9
                        PERFORM 900-CLEANUP
                        DISPLAY "謝謝使用本系統，再見！"
                    WHEN OTHER
                        DISPLAY "錯誤：請輸入有效的選擇 (1-9)"
                END-EVALUATE
                
                IF MENU-CHOICE NOT = 9 THEN
                    DISPLAY " "
                    DISPLAY "按任意鍵繼續..." WITH NO ADVANCING
                    ACCEPT CONTINUE-CHOICE
                END-IF
            END-PERFORM.

        300-ADD-CUSTOMER.
            DISPLAY " "
            DISPLAY "=== 新增客戶資料 ==="
            PERFORM 310-GENERATE-CUSTOMER-ID
            DISPLAY "客戶ID將為: " WS-NEW-CUST-ID
            DISPLAY "請輸入身分證字號: " WITH NO ADVANCING
            ACCEPT CUST-ID-NUMBER
            DISPLAY "請輸入客戶姓名: " WITH NO ADVANCING
            ACCEPT CUST-NAME
            DISPLAY "請輸入客戶地址: " WITH NO ADVANCING
            ACCEPT CUST-ADDRESS
            DISPLAY "請輸入客戶電話: " WITH NO ADVANCING
            ACCEPT CUST-PHONE
       *> 傳送 MOVE 語句：主要用於將變數賦值或參數傳遞（文數字傳送會斷尾，數字傳送會斷頭）。
            MOVE WS-NEW-CUST-ID TO CUST-ID
            OPEN EXTEND CUSTOMER-FILE
            WRITE CUSTOMER-RECORD
            END-WRITE
            CLOSE CUSTOMER-FILE
            DISPLAY " "
            DISPLAY "客戶資料新增成功!"
            DISPLAY "客戶ID: " WS-NEW-CUST-ID.

        310-GENERATE-CUSTOMER-ID.
            MOVE 0 TO WS-NEXT-CUST-ID
            OPEN INPUT CUSTOMER-FILE
            PERFORM UNTIL 1 = 2
                READ CUSTOMER-FILE
                    AT END EXIT PERFORM
                END-READ
                COMPUTE WS-NEXT-CUST-ID = FUNCTION MAX(WS-NEXT-CUST-ID, 
                                          FUNCTION NUMVAL(CUST-ID))
            END-PERFORM
            CLOSE CUSTOMER-FILE
            ADD 1 TO WS-NEXT-CUST-ID
            MOVE WS-NEXT-CUST-ID TO WS-NEW-CUST-ID.

        400-OPEN-ACCOUNT.
            DISPLAY " "
            DISPLAY "=== 開立新帳戶 ==="
            DISPLAY "請輸入客戶ID: " WITH NO ADVANCING
            ACCEPT ACC-CUST-ID
            PERFORM 410-VERIFY-CUSTOMER
            IF NOT CUSTOMER-EXISTS
                DISPLAY "錯誤: 找不到此客戶ID，請先建立客戶資料"
            ELSE
                PERFORM 420-GENERATE-ACCOUNT-NUMBER
                DISPLAY "新帳號將為: " WS-NEW-ACC-NUMBER
                DISPLAY " "
                DISPLAY "請選擇帳戶類型:"
                DISPLAY "S - 儲蓄帳戶"
                DISPLAY "C - 支票帳戶"
                DISPLAY "請輸入 (S/C): " WITH NO ADVANCING
                ACCEPT ACC-TYPE
                IF ACC-TYPE = "S" OR ACC-TYPE = "C"
                    DISPLAY "請輸入初始存款金額: " WITH NO ADVANCING
                    ACCEPT ACC-BALANCE
                    MOVE FUNCTION CURRENT-DATE(1:8) TO ACC-OPEN-DATE
                    MOVE "A" TO ACC-STATUS
                    MOVE WS-NEW-ACC-NUMBER TO ACC-NUMBER
                    OPEN EXTEND ACCOUNT-FILE
                    WRITE ACCOUNT-RECORD
                    END-WRITE
                    CLOSE ACCOUNT-FILE
                    IF ACC-BALANCE > 0
                        PERFORM 430-RECORD-INITIAL-DEPOSIT
                    END-IF
                    DISPLAY " "
                    DISPLAY "帳戶開立成功!"
                    DISPLAY "帳號: " ACC-NUMBER
                    DISPLAY "帳戶類型: " 
                        FUNCTION TRIM(
                        FUNCTION SUBSTITUTE(ACC-TYPE, 
                                "S", "儲蓄帳戶", 
                                "C", "支票帳戶"))
                    DISPLAY "初始餘額: " ACC-BALANCE
                    DISPLAY "開戶日期: " ACC-OPEN-DATE
                ELSE
                    DISPLAY "錯誤: 無效的帳戶類型，請輸入 S 或 C"
                END-IF
            END-IF.

        410-VERIFY-CUSTOMER.
            MOVE "N" TO WS-CUSTOMER-EXISTS
            OPEN INPUT CUSTOMER-FILE
            PERFORM UNTIL 1 = 2
                READ CUSTOMER-FILE
                    AT END EXIT PERFORM
                END-READ
                IF CUST-ID = ACC-CUST-ID
                    MOVE "Y" TO WS-CUSTOMER-EXISTS
                    EXIT PERFORM
                END-IF
            END-PERFORM
            CLOSE CUSTOMER-FILE.

        420-GENERATE-ACCOUNT-NUMBER.
            MOVE 0 TO WS-NEXT-ACC-NUMBER
            OPEN INPUT ACCOUNT-FILE
            PERFORM UNTIL 1 = 2
                READ ACCOUNT-FILE
                    AT END EXIT PERFORM
                END-READ
                COMPUTE WS-NEXT-ACC-NUMBER = 
                FUNCTION MAX(WS-NEXT-ACC-NUMBER, 
                FUNCTION NUMVAL(ACC-NUMBER))
            END-PERFORM
            CLOSE ACCOUNT-FILE
            ADD 1 TO WS-NEXT-ACC-NUMBER
            MOVE WS-NEXT-ACC-NUMBER TO WS-NEW-ACC-NUMBER.

        430-RECORD-INITIAL-DEPOSIT.
            MOVE 0 TO WS-TRANS-ID-NUM
            OPEN INPUT TRANS-FILE
            PERFORM UNTIL 1 = 2
                READ TRANS-FILE
                    AT END EXIT PERFORM
                END-READ
                COMPUTE WS-TRANS-ID-NUM = FUNCTION MAX(WS-TRANS-ID-NUM, 
                                          FUNCTION NUMVAL(TRANS-ID))
            END-PERFORM
            CLOSE TRANS-FILE
            ADD 1 TO WS-TRANS-ID-NUM
            MOVE WS-TRANS-ID-NUM TO TRANS-ID
            MOVE ACC-NUMBER TO TRANS-ACC-NUMBER
            MOVE FUNCTION CURRENT-DATE(1:8) TO TRANS-DATE
            MOVE FUNCTION CURRENT-DATE(9:6) TO TRANS-TIME
            MOVE "D" TO TRANS-TYPE
            MOVE ACC-BALANCE TO TRANS-AMOUNT
            MOVE 0 TO TRANS-PREV-BAL
            MOVE ACC-BALANCE TO TRANS-NEW-BAL
            MOVE "初始存款" TO TRANS-DESCRIPTION
            OPEN EXTEND TRANS-FILE
            WRITE TRANS-RECORD
            END-WRITE
            CLOSE TRANS-FILE.

        500-DEPOSIT.
            DISPLAY " "
            DISPLAY "=== 存款作業 ==="
            DISPLAY "請輸入帳號: " WITH NO ADVANCING
            ACCEPT WS-ACCOUNT-NUMBER
            MOVE "N" TO WS-CUSTOMER-EXISTS
            MOVE 0 TO WS-NEW-BALANCE
            OPEN INPUT ACCOUNT-FILE
            PERFORM UNTIL 1 = 2
                READ ACCOUNT-FILE
                    AT END EXIT PERFORM
                END-READ
                IF ACC-NUMBER = WS-ACCOUNT-NUMBER
                    MOVE "Y" TO WS-CUSTOMER-EXISTS
                    IF ACC-STATUS = "C"
                        DISPLAY "錯誤: 此帳戶已關閉"
                        EXIT PERFORM
                    END-IF
                    IF ACC-STATUS = "S"
                        DISPLAY "錯誤: 此帳戶已被凍結"
                        EXIT PERFORM
                    END-IF
                    DISPLAY "請輸入存款金額: " WITH NO ADVANCING
                    ACCEPT WS-TRANSACTION-AMT
                    IF WS-TRANSACTION-AMT <= 0
                        DISPLAY "錯誤: 存款金額必須大於零"
                        EXIT PERFORM
                    END-IF
                    COMPUTE WS-NEW-BALANCE = ACC-BALANCE + WS-TRANSACTION-AMT
                    MOVE WS-NEW-BALANCE TO ACC-BALANCE
                    MOVE ACCOUNT-RECORD TO TEMP-ACCOUNT-RECORD
                    EXIT PERFORM
                END-IF
            END-PERFORM
            CLOSE ACCOUNT-FILE
            
            IF WS-CUSTOMER-EXISTS = "N"
                DISPLAY "錯誤: 找不到此帳號"
                EXIT PARAGRAPH
            END-IF
            
            IF WS-TRANSACTION-AMT <= 0 OR
               ACC-STATUS = "C" OR
               ACC-STATUS = "S"
                EXIT PARAGRAPH
            END-IF
            
       *> === 安全檔案更新機制 (Safe File Update) ===
       *> 由於 COBOL 無法直接修改順序檔中的某一筆紀錄，
       *> 因此採用以下安全更新模式：讀取原檔案的同時，將所有資料寫入暫存檔，
       *> 並在此過程中將目標帳戶的資料替換成更新後的內容，最後更名覆蓋。
            OPEN INPUT ACCOUNT-FILE
            OPEN OUTPUT TEMP-ACCOUNT-FILE
            PERFORM UNTIL 1 = 2
                READ ACCOUNT-FILE
                    AT END EXIT PERFORM
                END-READ
                IF ACC-NUMBER = WS-ACCOUNT-NUMBER
                    MOVE TEMP-ACCOUNT-RECORD TO ACCOUNT-RECORD
                END-IF
                WRITE TEMP-ACCOUNT-RECORD FROM ACCOUNT-RECORD
                END-WRITE
            END-PERFORM
            CLOSE ACCOUNT-FILE
            CLOSE TEMP-ACCOUNT-FILE
            
            CALL "CBL_RENAME_FILE"
            USING "TEMP-ACCOUNT.SAM", "ACCOUNT.SAM"
            
            PERFORM 510-RECORD-TRANSACTION
            DISPLAY " "
            DISPLAY "存款成功!"
            DISPLAY "帳號: " WS-ACCOUNT-NUMBER
            DISPLAY "存款金額: " WS-TRANSACTION-AMT
            DISPLAY "新餘額: " WS-NEW-BALANCE.

        510-RECORD-TRANSACTION.
            MOVE 0 TO WS-TRANS-ID-NUM
            OPEN INPUT TRANS-FILE
            PERFORM UNTIL 1 = 2
                READ TRANS-FILE
                    AT END EXIT PERFORM
                END-READ
                COMPUTE WS-TRANS-ID-NUM = FUNCTION MAX(WS-TRANS-ID-NUM, 
                                         FUNCTION NUMVAL(TRANS-ID))
            END-PERFORM
            CLOSE TRANS-FILE
            ADD 1 TO WS-TRANS-ID-NUM
            MOVE WS-TRANS-ID-NUM TO TRANS-ID
            MOVE WS-ACCOUNT-NUMBER TO TRANS-ACC-NUMBER
            MOVE FUNCTION CURRENT-DATE(1:8) TO TRANS-DATE
            MOVE FUNCTION CURRENT-DATE(9:6) TO TRANS-TIME
            MOVE "D" TO TRANS-TYPE
            MOVE WS-TRANSACTION-AMT TO TRANS-AMOUNT
            COMPUTE TRANS-PREV-BAL = WS-NEW-BALANCE - WS-TRANSACTION-AMT
            MOVE WS-NEW-BALANCE TO TRANS-NEW-BAL
            MOVE "櫃台存款" TO TRANS-DESCRIPTION
            OPEN EXTEND TRANS-FILE
            WRITE TRANS-RECORD
            END-WRITE
            CLOSE TRANS-FILE.

        600-WITHDRAW.
            DISPLAY " "
            DISPLAY "=== 提款作業 ==="
            DISPLAY "請輸入帳號: " WITH NO ADVANCING
            ACCEPT WS-ACCOUNT-NUMBER
            MOVE "N" TO WS-CUSTOMER-EXISTS
            MOVE 0 TO WS-NEW-BALANCE
            OPEN INPUT ACCOUNT-FILE
            PERFORM UNTIL 1 = 2
                READ ACCOUNT-FILE
                    AT END EXIT PERFORM
                END-READ
                IF ACC-NUMBER = WS-ACCOUNT-NUMBER
                    MOVE "Y" TO WS-CUSTOMER-EXISTS
                    IF ACC-STATUS = "C"
                        DISPLAY "錯誤: 此帳戶已關閉"
                        EXIT PERFORM
                    END-IF
                    IF ACC-STATUS = "S"
                        DISPLAY "錯誤: 此帳戶已被凍結"
                        EXIT PERFORM
                    END-IF
                    DISPLAY "請輸入提款金額: " WITH NO ADVANCING
                    ACCEPT WS-TRANSACTION-AMT
                    IF WS-TRANSACTION-AMT <= 0
                        DISPLAY "錯誤: 提款金額必須大於零"
                        EXIT PERFORM
                    END-IF
                    IF ACC-BALANCE < WS-TRANSACTION-AMT
                        DISPLAY "錯誤: 餘額不足，無法提款"
                        DISPLAY "目前餘額: " ACC-BALANCE
                        EXIT PERFORM
                    END-IF
                    COMPUTE WS-NEW-BALANCE = ACC-BALANCE - WS-TRANSACTION-AMT
                    MOVE WS-NEW-BALANCE TO ACC-BALANCE
                    MOVE ACCOUNT-RECORD TO TEMP-ACCOUNT-RECORD
                    EXIT PERFORM
                END-IF
            END-PERFORM
            CLOSE ACCOUNT-FILE
            
            IF WS-CUSTOMER-EXISTS = "N"
                DISPLAY "錯誤: 找不到此帳號"
                EXIT PARAGRAPH
            END-IF
            
            IF WS-TRANSACTION-AMT <= 0 OR
               ACC-BALANCE < WS-TRANSACTION-AMT OR
               ACC-STATUS = "C" OR
               ACC-STATUS = "S"
                EXIT PARAGRAPH
            END-IF
            
            OPEN INPUT ACCOUNT-FILE
            OPEN OUTPUT TEMP-ACCOUNT-FILE
            PERFORM UNTIL 1 = 2
                READ ACCOUNT-FILE
                    AT END EXIT PERFORM
                END-READ
                IF ACC-NUMBER = WS-ACCOUNT-NUMBER
                    MOVE TEMP-ACCOUNT-RECORD TO ACCOUNT-RECORD
                END-IF
                WRITE TEMP-ACCOUNT-RECORD FROM ACCOUNT-RECORD
                END-WRITE
            END-PERFORM
            CLOSE ACCOUNT-FILE
            CLOSE TEMP-ACCOUNT-FILE
            
            CALL "CBL_RENAME_FILE"
            USING "TEMP-ACCOUNT.SAM", "ACCOUNT.SAM"
            
            PERFORM 610-RECORD-TRANSACTION
            DISPLAY " "
            DISPLAY "提款成功!"
            DISPLAY "帳號: " WS-ACCOUNT-NUMBER
            DISPLAY "提款金額: " WS-TRANSACTION-AMT
            DISPLAY "新餘額: " WS-NEW-BALANCE.

        610-RECORD-TRANSACTION.
            MOVE 0 TO WS-TRANS-ID-NUM
            OPEN INPUT TRANS-FILE
            PERFORM UNTIL 1 = 2
                READ TRANS-FILE
                    AT END EXIT PERFORM
                END-READ
                COMPUTE WS-TRANS-ID-NUM = FUNCTION MAX(WS-TRANS-ID-NUM, 
                                         FUNCTION NUMVAL(TRANS-ID))
            END-PERFORM
            CLOSE TRANS-FILE
            ADD 1 TO WS-TRANS-ID-NUM
            MOVE WS-TRANS-ID-NUM TO TRANS-ID
            MOVE WS-ACCOUNT-NUMBER TO TRANS-ACC-NUMBER
            MOVE FUNCTION CURRENT-DATE(1:8) TO TRANS-DATE
            MOVE FUNCTION CURRENT-DATE(9:6) TO TRANS-TIME
            MOVE "W" TO TRANS-TYPE
            MOVE WS-TRANSACTION-AMT TO TRANS-AMOUNT
            COMPUTE TRANS-PREV-BAL = WS-NEW-BALANCE + WS-TRANSACTION-AMT
            MOVE WS-NEW-BALANCE TO TRANS-NEW-BAL
            MOVE "櫃台提款" TO TRANS-DESCRIPTION
            OPEN EXTEND TRANS-FILE
            WRITE TRANS-RECORD
            END-WRITE
            CLOSE TRANS-FILE.

        700-TRANSFER.
            DISPLAY " "
            DISPLAY "=== 轉帳作業 ==="
            DISPLAY "請輸入來源帳號: " WITH NO ADVANCING
            ACCEPT WS-SOURCE-ACC-NUMBER
            MOVE "N" TO WS-CUSTOMER-EXISTS
            OPEN INPUT ACCOUNT-FILE
            PERFORM UNTIL 1 = 2
                READ ACCOUNT-FILE
                    AT END EXIT PERFORM
                END-READ
                IF ACC-NUMBER = WS-SOURCE-ACC-NUMBER
                    MOVE "Y" TO WS-CUSTOMER-EXISTS
                    IF ACC-STATUS = "C"
                        DISPLAY "錯誤: 來源帳戶已關閉"
                        EXIT PERFORM
                    END-IF
                    IF ACC-STATUS = "S"
                        DISPLAY "錯誤: 來源帳戶已被凍結"
                        EXIT PERFORM
                    END-IF
                    MOVE ACC-BALANCE TO WS-SOURCE-ACC-BALANCE
                    EXIT PERFORM
                END-IF
            END-PERFORM
            CLOSE ACCOUNT-FILE
            
            IF WS-CUSTOMER-EXISTS = "N"
                DISPLAY "錯誤: 找不到來源帳號"
                EXIT PARAGRAPH
            END-IF
            
            DISPLAY "請輸入目標帳號: " WITH NO ADVANCING
            ACCEPT WS-TARGET-ACC-NUMBER
            
            IF WS-SOURCE-ACC-NUMBER = WS-TARGET-ACC-NUMBER
                DISPLAY "錯誤: 來源和目標帳號不能相同"
                EXIT PARAGRAPH
            END-IF
            
            MOVE "N" TO WS-CUSTOMER-EXISTS
            OPEN INPUT ACCOUNT-FILE
            PERFORM UNTIL 1 = 2
                READ ACCOUNT-FILE
                    AT END EXIT PERFORM
                END-READ
                IF ACC-NUMBER = WS-TARGET-ACC-NUMBER
                    MOVE "Y" TO WS-CUSTOMER-EXISTS
                    IF ACC-STATUS = "C"
                        DISPLAY "錯誤: 目標帳戶已關閉"
                        EXIT PERFORM
                    END-IF
                    IF ACC-STATUS = "S"
                        DISPLAY "錯誤: 目標帳戶已被凍結"
                        EXIT PERFORM
                    END-IF
                    MOVE ACC-BALANCE TO WS-TARGET-ACC-BALANCE
                    EXIT PERFORM
                END-IF
            END-PERFORM
            CLOSE ACCOUNT-FILE
            
            IF WS-CUSTOMER-EXISTS = "N"
                DISPLAY "錯誤: 找不到目標帳號"
                EXIT PARAGRAPH
            END-IF
            
            DISPLAY "請輸入轉帳金額: " WITH NO ADVANCING
            ACCEPT WS-TRANSACTION-AMT
            
            IF WS-TRANSACTION-AMT <= 0
                DISPLAY "錯誤: 轉帳金額必須大於零"
                EXIT PARAGRAPH
            END-IF
            
            IF WS-SOURCE-ACC-BALANCE < WS-TRANSACTION-AMT
                DISPLAY "錯誤: 來源帳戶餘額不足，無法轉帳"
                DISPLAY "目前餘額: " WS-SOURCE-ACC-BALANCE
                EXIT PARAGRAPH
            END-IF
            
            OPEN INPUT ACCOUNT-FILE
            OPEN OUTPUT TEMP-ACCOUNT-FILE
            PERFORM UNTIL 1 = 2
                READ ACCOUNT-FILE
                    AT END EXIT PERFORM
                END-READ
                IF ACC-NUMBER = WS-SOURCE-ACC-NUMBER
                    COMPUTE ACC-BALANCE = ACC-BALANCE - WS-TRANSACTION-AMT
                END-IF
                IF ACC-NUMBER = WS-TARGET-ACC-NUMBER
                    COMPUTE ACC-BALANCE = ACC-BALANCE + WS-TRANSACTION-AMT
                END-IF
                WRITE TEMP-ACCOUNT-RECORD FROM ACCOUNT-RECORD
                END-WRITE
            END-PERFORM
            CLOSE ACCOUNT-FILE
            CLOSE TEMP-ACCOUNT-FILE
            
            CALL "CBL_RENAME_FILE"
            USING "TEMP-ACCOUNT.SAM", "ACCOUNT.SAM"
            
            PERFORM 710-RECORD-TRANSFER-TRANSACTION
            DISPLAY " "
            DISPLAY "轉帳成功!"
            DISPLAY "來源帳號: " WS-SOURCE-ACC-NUMBER
            DISPLAY "目標帳號: " WS-TARGET-ACC-NUMBER
            DISPLAY "轉帳金額: " WS-TRANSACTION-AMT
            COMPUTE WS-NEW-BALANCE = WS-SOURCE-ACC-BALANCE - WS-TRANSACTION-AMT
            DISPLAY "來源帳戶新餘額: " WS-NEW-BALANCE.

        710-RECORD-TRANSFER-TRANSACTION.
            MOVE 0 TO WS-TRANS-ID-NUM
            OPEN INPUT TRANS-FILE
            PERFORM UNTIL 1 = 2
                READ TRANS-FILE
                    AT END EXIT PERFORM
                END-READ
                COMPUTE WS-TRANS-ID-NUM = FUNCTION MAX(WS-TRANS-ID-NUM, 
                                         FUNCTION NUMVAL(TRANS-ID))
            END-PERFORM
            CLOSE TRANS-FILE
            
            ADD 1 TO WS-TRANS-ID-NUM
            MOVE WS-TRANS-ID-NUM TO TRANS-ID
            MOVE WS-SOURCE-ACC-NUMBER TO TRANS-ACC-NUMBER
            MOVE FUNCTION CURRENT-DATE(1:8) TO TRANS-DATE
            MOVE FUNCTION CURRENT-DATE(9:6) TO TRANS-TIME
            MOVE "T" TO TRANS-TYPE
            MOVE WS-TRANSACTION-AMT TO TRANS-AMOUNT
            MOVE WS-SOURCE-ACC-BALANCE TO TRANS-PREV-BAL
            COMPUTE TRANS-NEW-BAL = WS-SOURCE-ACC-BALANCE - WS-TRANSACTION-AMT
            
       *> STRING 用於拼接字串。DELIMITED BY SIZE 代表使用整個欄位大小進行拼接。
            STRING "轉出至帳號: " WS-TARGET-ACC-NUMBER 
                DELIMITED BY SIZE INTO TRANS-DESCRIPTION
            
            OPEN EXTEND TRANS-FILE
            WRITE TRANS-RECORD
            END-WRITE
            CLOSE TRANS-FILE
            
            ADD 1 TO WS-TRANS-ID-NUM
            MOVE WS-TRANS-ID-NUM TO TRANS-ID
            MOVE WS-TARGET-ACC-NUMBER TO TRANS-ACC-NUMBER
            MOVE FUNCTION CURRENT-DATE(1:8) TO TRANS-DATE
            MOVE FUNCTION CURRENT-DATE(9:6) TO TRANS-TIME
            MOVE "T" TO TRANS-TYPE
            MOVE WS-TRANSACTION-AMT TO TRANS-AMOUNT
            MOVE WS-TARGET-ACC-BALANCE TO TRANS-PREV-BAL
            COMPUTE TRANS-NEW-BAL = WS-TARGET-ACC-BALANCE + WS-TRANSACTION-AMT
            
            STRING "轉入自帳號: " WS-SOURCE-ACC-NUMBER 
                DELIMITED BY SIZE INTO TRANS-DESCRIPTION
            
            OPEN EXTEND TRANS-FILE
            WRITE TRANS-RECORD
            END-WRITE
            CLOSE TRANS-FILE.

        800-CHECK-BALANCE.
            DISPLAY " "
            DISPLAY "=== 查詢餘額 ==="
            DISPLAY "請輸入帳號: " WITH NO ADVANCING
            ACCEPT WS-ACCOUNT-NUMBER
            MOVE "N" TO WS-CUSTOMER-EXISTS
            MOVE 0 TO WS-TRANS-COUNT
            OPEN INPUT ACCOUNT-FILE
            PERFORM UNTIL 1 = 2
                READ ACCOUNT-FILE
                    AT END EXIT PERFORM
                END-READ
                IF ACC-NUMBER = WS-ACCOUNT-NUMBER
                    MOVE "Y" TO WS-CUSTOMER-EXISTS
                    DISPLAY " "
                    DISPLAY "帳戶資訊:"
                    DISPLAY "-------------------------"
                    DISPLAY "帳號: " ACC-NUMBER
                    DISPLAY "客戶ID: " ACC-CUST-ID
                    DISPLAY "帳戶類型: " 
                        FUNCTION TRIM(
                        FUNCTION SUBSTITUTE(ACC-TYPE, 
                                "S", "儲蓄帳戶", 
                                "C", "支票帳戶"))
                    DISPLAY "餘額: " ACC-BALANCE
                    DISPLAY "開戶日期: " ACC-OPEN-DATE
                    DISPLAY "帳戶狀態: " 
                        FUNCTION TRIM(
                        FUNCTION SUBSTITUTE(ACC-STATUS, 
                                "A", "啟用", 
                                "C", "關閉",
                                "S", "凍結"))
                    
                    PERFORM 810-SHOW-CUSTOMER-INFO
                    
                    DISPLAY " "
                    DISPLAY "最近5筆交易記錄:"
                    DISPLAY "-------------------------"
                    PERFORM 820-SHOW-RECENT-TRANSACTIONS
                    EXIT PERFORM
                END-IF
            END-PERFORM
            
            IF WS-CUSTOMER-EXISTS = "N"
                DISPLAY "錯誤: 找不到此帳號"
            END-IF
            CLOSE ACCOUNT-FILE.

        810-SHOW-CUSTOMER-INFO.
            OPEN INPUT CUSTOMER-FILE
            PERFORM UNTIL 1 = 2
                READ CUSTOMER-FILE
                    AT END EXIT PERFORM
                END-READ
                IF CUST-ID = ACC-CUST-ID
                    DISPLAY " "
                    DISPLAY "客戶資訊:"
                    DISPLAY "-------------------------"
                    DISPLAY "姓名: " CUST-NAME
                    DISPLAY "身分證字號: " CUST-ID-NUMBER
                    DISPLAY "地址: " CUST-ADDRESS
                    DISPLAY "電話: " CUST-PHONE
                    EXIT PERFORM
                END-IF
            END-PERFORM
            CLOSE CUSTOMER-FILE.

        820-SHOW-RECENT-TRANSACTIONS.
            MOVE 0 TO WS-TRANS-TOTAL
            OPEN INPUT TRANS-FILE
            PERFORM UNTIL 1 = 2
                READ TRANS-FILE
                    AT END EXIT PERFORM
                END-READ
                IF TRANS-ACC-NUMBER = WS-ACCOUNT-NUMBER
                    ADD 1 TO WS-TRANS-TOTAL
       *> === 環形緩衝區 (Ring Buffer) 索引計算 ===
       *> 因為不確定總共有幾筆交易，故利用 MOD 5 運算將資料循環填入長度 5 的陣列中。
                    COMPUTE WS-RING-IDX =
                        FUNCTION MOD(WS-TRANS-TOTAL - 1, 5) + 1
                    MOVE TRANS-DATE TO WS-RING-DATE(WS-RING-IDX)
                    MOVE TRANS-TIME TO WS-RING-TIME(WS-RING-IDX)
                    MOVE TRANS-TYPE TO WS-RING-TYPE(WS-RING-IDX)
                    MOVE TRANS-AMOUNT TO WS-RING-AMOUNT(WS-RING-IDX)
                    MOVE TRANS-PREV-BAL TO WS-RING-PREV(WS-RING-IDX)
                    MOVE TRANS-NEW-BAL TO WS-RING-NEW(WS-RING-IDX)
                    MOVE TRANS-DESCRIPTION TO WS-RING-DESC(WS-RING-IDX)
                END-IF
            END-PERFORM
            CLOSE TRANS-FILE
            
            IF WS-TRANS-TOTAL = 0
                DISPLAY "此帳戶尚無交易記錄"
                EXIT PARAGRAPH
            END-IF
            
       *> === 判斷環形緩衝區起點與顯示筆數 ===
            IF WS-TRANS-TOTAL <= 5
                MOVE 1 TO WS-RING-START
                MOVE WS-TRANS-TOTAL TO WS-TRANS-COUNT
            ELSE
                COMPUTE WS-RING-START =
                    FUNCTION MOD(WS-TRANS-TOTAL, 5) + 1
                MOVE 5 TO WS-TRANS-COUNT
            END-IF
            
       *> PERFORM VARYING 相當於 for 迴圈。
            PERFORM VARYING WS-RING-I FROM 1 BY 1
                UNTIL WS-RING-I > WS-TRANS-COUNT
                COMPUTE WS-RING-IDX =
                    FUNCTION MOD(WS-RING-START + WS-RING-I - 2, 5) + 1
                DISPLAY "日期: " WS-RING-DATE(WS-RING-IDX)
                        " 時間: " WS-RING-TIME(WS-RING-IDX)
                DISPLAY "類型: "
                    FUNCTION TRIM(
                    FUNCTION SUBSTITUTE(
                        WS-RING-TYPE(WS-RING-IDX),
                        "D", "存款",
                        "W", "提款",
                        "T", "轉帳"))
                DISPLAY "金額: " WS-RING-AMOUNT(WS-RING-IDX)
                DISPLAY "交易前餘額: " WS-RING-PREV(WS-RING-IDX)
                DISPLAY "交易後餘額: " WS-RING-NEW(WS-RING-IDX)
                DISPLAY "描述: " WS-RING-DESC(WS-RING-IDX)
                DISPLAY "-------------------------"
            END-PERFORM.

        900-CLEANUP.
       *> 安全關閉所有可能已開啟的檔案描述元，避免資源洩漏。
            CLOSE CUSTOMER-FILE
            IF CUST-FILE-STATUS NOT = "00"
                CONTINUE
            END-IF
            CLOSE ACCOUNT-FILE
            IF ACC-FILE-STATUS NOT = "00"
                CONTINUE
            END-IF
            CLOSE TRANS-FILE
            IF TRANS-FILE-STATUS NOT = "00"
                CONTINUE
            END-IF
            CLOSE TEMP-ACCOUNT-FILE
            IF ACC-FILE-STATUS NOT = "00"
                CONTINUE
            END-IF.
        END PROGRAM BANK.
