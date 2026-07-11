       IDENTIFICATION DIVISION.
       PROGRAM-ID. BANK.
       AUTHOR. Scorpio-meow.
       DATE-WRITTEN. 2025-03-07.
       
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. PC.
       OBJECT-COMPUTER. PC.
       
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CUSTOMER-FILE ASSIGN TO "CUSTOMER.SAM"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT ACCOUNT-FILE ASSIGN TO "ACCOUNT.SAM"
               ORGANIZATION IS LINE SEQUENTIAL.
               
           SELECT TRANS-FILE ASSIGN TO "TRANS.SAM"
               ORGANIZATION IS LINE SEQUENTIAL.
               
           SELECT TEMP-ACCOUNT-FILE ASSIGN TO "TEMP-ACCOUNT.SAM"
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD  CUSTOMER-FILE.
       01  CUSTOMER-RECORD.
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
           05  TRANS-AMOUNT        PIC 9(7)V99.
           05  TRANS-PREV-BAL      PIC 9(7)V99.    *> 新增：交易前餘額
           05  TRANS-NEW-BAL       PIC 9(7)V99.    *> 新增：交易後餘額
           05  TRANS-DESCRIPTION   PIC X(30).

       FD  TEMP-ACCOUNT-FILE.
       01  TEMP-ACCOUNT-RECORD     PIC X(40).
           
       WORKING-STORAGE SECTION.
       
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
           05  WS-TRANS-COUNT      PIC 9(2) VALUE 0.  *> 添加此行
           
       01  CUSTOMER-VARIABLES.
           05  WS-NEW-CUST-ID      PIC X(10).
           05  WS-NEXT-CUST-ID     PIC 9(10).
           05  WS-NEW-ACC-NUMBER   PIC X(10).
           05  WS-NEXT-ACC-NUMBER  PIC 9(10).
           05  WS-CUSTOMER-EXISTS  PIC X VALUE "N".
               88  CUSTOMER-EXISTS VALUE "Y".

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
       PROCEDURE DIVISION.
       PERFORM 200-PROCESS-MENU.
       PERFORM 900-CLEANUP.
       STOP RUN.

       200-PROCESS-MENU.
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
               DISPLAY "請輸入您的選擇 (1-9): " WITH NO ADVANCING
               ACCEPT MENU-CHOICE
               
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
           
           *> 生成唯一客戶ID
           PERFORM 310-GENERATE-CUSTOMER-ID
           
           DISPLAY "客戶ID將為: " WS-NEW-CUST-ID
           
           *> 收集客戶資訊
           DISPLAY "請輸入身分證字號: " WITH NO ADVANCING
           ACCEPT CUST-ID-NUMBER
           
           DISPLAY "請輸入客戶姓名: " WITH NO ADVANCING
           ACCEPT CUST-NAME
           
           DISPLAY "請輸入客戶地址: " WITH NO ADVANCING
           ACCEPT CUST-ADDRESS
           
           DISPLAY "請輸入客戶電話: " WITH NO ADVANCING
           ACCEPT CUST-PHONE
           
           *> 寫入客戶記錄
           MOVE WS-NEW-CUST-ID TO CUST-ID
           
           OPEN EXTEND CUSTOMER-FILE
           WRITE CUSTOMER-RECORD
           END-WRITE
           CLOSE CUSTOMER-FILE
           
           DISPLAY " "
           DISPLAY "客戶資料新增成功!"
           DISPLAY "客戶ID: " WS-NEW-CUST-ID.
           
       310-GENERATE-CUSTOMER-ID.
           *> 讀取所有現有客戶來找到最大ID
           MOVE 0 TO WS-NEXT-CUST-ID
           
           OPEN INPUT CUSTOMER-FILE
           PERFORM UNTIL 1 = 2
               READ CUSTOMER-FILE
                   AT END EXIT PERFORM
               END-READ
               
               *> 將客戶ID轉換為數字以比較
               COMPUTE WS-NEXT-CUST-ID = FUNCTION MAX(WS-NEXT-CUST-ID, 
                                         FUNCTION NUMVAL(CUST-ID))
           END-PERFORM
           CLOSE CUSTOMER-FILE
           
           *> 增加ID值
           ADD 1 TO WS-NEXT-CUST-ID
           
           *> 格式化為6位數的字符串
           MOVE WS-NEXT-CUST-ID TO WS-NEW-CUST-ID.
           
       400-OPEN-ACCOUNT.
           DISPLAY " "
           DISPLAY "=== 開立新帳戶 ==="
           
           *> 確認客戶存在
           DISPLAY "請輸入客戶ID: " WITH NO ADVANCING
           ACCEPT ACC-CUST-ID
           
           PERFORM 410-VERIFY-CUSTOMER
           
           IF NOT CUSTOMER-EXISTS
               DISPLAY "錯誤: 找不到此客戶ID，請先建立客戶資料"
           ELSE
               *> 生成唯一帳號
               PERFORM 420-GENERATE-ACCOUNT-NUMBER
               DISPLAY "新帳號將為: " WS-NEW-ACC-NUMBER
               
               *> 選擇帳戶類型
               DISPLAY " "
               DISPLAY "請選擇帳戶類型:"
               DISPLAY "S - 儲蓄帳戶"
               DISPLAY "C - 支票帳戶"
               DISPLAY "請輸入 (S/C): " WITH NO ADVANCING
               ACCEPT ACC-TYPE
               
               *> 驗證帳戶類型
               IF ACC-TYPE = "S" OR ACC-TYPE = "C"
                   *> 輸入初始存款金額
                   DISPLAY "請輸入初始存款金額: " WITH NO ADVANCING
                   ACCEPT ACC-BALANCE
                   
                   *> 設定開戶日期
                   MOVE FUNCTION CURRENT-DATE(1:8) TO ACC-OPEN-DATE
                   
                   *> 設定帳戶狀態
                   MOVE "A" TO ACC-STATUS
                   
                   *> 保存帳號
                   MOVE WS-NEW-ACC-NUMBER TO ACC-NUMBER
                   
                   *> 寫入帳戶記錄
                   OPEN EXTEND ACCOUNT-FILE
                   WRITE ACCOUNT-RECORD
                   END-WRITE
                   CLOSE ACCOUNT-FILE
                   
                   *> 記錄初始存款交易
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
           *> 讀取所有現有帳戶來找到最大帳號
           MOVE 0 TO WS-NEXT-ACC-NUMBER
           
           OPEN INPUT ACCOUNT-FILE
           PERFORM UNTIL 1 = 2
               READ ACCOUNT-FILE
                   AT END EXIT PERFORM
               END-READ
               
               *> 將帳號轉換為數字以比較
               COMPUTE WS-NEXT-ACC-NUMBER = 
               FUNCTION MAX(WS-NEXT-ACC-NUMBER, 
               FUNCTION NUMVAL(ACC-NUMBER))
           END-PERFORM
           CLOSE ACCOUNT-FILE
           
           *> 增加帳號值
           ADD 1 TO WS-NEXT-ACC-NUMBER
           
           *> 格式化為10位數的字符串
           MOVE WS-NEXT-ACC-NUMBER TO WS-NEW-ACC-NUMBER.
           
       430-RECORD-INITIAL-DEPOSIT.
           *> 生成交易ID
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
           
           *> 設定交易資訊
           MOVE ACC-NUMBER TO TRANS-ACC-NUMBER
           MOVE FUNCTION CURRENT-DATE(1:8) TO TRANS-DATE
           MOVE FUNCTION CURRENT-DATE(9:6) TO TRANS-TIME
           MOVE "D" TO TRANS-TYPE
           MOVE ACC-BALANCE TO TRANS-AMOUNT
           MOVE 0 TO TRANS-PREV-BAL
           MOVE ACC-BALANCE TO TRANS-NEW-BAL
           MOVE "初始存款" TO TRANS-DESCRIPTION
           
           *> 寫入交易記錄
           OPEN EXTEND TRANS-FILE
           WRITE TRANS-RECORD
           END-WRITE
           CLOSE TRANS-FILE.

       500-DEPOSIT.
           DISPLAY " "
           DISPLAY "=== 存款作業 ==="
           
           *> 請求帳號
           DISPLAY "請輸入帳號: " WITH NO ADVANCING
           ACCEPT WS-ACCOUNT-NUMBER
           
           *> 驗證帳號是否存在並取得資訊
           MOVE "N" TO WS-CUSTOMER-EXISTS
           MOVE 0 TO WS-NEW-BALANCE
           
           *> 讀取所有帳戶並找到匹配的帳戶
           OPEN INPUT ACCOUNT-FILE
           PERFORM UNTIL 1 = 2
               READ ACCOUNT-FILE
                   AT END EXIT PERFORM
               END-READ
               
               IF ACC-NUMBER = WS-ACCOUNT-NUMBER
                   MOVE "Y" TO WS-CUSTOMER-EXISTS
                   
                   *> 確認帳戶狀態
                   IF ACC-STATUS = "C"
                       DISPLAY "錯誤: 此帳戶已關閉"
                       EXIT PERFORM
                   END-IF
                   
                   IF ACC-STATUS = "S"
                       DISPLAY "錯誤: 此帳戶已被凍結"
                       EXIT PERFORM
                   END-IF
                   
                   *> 輸入存款金額
                   DISPLAY "請輸入存款金額: " WITH NO ADVANCING
                   ACCEPT WS-TRANSACTION-AMT
                   
                   IF WS-TRANSACTION-AMT <= 0
                       DISPLAY "錯誤: 存款金額必須大於零"
                       EXIT PERFORM
                   END-IF
                   
                   *> 更新餘額
                   COMPUTE WS-NEW-BALANCE = ACC-BALANCE + WS-TRANSACTION-AMT
                   MOVE WS-NEW-BALANCE TO ACC-BALANCE
                   
                   *> 儲存當前帳戶資料
                   MOVE ACCOUNT-RECORD TO TEMP-ACCOUNT-RECORD
                   
                   EXIT PERFORM
               END-IF
           END-PERFORM
           CLOSE ACCOUNT-FILE
           
           IF WS-CUSTOMER-EXISTS = "N"
               DISPLAY "錯誤: 找不到此帳號"
               EXIT PARAGRAPH
           END-IF
           
           *> 如果金額無效或帳戶狀態不正確，退出
           IF WS-TRANSACTION-AMT <= 0 OR
              ACC-STATUS = "C" OR
              ACC-STATUS = "S"
               EXIT PARAGRAPH
           END-IF
           
           *> 重寫所有帳戶但更新目標帳戶
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
           
           *> 用臨時檔案替換原始檔案
           CALL "CBL_RENAME_FILE"
           USING "TEMP-ACCOUNT.SAM", "ACCOUNT.SAM", 0
           
           *> 記錄交易
           PERFORM 510-RECORD-TRANSACTION
           
           DISPLAY " "
           DISPLAY "存款成功!"
           DISPLAY "帳號: " WS-ACCOUNT-NUMBER
           DISPLAY "存款金額: " WS-TRANSACTION-AMT
           DISPLAY "新餘額: " WS-NEW-BALANCE.
       
       510-RECORD-TRANSACTION.
           *> 生成交易ID
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
           
           *> 設定交易資訊
           MOVE WS-ACCOUNT-NUMBER TO TRANS-ACC-NUMBER
           MOVE FUNCTION CURRENT-DATE(1:8) TO TRANS-DATE
           MOVE FUNCTION CURRENT-DATE(9:6) TO TRANS-TIME
           MOVE "D" TO TRANS-TYPE
           MOVE WS-TRANSACTION-AMT TO TRANS-AMOUNT
           COMPUTE TRANS-PREV-BAL = WS-NEW-BALANCE - WS-TRANSACTION-AMT
           MOVE WS-NEW-BALANCE TO TRANS-NEW-BAL
           MOVE "櫃台存款" TO TRANS-DESCRIPTION
           
           *> 寫入交易記錄
           OPEN EXTEND TRANS-FILE
           WRITE TRANS-RECORD
           END-WRITE
           CLOSE TRANS-FILE.
       
       600-WITHDRAW.
           DISPLAY " "
           DISPLAY "=== 提款作業 ==="
           
           *> 請求帳號
           DISPLAY "請輸入帳號: " WITH NO ADVANCING
           ACCEPT WS-ACCOUNT-NUMBER
           
           *> 驗證帳號是否存在並取得資訊
           MOVE "N" TO WS-CUSTOMER-EXISTS
           MOVE 0 TO WS-NEW-BALANCE
           
           *> 讀取所有帳戶並找到匹配的帳戶
           OPEN INPUT ACCOUNT-FILE
           PERFORM UNTIL 1 = 2
               READ ACCOUNT-FILE
                   AT END EXIT PERFORM
               END-READ
               
               IF ACC-NUMBER = WS-ACCOUNT-NUMBER
                   MOVE "Y" TO WS-CUSTOMER-EXISTS
                   
                   *> 確認帳戶狀態
                   IF ACC-STATUS = "C"
                       DISPLAY "錯誤: 此帳戶已關閉"
                       EXIT PERFORM
                   END-IF
                   
                   IF ACC-STATUS = "S"
                       DISPLAY "錯誤: 此帳戶已被凍結"
                       EXIT PERFORM
                   END-IF
                   
                   *> 輸入提款金額
                   DISPLAY "請輸入提款金額: " WITH NO ADVANCING
                   ACCEPT WS-TRANSACTION-AMT
                   
                   IF WS-TRANSACTION-AMT <= 0
                       DISPLAY "錯誤: 提款金額必須大於零"
                       EXIT PERFORM
                   END-IF
                   
                   *> 檢查餘額是否足夠
                   IF ACC-BALANCE < WS-TRANSACTION-AMT
                       DISPLAY "錯誤: 餘額不足，無法提款"
                       DISPLAY "目前餘額: " ACC-BALANCE
                       EXIT PERFORM
                   END-IF
                   
                   *> 更新餘額
                   COMPUTE WS-NEW-BALANCE = ACC-BALANCE - WS-TRANSACTION-AMT
                   MOVE WS-NEW-BALANCE TO ACC-BALANCE
                   
                   *> 儲存當前帳戶資料
                   MOVE ACCOUNT-RECORD TO TEMP-ACCOUNT-RECORD
                   
                   EXIT PERFORM
               END-IF
           END-PERFORM
           CLOSE ACCOUNT-FILE
           
           IF WS-CUSTOMER-EXISTS = "N"
               DISPLAY "錯誤: 找不到此帳號"
               EXIT PARAGRAPH
           END-IF
           
           *> 如果金額無效、餘額不足或帳戶狀態不正確，退出
           IF WS-TRANSACTION-AMT <= 0 OR
              ACC-BALANCE < WS-TRANSACTION-AMT OR
              ACC-STATUS = "C" OR
              ACC-STATUS = "S"
               EXIT PARAGRAPH
           END-IF
           
           *> 重寫所有帳戶但更新目標帳戶
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
           
           *> 用臨時檔案替換原始檔案
           CALL "CBL_RENAME_FILE"
           USING "TEMP-ACCOUNT.SAM", "ACCOUNT.SAM", 0
           
           *> 記錄交易
           PERFORM 610-RECORD-TRANSACTION
           
           DISPLAY " "
           DISPLAY "提款成功!"
           DISPLAY "帳號: " WS-ACCOUNT-NUMBER
           DISPLAY "提款金額: " WS-TRANSACTION-AMT
           DISPLAY "新餘額: " WS-NEW-BALANCE.
       
       610-RECORD-TRANSACTION.
           *> 生成交易ID
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
           
           *> 設定交易資訊
           MOVE WS-ACCOUNT-NUMBER TO TRANS-ACC-NUMBER
           MOVE FUNCTION CURRENT-DATE(1:8) TO TRANS-DATE
           MOVE FUNCTION CURRENT-DATE(9:6) TO TRANS-TIME
           MOVE "W" TO TRANS-TYPE
           MOVE WS-TRANSACTION-AMT TO TRANS-AMOUNT
           COMPUTE TRANS-PREV-BAL = WS-NEW-BALANCE + WS-TRANSACTION-AMT
           MOVE WS-NEW-BALANCE TO TRANS-NEW-BAL
           MOVE "櫃台提款" TO TRANS-DESCRIPTION
           
           *> 寫入交易記錄
           OPEN EXTEND TRANS-FILE
           WRITE TRANS-RECORD
           END-WRITE
           CLOSE TRANS-FILE.
       
       700-TRANSFER.
           DISPLAY " "
           DISPLAY "=== 轉帳作業 ==="
           
           *> 請求來源帳號
           DISPLAY "請輸入來源帳號: " WITH NO ADVANCING
           ACCEPT WS-SOURCE-ACC-NUMBER
           
           *> 驗證來源帳號是否存在
           MOVE "N" TO WS-CUSTOMER-EXISTS
           
           OPEN INPUT ACCOUNT-FILE
           PERFORM UNTIL 1 = 2
               READ ACCOUNT-FILE
                   AT END EXIT PERFORM
               END-READ
               
               IF ACC-NUMBER = WS-SOURCE-ACC-NUMBER
                   MOVE "Y" TO WS-CUSTOMER-EXISTS
                   
                   *> 確認帳戶狀態
                   IF ACC-STATUS = "C"
                       DISPLAY "錯誤: 來源帳戶已關閉"
                       EXIT PERFORM
                   END-IF
                   
                   IF ACC-STATUS = "S"
                       DISPLAY "錯誤: 來源帳戶已被凍結"
                       EXIT PERFORM
                   END-IF
                   
                   *> 保存來源帳戶餘額
                   MOVE ACC-BALANCE TO WS-SOURCE-ACC-BALANCE
                   EXIT PERFORM
               END-IF
           END-PERFORM
           CLOSE ACCOUNT-FILE
           
           IF WS-CUSTOMER-EXISTS = "N"
               DISPLAY "錯誤: 找不到來源帳號"
               EXIT PARAGRAPH
           END-IF
           
           *> 請求目標帳號
           DISPLAY "請輸入目標帳號: " WITH NO ADVANCING
           ACCEPT WS-TARGET-ACC-NUMBER
           
           *> 檢查來源和目標帳號不同
           IF WS-SOURCE-ACC-NUMBER = WS-TARGET-ACC-NUMBER
               DISPLAY "錯誤: 來源和目標帳號不能相同"
               EXIT PARAGRAPH
           END-IF
           
           *> 驗證目標帳號是否存在
           MOVE "N" TO WS-CUSTOMER-EXISTS
           
           OPEN INPUT ACCOUNT-FILE
           PERFORM UNTIL 1 = 2
               READ ACCOUNT-FILE
                   AT END EXIT PERFORM
               END-READ
               
               IF ACC-NUMBER = WS-TARGET-ACC-NUMBER
                   MOVE "Y" TO WS-CUSTOMER-EXISTS
                   
                   *> 確認帳戶狀態
                   IF ACC-STATUS = "C"
                       DISPLAY "錯誤: 目標帳戶已關閉"
                       EXIT PERFORM
                   END-IF
                   
                   IF ACC-STATUS = "S"
                       DISPLAY "錯誤: 目標帳戶已被凍結"
                       EXIT PERFORM
                   END-IF
                   
                   *> 保存目標帳戶餘額
                   MOVE ACC-BALANCE TO WS-TARGET-ACC-BALANCE
                   EXIT PERFORM
               END-IF
           END-PERFORM
           CLOSE ACCOUNT-FILE
           
           IF WS-CUSTOMER-EXISTS = "N"
               DISPLAY "錯誤: 找不到目標帳號"
               EXIT PARAGRAPH
           END-IF
           
           *> 輸入轉帳金額
           DISPLAY "請輸入轉帳金額: " WITH NO ADVANCING
           ACCEPT WS-TRANSACTION-AMT
           
           IF WS-TRANSACTION-AMT <= 0
               DISPLAY "錯誤: 轉帳金額必須大於零"
               EXIT PARAGRAPH
           END-IF
           
           *> 檢查來源帳戶餘額是否足夠
           IF WS-SOURCE-ACC-BALANCE < WS-TRANSACTION-AMT
               DISPLAY "錯誤: 來源帳戶餘額不足，無法轉帳"
               DISPLAY "目前餘額: " WS-SOURCE-ACC-BALANCE
               EXIT PARAGRAPH
           END-IF
           
           *> 更新來源和目標帳戶餘額
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
           
           *> 用臨時檔案替換原始檔案
           CALL "CBL_RENAME_FILE"
           USING "TEMP-ACCOUNT.SAM", "ACCOUNT.SAM", 0
           
           *> 記錄轉帳交易
           PERFORM 710-RECORD-TRANSFER-TRANSACTION
           
           DISPLAY " "
           DISPLAY "轉帳成功!"
           DISPLAY "來源帳號: " WS-SOURCE-ACC-NUMBER
           DISPLAY "目標帳號: " WS-TARGET-ACC-NUMBER
           DISPLAY "轉帳金額: " WS-TRANSACTION-AMT
           COMPUTE WS-NEW-BALANCE = WS-SOURCE-ACC-BALANCE - WS-TRANSACTION-AMT
           DISPLAY "來源帳戶新餘額: " WS-NEW-BALANCE.
           
       710-RECORD-TRANSFER-TRANSACTION.
           *> 生成交易ID
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
           
           *> 記錄來源帳戶交易
           MOVE WS-TRANS-ID-NUM TO TRANS-ID
           MOVE WS-SOURCE-ACC-NUMBER TO TRANS-ACC-NUMBER
           MOVE FUNCTION CURRENT-DATE(1:8) TO TRANS-DATE
           MOVE FUNCTION CURRENT-DATE(9:6) TO TRANS-TIME
           MOVE "T" TO TRANS-TYPE
           MOVE WS-TRANSACTION-AMT TO TRANS-AMOUNT
           MOVE WS-SOURCE-ACC-BALANCE TO TRANS-PREV-BAL
           COMPUTE TRANS-NEW-BAL = WS-SOURCE-ACC-BALANCE - WS-TRANSACTION-AMT
           MOVE "轉出至帳號: " TO TRANS-DESCRIPTION
           STRING "轉出至帳號: " WS-TARGET-ACC-NUMBER 
               DELIMITED BY SIZE INTO TRANS-DESCRIPTION
           
           OPEN EXTEND TRANS-FILE
           WRITE TRANS-RECORD
           END-WRITE
           CLOSE TRANS-FILE
           
           *> 記錄目標帳戶交易
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
           
           *> 請求帳號
           DISPLAY "請輸入帳號: " WITH NO ADVANCING
           ACCEPT WS-ACCOUNT-NUMBER
           
           *> 驗證帳號是否存在並顯示餘額
           MOVE "N" TO WS-CUSTOMER-EXISTS
           MOVE 0 TO WS-TRANS-COUNT
           
           OPEN INPUT ACCOUNT-FILE
           PERFORM UNTIL 1 = 2
               READ ACCOUNT-FILE
                   AT END EXIT PERFORM
               END-READ
               
               IF ACC-NUMBER = WS-ACCOUNT-NUMBER
                   MOVE "Y" TO WS-CUSTOMER-EXISTS
                   
                   *> 顯示帳戶狀態資訊
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
                   
                   *> 顯示客戶資訊
                   PERFORM 810-SHOW-CUSTOMER-INFO
                   
                   *> 顯示最近交易記錄
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
           *> 查找並顯示客戶資訊
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
           *> 清空計數器；不在讀到第 5 筆時停止
           MOVE 0 TO WS-TRANS-TOTAL

           *> 必須讀完整個 TRANS.SAM
           OPEN INPUT TRANS-FILE
           PERFORM UNTIL 1 = 2
               READ TRANS-FILE
                   AT END
                       EXIT PERFORM
               END-READ

               *> 只處理目前查詢帳號的交易
               IF TRANS-ACC-NUMBER = WS-ACCOUNT-NUMBER
                   ADD 1 TO WS-TRANS-TOTAL

                   *> 算出這筆交易要放在第 1 至第 5 格哪一格
                   COMPUTE WS-RING-IDX =
                       FUNCTION MOD(WS-TRANS-TOTAL - 1, 5) + 1

                   *> 將交易完整複製到該暫存格
                   MOVE TRANS-DATE
                       TO WS-RING-DATE(WS-RING-IDX)
                   MOVE TRANS-TIME
                       TO WS-RING-TIME(WS-RING-IDX)
                   MOVE TRANS-TYPE
                       TO WS-RING-TYPE(WS-RING-IDX)
                   MOVE TRANS-AMOUNT
                       TO WS-RING-AMOUNT(WS-RING-IDX)
                   MOVE TRANS-PREV-BAL
                       TO WS-RING-PREV(WS-RING-IDX)
                   MOVE TRANS-NEW-BAL
                       TO WS-RING-NEW(WS-RING-IDX)
                   MOVE TRANS-DESCRIPTION
                       TO WS-RING-DESC(WS-RING-IDX)
               END-IF
           END-PERFORM
           CLOSE TRANS-FILE

           IF WS-TRANS-TOTAL = 0
               DISPLAY "此帳戶尚無交易記錄"
               EXIT PARAGRAPH
           END-IF

           *> 不足 5 筆時從第 1 格開始；
           *> 超過 5 筆時，找出目前最舊交易所在的格子
           IF WS-TRANS-TOTAL <= 5
               MOVE 1 TO WS-RING-START
               MOVE WS-TRANS-TOTAL TO WS-TRANS-COUNT
           ELSE
               COMPUTE WS-RING-START =
                   FUNCTION MOD(WS-TRANS-TOTAL, 5) + 1
               MOVE 5 TO WS-TRANS-COUNT
           END-IF

           *> 由舊到新依序輸出最後 5 筆
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
               DISPLAY "金額: "
                   WS-RING-AMOUNT(WS-RING-IDX)
               DISPLAY "交易前餘額: "
                   WS-RING-PREV(WS-RING-IDX)
               DISPLAY "交易後餘額: "
                   WS-RING-NEW(WS-RING-IDX)
               DISPLAY "描述: "
                   WS-RING-DESC(WS-RING-IDX)
               DISPLAY "-------------------------"
           END-PERFORM.
       
       900-CLEANUP.
           *> 關閉可能打開的檔案
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