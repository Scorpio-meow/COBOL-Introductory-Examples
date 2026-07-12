       Identification Division.
       Program-Id. BANK.
       Author. Scorpio-meow.
       Date-Written. 2025-03-07.
       
       Environment Division.
       Configuration Section.
       Source-Computer. PC.
       Object-Computer. PC.
       
       Input-Output Section.
       File-Control.
           Select CUSTOMER-FILE Assign To "CUSTOMER.SAM"
               Organization Is Line Sequential
               File Status Is CUST-FILE-STATUS.

           Select ACCOUNT-FILE Assign To "ACCOUNT.SAM"
               Organization Is Line Sequential
               File Status Is ACC-FILE-STATUS.
               
           Select TRANS-FILE Assign To "TRANS.SAM"
               Organization Is Line Sequential
               File Status Is TRANS-FILE-STATUS.
       
       Data Division.
       File Section.
       FD  CUSTOMER-FILE.
       01  CUSTOMER-RECORD.
           05  CUST-ID             PIC X(6).
           05  CUST-ID-NUMBER      PIC X(10).
           05  CUST-NAME           PIC X(30).
           05  CUST-ADDRESS        PIC X(50).
           05  CUST-PHONE          PIC X(15).
           
       FD  ACCOUNT-FILE.
       01  ACCOUNT-RECORD.
           05  ACC-NUMBER          PIC X(10).
           05  ACC-CUST-ID         PIC X(6).
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

       
           
       Working-Storage Section.
       
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
           
       01  CUSTOMER-VARIABLES.
           05  WS-NEW-CUST-ID      PIC X(6).
           05  WS-NEXT-CUST-ID     PIC 9(6).
           05  WS-NEW-ACC-NUMBER   PIC X(10).
           05  WS-NEXT-ACC-NUMBER  PIC 9(10).
           05  WS-CUSTOMER-EXISTS  PIC X VALUE "N".
               88  CUSTOMER-EXISTS VALUE "Y".

       *> 身份證字號驗證變數
       01  ID-VALIDATE-VARS.
           05  WS-ID-CODE.
               10  WS-ID-C1        PIC X.
               10  WS-ID-C2        PIC 9.
               10  WS-ID-C3        PIC 9.
               10  WS-ID-C4        PIC 9.
               10  WS-ID-C5        PIC 9.
               10  WS-ID-C6        PIC 9.
               10  WS-ID-C7        PIC 9.
               10  WS-ID-C8        PIC 9.
               10  WS-ID-C9        PIC 9.
               10  WS-ID-C10       PIC 9.
           05  WS-ID-NO.
               10  WS-ID-N1        PIC 9.
               10  WS-ID-N2        PIC 9.
               10  WS-ID-NX.
                   15  WS-ID-N3    PIC 9.
                   15  WS-ID-N4    PIC 9.
                   15  WS-ID-N5    PIC 9.
                   15  WS-ID-N6    PIC 9.
                   15  WS-ID-N7    PIC 9.
                   15  WS-ID-N8    PIC 9.
                   15  WS-ID-N9    PIC 9.
                   15  WS-ID-N10   PIC 9.
           05  WS-ID-SUM           PIC 9(5).
           05  WS-ID-RESULT        PIC 9(5).
           05  WS-ID-RESULT2       PIC 9.
           05  WS-ID-CHECK         PIC 9.
           05  WS-ID-VALID         PIC X VALUE "N".
               88  ID-VALID        VALUE "Y".

        01  ACCOUNT-TABLE.
            05  ACC-ENTRY           OCCURS 100 TIMES.
                10  AE-NUMBER       PIC X(10).
                10  AE-CUST-ID      PIC X(6).
                10  AE-TYPE         PIC X(1).
                10  AE-BALANCE      PIC 9(10).
                10  AE-OPEN-DATE    PIC X(8).
                10  AE-STATUS       PIC X(1).
        01  WS-ACC-COUNT            PIC 9(3) VALUE ZERO.
        01  WS-ACC-IDX              PIC 9(3) VALUE ZERO.
       
       Procedure Division.
       perform 200-PROCESS-MENU.
       perform 900-CLEANUP.
       stop run.

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
           DISPLAY "==============================="
           DISPLAY "        新增客戶資料           "
           DISPLAY "==============================="
           
           *> 初始化變數
           INITIALIZE CUSTOMER-RECORD
           MOVE SPACES TO WS-ERROR-MESSAGE
           
           *> 檢查客戶檔案是否存在，若不存在則建立
           OPEN INPUT CUSTOMER-FILE
           IF NOT CUST-SUCCESS
               *> 如果檔案不存在，則創建一個
               CLOSE CUSTOMER-FILE
               OPEN OUTPUT CUSTOMER-FILE
               IF NOT CUST-SUCCESS
                   STRING "無法建立客戶檔案，狀態碼: " CUST-FILE-STATUS
                       DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                   DISPLAY WS-ERROR-MESSAGE
                   EXIT PARAGRAPH
               END-IF
               CLOSE CUSTOMER-FILE
           ELSE
               CLOSE CUSTOMER-FILE
           END-IF
       
           *> 生成客戶ID (從現有客戶數量+1)
           MOVE ZERO TO WS-NEXT-CUST-ID
           OPEN INPUT CUSTOMER-FILE
           IF CUST-SUCCESS
               PERFORM UNTIL 1 = 0
                   READ CUSTOMER-FILE
                       AT END
                           EXIT PERFORM
                       NOT AT END
                           ADD 1 TO WS-NEXT-CUST-ID
                   END-READ
               END-PERFORM
               CLOSE CUSTOMER-FILE
           ELSE
               STRING "無法讀取客戶檔案，狀態碼: " CUST-FILE-STATUS
                   DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
               DISPLAY WS-ERROR-MESSAGE
               EXIT PARAGRAPH
           END-IF
           
           ADD 1 TO WS-NEXT-CUST-ID
           MOVE WS-NEXT-CUST-ID TO WS-NEW-CUST-ID
           
           *> 接收客戶資料
           DISPLAY " "
           DISPLAY "新客戶ID: " WS-NEW-CUST-ID
           
           *> 身份證號碼驗證
           PERFORM UNTIL 1 = 0
               DISPLAY "請輸入身份證字號 (格式：英文字母+9位數字): " WITH NO ADVANCING
               ACCEPT CUST-ID-NUMBER
               MOVE CUST-ID-NUMBER TO WS-ID-CODE
               PERFORM 950-VALIDATE-ID
               IF ID-VALID
                   EXIT PERFORM
               ELSE
                   DISPLAY "錯誤：身份證字號格式不正確，請重新輸入"
               END-IF
           END-PERFORM
           
           *> 客戶姓名驗證
           PERFORM UNTIL 1 = 0
               DISPLAY "請輸入客戶姓名: " WITH NO ADVANCING
               ACCEPT CUST-NAME
               
               IF FUNCTION LENGTH(FUNCTION TRIM(CUST-NAME)) > 0
                   EXIT PERFORM
               ELSE
                   DISPLAY "錯誤：客戶姓名不得為空"
               END-IF
           END-PERFORM
           
           DISPLAY "請輸入客戶地址: " WITH NO ADVANCING
           ACCEPT CUST-ADDRESS
           
           DISPLAY "請輸入聯絡電話: " WITH NO ADVANCING
           ACCEPT CUST-PHONE
           
           *> 確認資料
           DISPLAY " "
           DISPLAY "請確認客戶資料："
           DISPLAY "--------------------------------"
           DISPLAY "客戶ID: " WS-NEW-CUST-ID
           DISPLAY "身份證號碼: " CUST-ID-NUMBER
           DISPLAY "客戶姓名: " CUST-NAME
           DISPLAY "客戶地址: " CUST-ADDRESS
           DISPLAY "聯絡電話: " CUST-PHONE
           DISPLAY "--------------------------------"
           DISPLAY "確認儲存資料？(Y/N): " WITH NO ADVANCING
           ACCEPT CONTINUE-CHOICE
           
           IF FUNCTION UPPER-CASE(CONTINUE-CHOICE) = "Y"
               *> 寫入客戶資料
               MOVE WS-NEW-CUST-ID TO CUST-ID
               
               *> 嘗試開啟檔案以新增資料
               OPEN EXTEND CUSTOMER-FILE
               IF NOT CUST-SUCCESS
                   *> 如果無法EXTEND，則嘗試OUTPUT模式開啟
                   OPEN OUTPUT CUSTOMER-FILE
                   IF NOT CUST-SUCCESS
                       STRING "無法開啟客戶檔案，狀態碼: " CUST-FILE-STATUS
                           DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                       DISPLAY WS-ERROR-MESSAGE
                       EXIT PARAGRAPH
                   END-IF
               END-IF
               
               WRITE CUSTOMER-RECORD
               IF CUST-SUCCESS
                   DISPLAY " "
                   DISPLAY "客戶資料已成功建立！"
                   DISPLAY "客戶ID: " CUST-ID
                   DISPLAY "請記錄此客戶ID以便開立帳戶使用"
               ELSE
                   STRING "錯誤：無法寫入客戶資料，狀態碼: " CUST-FILE-STATUS
                       DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                   DISPLAY WS-ERROR-MESSAGE
               END-IF
               
               CLOSE CUSTOMER-FILE
           ELSE
               DISPLAY "已取消新增客戶資料"
           END-IF
           .
           
       400-OPEN-ACCOUNT.
           DISPLAY " "
           DISPLAY "==============================="
           DISPLAY "           開立新帳戶          "
           DISPLAY "==============================="
           
           *> 初始化變數
           INITIALIZE ACCOUNT-RECORD
           MOVE SPACES TO WS-ERROR-MESSAGE
           
           *> 接收客戶資料
           DISPLAY "請輸入客戶ID: " WITH NO ADVANCING
           ACCEPT WS-NEW-CUST-ID
           
           *> 檢查客戶ID是否為空
           IF FUNCTION LENGTH(FUNCTION TRIM(WS-NEW-CUST-ID)) = 0
               DISPLAY "錯誤：客戶ID不可為空"
               EXIT PARAGRAPH
           END-IF
           
           *> 檢查客戶是否存在
           MOVE "N" TO WS-CUSTOMER-EXISTS
           OPEN INPUT CUSTOMER-FILE
           IF NOT CUST-SUCCESS
               STRING "錯誤：無法開啟客戶檔案，狀態碼: " CUST-FILE-STATUS
                   DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
               DISPLAY WS-ERROR-MESSAGE
               EXIT PARAGRAPH
           END-IF
           
           *> 查詢客戶資訊
           PERFORM UNTIL 1 = 0
               READ CUSTOMER-FILE
                   AT END
                       EXIT PERFORM
                   NOT AT END
                       IF CUST-ID = WS-NEW-CUST-ID
                           MOVE "Y" TO WS-CUSTOMER-EXISTS
                           DISPLAY "找到客戶：" CUST-NAME 
                           EXIT PERFORM
                       END-IF
               END-READ
           END-PERFORM
           
           CLOSE CUSTOMER-FILE
           
           *> 如果客戶不存在，顯示錯誤訊息並退出
           IF NOT CUSTOMER-EXISTS
               DISPLAY "錯誤：客戶ID " WS-NEW-CUST-ID " 不存在"
               DISPLAY "請先建立客戶資料"
               EXIT PARAGRAPH
           END-IF
           
           *> 檢查帳戶檔案是否存在，若不存在則建立
           OPEN INPUT ACCOUNT-FILE
           IF NOT ACC-SUCCESS
               *> 如果檔案不存在，則創建一個
               CLOSE ACCOUNT-FILE
               OPEN OUTPUT ACCOUNT-FILE
               IF NOT ACC-SUCCESS
                   STRING "無法建立帳戶檔案，狀態碼: " ACC-FILE-STATUS
                       DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                   DISPLAY WS-ERROR-MESSAGE
                   EXIT PARAGRAPH
               END-IF
               CLOSE ACCOUNT-FILE
           ELSE
               CLOSE ACCOUNT-FILE
           END-IF
           
           *> 生成新帳號 (從現有帳戶數量+1)
           MOVE ZERO TO WS-NEXT-ACC-NUMBER
           OPEN INPUT ACCOUNT-FILE
           IF ACC-SUCCESS
               PERFORM UNTIL 1 = 0
                   READ ACCOUNT-FILE
                       AT END
                           EXIT PERFORM
                       NOT AT END
                           ADD 1 TO WS-NEXT-ACC-NUMBER
                   END-READ
               END-PERFORM
               CLOSE ACCOUNT-FILE
           ELSE
               STRING "無法讀取帳戶檔案，狀態碼: " ACC-FILE-STATUS
                   DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
               DISPLAY WS-ERROR-MESSAGE
               EXIT PARAGRAPH
           END-IF
           
           ADD 1 TO WS-NEXT-ACC-NUMBER
           MOVE WS-NEXT-ACC-NUMBER TO WS-NEW-ACC-NUMBER
           
           DISPLAY " "
           DISPLAY "新帳號: " WS-NEW-ACC-NUMBER
           
           *> 選擇帳戶類型
           PERFORM UNTIL MENU-CHOICE = 1 OR MENU-CHOICE = 2
               DISPLAY " "
               DISPLAY "請選擇帳戶類型:"
               DISPLAY "1. 儲蓄帳戶 (S)"
               DISPLAY "2. 支票帳戶 (C)"
               DISPLAY "請選擇 (1/2): " WITH NO ADVANCING
               ACCEPT MENU-CHOICE
               
               IF MENU-CHOICE NOT = 1 AND MENU-CHOICE NOT = 2
                   DISPLAY "錯誤：請選擇有效的帳戶類型 (1或2)"
               END-IF
           END-PERFORM
           
           EVALUATE MENU-CHOICE
               WHEN 1
                   MOVE "S" TO ACC-TYPE
                   DISPLAY "已選擇：儲蓄帳戶"
               WHEN 2
                   MOVE "C" TO ACC-TYPE
                   DISPLAY "已選擇：支票帳戶"
           END-EVALUATE
           
           *> 設定初始存款金額
           PERFORM UNTIL 1 = 0
               DISPLAY "請輸入初始存款金額: " WITH NO ADVANCING
               ACCEPT ACC-BALANCE
               
               IF ACC-BALANCE <= 0
                   DISPLAY "錯誤：初始存款金額必須大於零"
               ELSE
                   EXIT PERFORM
               END-IF
           END-PERFORM
           
           *> 獲取當前日期作為開戶日期 (格式YYYYMMDD)
           MOVE FUNCTION CURRENT-DATE(1:8) TO ACC-OPEN-DATE
           
           *> 設定帳戶狀態為活動狀態
           MOVE "A" TO ACC-STATUS
           
           *> 完善帳戶記錄
           MOVE WS-NEW-ACC-NUMBER TO ACC-NUMBER
           MOVE WS-NEW-CUST-ID TO ACC-CUST-ID
           
           *> 確認資料
           DISPLAY " "
           DISPLAY "請確認帳戶資料："
           DISPLAY "--------------------------------"
           DISPLAY "帳戶號碼: " ACC-NUMBER
           DISPLAY "客戶ID: " ACC-CUST-ID
           DISPLAY "帳戶類型: " 
               IF ACC-TYPE = "S"
                   DISPLAY "儲蓄帳戶"
               ELSE
                   DISPLAY "支票帳戶"
               END-IF
           DISPLAY "初始存款: " ACC-BALANCE
           DISPLAY "開戶日期: " ACC-OPEN-DATE
           DISPLAY "帳戶狀態: 活動中"
           DISPLAY "--------------------------------"
           DISPLAY "確認開立帳戶？(Y/N): " WITH NO ADVANCING
           ACCEPT CONTINUE-CHOICE
           
           IF FUNCTION UPPER-CASE(CONTINUE-CHOICE) = "Y"
               *> 寫入帳戶資料
               OPEN EXTEND ACCOUNT-FILE
               IF NOT ACC-SUCCESS
                   *> 如果無法EXTEND，則嘗試OUTPUT模式開啟
                   OPEN OUTPUT ACCOUNT-FILE
                   IF NOT ACC-SUCCESS
                       STRING "無法開啟帳戶檔案，狀態碼: " ACC-FILE-STATUS
                           DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                       DISPLAY WS-ERROR-MESSAGE
                       EXIT PARAGRAPH
                   END-IF
               END-IF
               
               WRITE ACCOUNT-RECORD
               IF ACC-SUCCESS
                   DISPLAY " "
                   DISPLAY "帳戶已成功建立！"
                   DISPLAY "帳戶號碼: " ACC-NUMBER
                   DISPLAY "請記錄此帳號以便進行交易"
                   
                   *> 檢查交易檔案是否存在，若不存在則建立
                   OPEN INPUT TRANS-FILE
                   IF NOT TRANS-SUCCESS
                       CLOSE TRANS-FILE
                       OPEN OUTPUT TRANS-FILE
                       CLOSE TRANS-FILE
                   ELSE
                       CLOSE TRANS-FILE
                   END-IF
                   
                   *> 建立開戶交易記錄
                   MOVE ZERO TO WS-TRANS-ID-NUM
                   OPEN INPUT TRANS-FILE
                   IF TRANS-SUCCESS
                       PERFORM UNTIL 1 = 0
                           READ TRANS-FILE
                               AT END
                                   EXIT PERFORM
                               NOT AT END
                                   ADD 1 TO WS-TRANS-ID-NUM
                           END-READ
                       END-PERFORM
                       CLOSE TRANS-FILE
                   ELSE
                       STRING "無法讀取交易檔案，狀態碼: " TRANS-FILE-STATUS
                           DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                       DISPLAY WS-ERROR-MESSAGE
                   END-IF
                   
                   ADD 1 TO WS-TRANS-ID-NUM
                   MOVE WS-TRANS-ID-NUM TO TRANS-ID
                   MOVE ACC-NUMBER TO TRANS-ACC-NUMBER
                   MOVE ACC-OPEN-DATE TO TRANS-DATE
                   MOVE FUNCTION CURRENT-DATE(9:6) TO TRANS-TIME
                   MOVE "D" TO TRANS-TYPE
                   MOVE ACC-BALANCE TO TRANS-AMOUNT
                   MOVE ZERO TO TRANS-PREV-BAL
                   MOVE ACC-BALANCE TO TRANS-NEW-BAL
                   MOVE "開戶初始存款" TO TRANS-DESCRIPTION
                   
                   OPEN EXTEND TRANS-FILE
                   IF TRANS-SUCCESS
                       WRITE TRANS-RECORD
                       IF NOT TRANS-SUCCESS
                           DISPLAY "警告：無法記錄開戶交易，狀態碼: " TRANS-FILE-STATUS
                       END-IF
                   ELSE
                       OPEN OUTPUT TRANS-FILE
                       IF TRANS-SUCCESS
                           WRITE TRANS-RECORD
                           IF NOT TRANS-SUCCESS
                               DISPLAY "警告：無法記錄開戶交易，狀態碼: " TRANS-FILE-STATUS
                           END-IF
                       ELSE
                           DISPLAY "警告：無法開啟交易檔案，狀態碼: " TRANS-FILE-STATUS
                       END-IF
                   END-IF
                   CLOSE TRANS-FILE
               ELSE
                   STRING "錯誤：無法寫入帳戶資料，狀態碼: " ACC-FILE-STATUS
                       DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                   DISPLAY WS-ERROR-MESSAGE
               END-IF
               
               CLOSE ACCOUNT-FILE
           ELSE
               DISPLAY "已取消開立帳戶"
           END-IF
           .
           
       500-DEPOSIT.
           DISPLAY " "
           DISPLAY "==============================="
           DISPLAY "             存款              "
           DISPLAY "==============================="
           
           *> 初始化變數
           INITIALIZE TRANS-RECORD
           MOVE SPACES TO WS-ERROR-MESSAGE
           MOVE ZERO TO WS-TRANSACTION-AMT
           MOVE ZERO TO WS-NEW-BALANCE
           
           *> 接收帳戶號碼
           DISPLAY "請輸入帳戶號碼: " WITH NO ADVANCING
           ACCEPT WS-ACCOUNT-NUMBER
           
           *> 檢查帳戶號碼是否為空
           IF FUNCTION LENGTH(FUNCTION TRIM(WS-ACCOUNT-NUMBER)) = 0
               DISPLAY "錯誤：帳戶號碼不可為空"
               EXIT PARAGRAPH
           END-IF
           
           *> 檢查帳戶是否存在
           MOVE "N" TO WS-CUSTOMER-EXISTS  *> 重用此變數作為「帳戶存在」標誌
           
           *> 開啟帳戶檔案
           OPEN INPUT ACCOUNT-FILE
           IF NOT ACC-SUCCESS
               STRING "錯誤：無法開啟帳戶檔案，狀態碼: " ACC-FILE-STATUS
                   DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
               DISPLAY WS-ERROR-MESSAGE
               EXIT PARAGRAPH
           END-IF
           
           *> 查詢帳戶
           PERFORM UNTIL 1 = 0
               READ ACCOUNT-FILE
                   AT END
                       EXIT PERFORM
                   NOT AT END
                       IF FUNCTION TRIM(ACC-NUMBER) = FUNCTION 
                                   TRIM(WS-ACCOUNT-NUMBER)
                           MOVE "Y" TO WS-CUSTOMER-EXISTS
                           MOVE ACCOUNT-RECORD TO ACCOUNT-RECORD
                           
                           *> 檢查帳戶狀態
                           IF ACC-STATUS = "C"
                               DISPLAY "錯誤：此帳戶已關閉，無法進行存款操作"
                               MOVE "N" TO WS-CUSTOMER-EXISTS
                           END-IF
                           IF ACC-STATUS = "S"
                               DISPLAY "錯誤：此帳戶已凍結，無法進行存款操作"
                               MOVE "N" TO WS-CUSTOMER-EXISTS
                           END-IF
                           EXIT PERFORM
                       END-IF
               END-READ
           END-PERFORM
           
           CLOSE ACCOUNT-FILE
           
           *> 如果帳戶存在且狀態正常，執行存款操作
           IF WS-CUSTOMER-EXISTS = "Y"
               DISPLAY " "
               DISPLAY "帳戶資訊："
               DISPLAY "--------------------------------"
               DISPLAY "帳戶號碼: " ACC-NUMBER
               DISPLAY "帳戶類型: " 
                   IF ACC-TYPE = "S"
                       DISPLAY "儲蓄帳戶"
                   ELSE
                       DISPLAY "支票帳戶"
                   END-IF
               DISPLAY "目前餘額: " ACC-BALANCE
               DISPLAY "--------------------------------"
               
               *> 輸入並驗證存款金額
               PERFORM UNTIL 1 = 0
                   DISPLAY "請輸入存款金額: " WITH NO ADVANCING
                   ACCEPT WS-TRANSACTION-AMT
                   
                   IF WS-TRANSACTION-AMT <= 0
                       DISPLAY "錯誤：存款金額必須大於零"
                   ELSE
                       EXIT PERFORM
                   END-IF
               END-PERFORM
               
               *> 確認操作
               DISPLAY " "
               DISPLAY "您將存入: " WS-TRANSACTION-AMT " 元至帳戶 " ACC-NUMBER
               DISPLAY "確認存款？(Y/N): " WITH NO ADVANCING
               ACCEPT CONTINUE-CHOICE
               
                IF FUNCTION UPPER-CASE(CONTINUE-CHOICE) = "Y"
                    *> 步驟1：讀取所有帳戶記錄到暫存陣列
                    MOVE ZERO TO WS-ACC-COUNT
                    MOVE ZERO TO WS-ACC-IDX
                    OPEN INPUT ACCOUNT-FILE
                    IF NOT ACC-SUCCESS
                        STRING "錯誤：無法開啟帳戶檔案，狀態碼: " ACC-FILE-STATUS
                            DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                        DISPLAY WS-ERROR-MESSAGE
                        EXIT PARAGRAPH
                    END-IF
                    PERFORM UNTIL 1 = 0
                        READ ACCOUNT-FILE
                            AT END
                                EXIT PERFORM
                            NOT AT END
                                ADD 1 TO WS-ACC-COUNT
                                MOVE ACC-NUMBER    TO AE-NUMBER(WS-ACC-COUNT)
                                MOVE ACC-CUST-ID   TO AE-CUST-ID(WS-ACC-COUNT)
                                MOVE ACC-TYPE      TO AE-TYPE(WS-ACC-COUNT)
                                MOVE ACC-BALANCE   TO AE-BALANCE(WS-ACC-COUNT)
                                MOVE ACC-OPEN-DATE TO AE-OPEN-DATE(WS-ACC-COUNT)
                                MOVE ACC-STATUS    TO AE-STATUS(WS-ACC-COUNT)
                        END-READ
                    END-PERFORM
                    CLOSE ACCOUNT-FILE

                    *> 步驟2：在陣列中修改目標帳戶餘額
                    MOVE ZERO TO WS-ACC-IDX
                    PERFORM VARYING WS-ACC-IDX FROM 1 BY 1
                        UNTIL WS-ACC-IDX > WS-ACC-COUNT
                        IF FUNCTION TRIM(AE-NUMBER(WS-ACC-IDX)) =
                           FUNCTION TRIM(WS-ACCOUNT-NUMBER)
                            MOVE AE-BALANCE(WS-ACC-IDX) TO TRANS-PREV-BAL
                            COMPUTE AE-BALANCE(WS-ACC-IDX) =
                                AE-BALANCE(WS-ACC-IDX) + WS-TRANSACTION-AMT
                            MOVE AE-BALANCE(WS-ACC-IDX) TO WS-NEW-BALANCE
                            MOVE AE-BALANCE(WS-ACC-IDX) TO TRANS-NEW-BAL
                            EXIT PERFORM
                        END-IF
                    END-PERFORM

                    *> 步驟3：OUTPUT 重寫整個帳戶檔案
                    OPEN OUTPUT ACCOUNT-FILE
                    IF NOT ACC-SUCCESS
                        STRING "錯誤：無法重新開啟帳戶檔案，狀態碼: " ACC-FILE-STATUS
                            DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                        DISPLAY WS-ERROR-MESSAGE
                        EXIT PARAGRAPH
                    END-IF
                    PERFORM VARYING WS-ACC-IDX FROM 1 BY 1
                        UNTIL WS-ACC-IDX > WS-ACC-COUNT
                        MOVE AE-NUMBER(WS-ACC-IDX)    TO ACC-NUMBER
                        MOVE AE-CUST-ID(WS-ACC-IDX)   TO ACC-CUST-ID
                        MOVE AE-TYPE(WS-ACC-IDX)       TO ACC-TYPE
                        MOVE AE-BALANCE(WS-ACC-IDX)    TO ACC-BALANCE
                        MOVE AE-OPEN-DATE(WS-ACC-IDX)  TO ACC-OPEN-DATE
                        MOVE AE-STATUS(WS-ACC-IDX)     TO ACC-STATUS
                        WRITE ACCOUNT-RECORD
                        IF NOT ACC-SUCCESS
                            STRING "錯誤：寫入帳戶記錄失敗，狀態碼: " ACC-FILE-STATUS
                                DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                            DISPLAY WS-ERROR-MESSAGE
                        END-IF
                    END-PERFORM
                    CLOSE ACCOUNT-FILE

                    *> 步驟4：建立交易記錄
                    IF WS-NEW-BALANCE >= 0 AND WS-ACC-COUNT > 0
                        MOVE ZERO TO WS-TRANS-ID-NUM
                        OPEN INPUT TRANS-FILE
                        IF TRANS-SUCCESS
                            PERFORM UNTIL 1 = 0
                                READ TRANS-FILE
                                    AT END
                                        EXIT PERFORM
                                    NOT AT END
                                        ADD 1 TO WS-TRANS-ID-NUM
                                END-READ
                            END-PERFORM
                            CLOSE TRANS-FILE
                        ELSE
                            CLOSE TRANS-FILE
                        END-IF

                        ADD 1 TO WS-TRANS-ID-NUM
                        MOVE WS-TRANS-ID-NUM            TO TRANS-ID
                        MOVE WS-ACCOUNT-NUMBER          TO TRANS-ACC-NUMBER
                        MOVE FUNCTION CURRENT-DATE(1:8) TO TRANS-DATE
                        MOVE FUNCTION CURRENT-DATE(9:6) TO TRANS-TIME
                        MOVE "D"                        TO TRANS-TYPE
                        MOVE WS-TRANSACTION-AMT         TO TRANS-AMOUNT
                        MOVE "存款"                     TO TRANS-DESCRIPTION

                        OPEN EXTEND TRANS-FILE
                        IF NOT TRANS-SUCCESS
                            OPEN OUTPUT TRANS-FILE
                        END-IF
                        IF TRANS-SUCCESS
                            WRITE TRANS-RECORD
                            IF NOT TRANS-SUCCESS
                                STRING "警告：無法記錄交易，狀態碼: " TRANS-FILE-STATUS
                                    DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                                DISPLAY WS-ERROR-MESSAGE
                            END-IF
                        ELSE
                            STRING "警告：無法開啟交易檔案，狀態碼: " TRANS-FILE-STATUS
                                DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                            DISPLAY WS-ERROR-MESSAGE
                        END-IF
                        CLOSE TRANS-FILE

                        DISPLAY " "
                        DISPLAY "存款交易成功!"
                        DISPLAY "--------------------------------"
                        DISPLAY "帳戶號碼: " WS-ACCOUNT-NUMBER
                        DISPLAY "存款金額: " WS-TRANSACTION-AMT
                        DISPLAY "原始餘額: " TRANS-PREV-BAL
                        DISPLAY "目前餘額: " WS-NEW-BALANCE
                        DISPLAY "交易時間: " TRANS-DATE " " TRANS-TIME
                        DISPLAY "交易ID:   " TRANS-ID
                        DISPLAY "--------------------------------"
                    ELSE
                        DISPLAY "錯誤：找不到目標帳戶，餘額未更新"
                    END-IF
                ELSE
                    DISPLAY "已取消存款操作"
                END-IF
            ELSE
                DISPLAY "錯誤：找不到指定的帳戶號碼或帳戶狀態異常"
            END-IF
            .
           
       600-WITHDRAW.
           DISPLAY " "
           DISPLAY "==============================="
           DISPLAY "             提款              "
           DISPLAY "==============================="
           
           *> 初始化變數
           INITIALIZE TRANS-RECORD
           MOVE SPACES TO WS-ERROR-MESSAGE
           MOVE ZERO TO WS-TRANSACTION-AMT
           MOVE ZERO TO WS-NEW-BALANCE
           
           *> 接收帳戶號碼
           DISPLAY "請輸入帳戶號碼: " WITH NO ADVANCING
           ACCEPT WS-ACCOUNT-NUMBER
           
           *> 檢查帳戶號碼是否為空
           IF FUNCTION LENGTH(FUNCTION TRIM(WS-ACCOUNT-NUMBER)) = 0
               DISPLAY "錯誤：帳戶號碼不可為空"
               EXIT PARAGRAPH
           END-IF
           
           *> 檢查帳戶是否存在
           MOVE "N" TO WS-CUSTOMER-EXISTS  *> 重用此變數作為「帳戶存在」標誌
           
           *> 開啟帳戶檔案
           OPEN INPUT ACCOUNT-FILE
           IF NOT ACC-SUCCESS
               STRING "錯誤：無法開啟帳戶檔案，狀態碼: " ACC-FILE-STATUS
                   DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
               DISPLAY WS-ERROR-MESSAGE
               EXIT PARAGRAPH
           END-IF
           
           *> 查詢帳戶
           PERFORM UNTIL 1 = 0
               READ ACCOUNT-FILE
                   AT END
                       EXIT PERFORM
                   NOT AT END
                       IF FUNCTION TRIM(ACC-NUMBER) = FUNCTION TRIM(WS-ACCOUNT-NUMBER)
                           MOVE "Y" TO WS-CUSTOMER-EXISTS
                           MOVE ACCOUNT-RECORD TO ACCOUNT-RECORD
                           
                           *> 檢查帳戶狀態
                           IF ACC-STATUS = "C"
                               DISPLAY "錯誤：此帳戶已關閉，無法進行提款操作"
                               MOVE "N" TO WS-CUSTOMER-EXISTS
                           END-IF
                           IF ACC-STATUS = "S"
                               DISPLAY "錯誤：此帳戶已凍結，無法進行提款操作"
                               MOVE "N" TO WS-CUSTOMER-EXISTS
                           END-IF
                           EXIT PERFORM
                       END-IF
               END-READ
           END-PERFORM
           
           CLOSE ACCOUNT-FILE
           
           *> 如果帳戶存在且狀態正常，執行提款操作
           IF WS-CUSTOMER-EXISTS = "Y"
               DISPLAY " "
               DISPLAY "帳戶資訊："
               DISPLAY "--------------------------------"
               DISPLAY "帳戶號碼: " ACC-NUMBER
               DISPLAY "帳戶類型: " 
                   IF ACC-TYPE = "S"
                       DISPLAY "儲蓄帳戶"
                   ELSE
                       DISPLAY "支票帳戶"
                   END-IF
               DISPLAY "目前餘額: " ACC-BALANCE
               DISPLAY "--------------------------------"
               
               *> 輸入並驗證提款金額
               PERFORM UNTIL 1 = 0
                   DISPLAY "請輸入提款金額: " WITH NO ADVANCING
                   ACCEPT WS-TRANSACTION-AMT
                   
                   IF WS-TRANSACTION-AMT <= 0
                       DISPLAY "錯誤：提款金額必須大於零"
                   ELSE
                       IF WS-TRANSACTION-AMT > ACC-BALANCE
                           DISPLAY "錯誤：餘額不足，可提款金額為 " ACC-BALANCE
                       ELSE
                           EXIT PERFORM
                       END-IF
                   END-IF
               END-PERFORM
               
               *> 確認操作
               DISPLAY " "
               DISPLAY "您將提取: " WS-TRANSACTION-AMT " 元從帳戶 " ACC-NUMBER
               DISPLAY "確認提款？(Y/N): " WITH NO ADVANCING
               ACCEPT CONTINUE-CHOICE
               
                IF FUNCTION UPPER-CASE(CONTINUE-CHOICE) = "Y"
                    *> 步驟1：讀取所有帳戶記錄到暫存陣列
                    MOVE ZERO TO WS-ACC-COUNT
                    MOVE ZERO TO WS-ACC-IDX
                    OPEN INPUT ACCOUNT-FILE
                    IF NOT ACC-SUCCESS
                        STRING "錯誤：無法開啟帳戶檔案，狀態碼: " ACC-FILE-STATUS
                            DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                        DISPLAY WS-ERROR-MESSAGE
                        EXIT PARAGRAPH
                    END-IF
                    PERFORM UNTIL 1 = 0
                        READ ACCOUNT-FILE
                            AT END
                                EXIT PERFORM
                            NOT AT END
                                ADD 1 TO WS-ACC-COUNT
                                MOVE ACC-NUMBER    TO AE-NUMBER(WS-ACC-COUNT)
                                MOVE ACC-CUST-ID   TO AE-CUST-ID(WS-ACC-COUNT)
                                MOVE ACC-TYPE      TO AE-TYPE(WS-ACC-COUNT)
                                MOVE ACC-BALANCE   TO AE-BALANCE(WS-ACC-COUNT)
                                MOVE ACC-OPEN-DATE TO AE-OPEN-DATE(WS-ACC-COUNT)
                                MOVE ACC-STATUS    TO AE-STATUS(WS-ACC-COUNT)
                        END-READ
                    END-PERFORM
                    CLOSE ACCOUNT-FILE

                    *> 步驟2：在陣列中找到目標帳戶並扣款（含餘額再次確認）
                    MOVE ZERO TO WS-ACC-IDX
                    PERFORM VARYING WS-ACC-IDX FROM 1 BY 1
                        UNTIL WS-ACC-IDX > WS-ACC-COUNT
                        IF FUNCTION TRIM(AE-NUMBER(WS-ACC-IDX)) =
                           FUNCTION TRIM(WS-ACCOUNT-NUMBER)
                            IF WS-TRANSACTION-AMT > AE-BALANCE(WS-ACC-IDX)
                                STRING "錯誤：餘額不足，目前餘額為 "
                                    AE-BALANCE(WS-ACC-IDX)
                                    DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                                DISPLAY WS-ERROR-MESSAGE
                                EXIT PARAGRAPH
                            END-IF
                            MOVE AE-BALANCE(WS-ACC-IDX) TO TRANS-PREV-BAL
                            COMPUTE AE-BALANCE(WS-ACC-IDX) =
                                AE-BALANCE(WS-ACC-IDX) - WS-TRANSACTION-AMT
                            MOVE AE-BALANCE(WS-ACC-IDX) TO WS-NEW-BALANCE
                            MOVE AE-BALANCE(WS-ACC-IDX) TO TRANS-NEW-BAL
                            EXIT PERFORM
                        END-IF
                    END-PERFORM

                    *> 步驟3：OUTPUT 重寫整個帳戶檔案
                    OPEN OUTPUT ACCOUNT-FILE
                    IF NOT ACC-SUCCESS
                        STRING "錯誤：無法重新開啟帳戶檔案，狀態碼: " ACC-FILE-STATUS
                            DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                        DISPLAY WS-ERROR-MESSAGE
                        EXIT PARAGRAPH
                    END-IF
                    PERFORM VARYING WS-ACC-IDX FROM 1 BY 1
                        UNTIL WS-ACC-IDX > WS-ACC-COUNT
                        MOVE AE-NUMBER(WS-ACC-IDX)    TO ACC-NUMBER
                        MOVE AE-CUST-ID(WS-ACC-IDX)   TO ACC-CUST-ID
                        MOVE AE-TYPE(WS-ACC-IDX)       TO ACC-TYPE
                        MOVE AE-BALANCE(WS-ACC-IDX)    TO ACC-BALANCE
                        MOVE AE-OPEN-DATE(WS-ACC-IDX)  TO ACC-OPEN-DATE
                        MOVE AE-STATUS(WS-ACC-IDX)     TO ACC-STATUS
                        WRITE ACCOUNT-RECORD
                        IF NOT ACC-SUCCESS
                            STRING "錯誤：寫入帳戶記錄失敗，狀態碼: " ACC-FILE-STATUS
                                DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                            DISPLAY WS-ERROR-MESSAGE
                        END-IF
                    END-PERFORM
                    CLOSE ACCOUNT-FILE

                    *> 步驟4：建立交易記錄
                    MOVE ZERO TO WS-TRANS-ID-NUM
                    OPEN INPUT TRANS-FILE
                    IF TRANS-SUCCESS
                        PERFORM UNTIL 1 = 0
                            READ TRANS-FILE
                                AT END
                                    EXIT PERFORM
                                NOT AT END
                                    ADD 1 TO WS-TRANS-ID-NUM
                            END-READ
                        END-PERFORM
                        CLOSE TRANS-FILE
                    ELSE
                        CLOSE TRANS-FILE
                    END-IF

                    ADD 1 TO WS-TRANS-ID-NUM
                    MOVE WS-TRANS-ID-NUM            TO TRANS-ID
                    MOVE WS-ACCOUNT-NUMBER          TO TRANS-ACC-NUMBER
                    MOVE FUNCTION CURRENT-DATE(1:8) TO TRANS-DATE
                    MOVE FUNCTION CURRENT-DATE(9:6) TO TRANS-TIME
                    MOVE "W"                        TO TRANS-TYPE
                    MOVE WS-TRANSACTION-AMT         TO TRANS-AMOUNT
                    MOVE "提款"                     TO TRANS-DESCRIPTION

                    OPEN EXTEND TRANS-FILE
                    IF NOT TRANS-SUCCESS
                        OPEN OUTPUT TRANS-FILE
                    END-IF
                    IF TRANS-SUCCESS
                        WRITE TRANS-RECORD
                        IF NOT TRANS-SUCCESS
                            STRING "警告：無法記錄交易，狀態碼: " TRANS-FILE-STATUS
                                DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                            DISPLAY WS-ERROR-MESSAGE
                        END-IF
                    ELSE
                        STRING "警告：無法開啟交易檔案，狀態碼: " TRANS-FILE-STATUS
                            DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                        DISPLAY WS-ERROR-MESSAGE
                    END-IF
                    CLOSE TRANS-FILE

                    DISPLAY " "
                    DISPLAY "提款交易成功!"
                    DISPLAY "--------------------------------"
                    DISPLAY "帳戶號碼: " WS-ACCOUNT-NUMBER
                    DISPLAY "提款金額: " WS-TRANSACTION-AMT
                    DISPLAY "原始餘額: " TRANS-PREV-BAL
                    DISPLAY "目前餘額: " WS-NEW-BALANCE
                    DISPLAY "交易時間: " TRANS-DATE " " TRANS-TIME
                    DISPLAY "交易ID:   " TRANS-ID
                    DISPLAY "--------------------------------"
                ELSE
                    DISPLAY "已取消提款操作"
                END-IF
            ELSE
                DISPLAY "錯誤：找不到指定的帳戶號碼或帳戶狀態異常"
            END-IF
            .
           
       700-TRANSFER.
           DISPLAY " "
           DISPLAY "==============================="
           DISPLAY "             轉帳              "
           DISPLAY "==============================="
           
           *> 初始化變數
           INITIALIZE TRANS-RECORD
           MOVE SPACES TO WS-ERROR-MESSAGE
           MOVE ZERO TO WS-TRANSACTION-AMT
           MOVE ZERO TO WS-NEW-BALANCE
           
           *> 接收來源帳戶號碼
           DISPLAY "請輸入轉出帳戶號碼: " WITH NO ADVANCING
           ACCEPT WS-ACCOUNT-NUMBER
           
           *> 檢查來源帳戶號碼是否為空
           IF FUNCTION LENGTH(FUNCTION TRIM(WS-ACCOUNT-NUMBER)) = 0
               DISPLAY "錯誤：轉出帳戶號碼不可為空"
               EXIT PARAGRAPH
           END-IF
           
           *> 檢查來源帳戶是否存在
           MOVE "N" TO WS-CUSTOMER-EXISTS  *> 重用此變數作為「帳戶存在」標誌
           
           *> 開啟帳戶檔案
           OPEN INPUT ACCOUNT-FILE
           IF NOT ACC-SUCCESS
               STRING "錯誤：無法開啟帳戶檔案，狀態碼: " ACC-FILE-STATUS
                   DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
               DISPLAY WS-ERROR-MESSAGE
               EXIT PARAGRAPH
           END-IF
           
           *> 查詢來源帳戶
           PERFORM UNTIL 1 = 0
               READ ACCOUNT-FILE
                   AT END
                       EXIT PERFORM
                   NOT AT END
                       IF FUNCTION TRIM(ACC-NUMBER) = FUNCTION TRIM(WS-ACCOUNT-NUMBER)
                           MOVE "Y" TO WS-CUSTOMER-EXISTS
                           MOVE ACCOUNT-RECORD TO ACCOUNT-RECORD
                           
                           *> 檢查帳戶狀態
                           IF ACC-STATUS = "C"
                               DISPLAY "錯誤：此帳戶已關閉，無法進行轉帳操作"
                               MOVE "N" TO WS-CUSTOMER-EXISTS
                           END-IF
                           IF ACC-STATUS = "S"
                               DISPLAY "錯誤：此帳戶已凍結，無法進行轉帳操作"
                               MOVE "N" TO WS-CUSTOMER-EXISTS
                           END-IF
                           EXIT PERFORM
                       END-IF
               END-READ
           END-PERFORM
           
           CLOSE ACCOUNT-FILE
           
           *> 如果來源帳戶存在且狀態正常
           IF WS-CUSTOMER-EXISTS = "Y"
               *> 顯示來源帳戶資訊
               DISPLAY " "
               DISPLAY "轉出帳戶資訊："
               DISPLAY "--------------------------------"
               DISPLAY "帳戶號碼: " ACC-NUMBER
               DISPLAY "帳戶類型: " 
                   IF ACC-TYPE = "S"
                       DISPLAY "儲蓄帳戶"
                   ELSE
                       DISPLAY "支票帳戶"
                   END-IF
               DISPLAY "目前餘額: " ACC-BALANCE
               DISPLAY "--------------------------------"
               
               *> 儲存來源帳戶資訊
               MOVE ACC-NUMBER TO WS-ACCOUNT-NUMBER
               MOVE ACC-BALANCE TO WS-NEW-BALANCE
               
               *> 接收轉入帳戶號碼
               DISPLAY "請輸入轉入帳戶號碼: " WITH NO ADVANCING
               ACCEPT WS-NEW-ACC-NUMBER
               
               *> 檢查轉入帳戶號碼是否為空
               IF FUNCTION LENGTH(FUNCTION TRIM(WS-NEW-ACC-NUMBER)) = 0
                   DISPLAY "錯誤：轉入帳戶號碼不可為空"
                   EXIT PARAGRAPH
               END-IF
               
               *> 檢查是否轉給自己
               IF FUNCTION TRIM(WS-ACCOUNT-NUMBER) = FUNCTION TRIM(WS-NEW-ACC-NUMBER)
                   DISPLAY "錯誤：不能轉帳給自己的帳戶"
                   EXIT PARAGRAPH
               END-IF
               
               *> 檢查轉入帳戶是否存在
               MOVE "N" TO WS-CUSTOMER-EXISTS
               OPEN INPUT ACCOUNT-FILE
               IF NOT ACC-SUCCESS
                   STRING "錯誤：無法開啟帳戶檔案，狀態碼: " ACC-FILE-STATUS
                       DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                   DISPLAY WS-ERROR-MESSAGE
                   EXIT PARAGRAPH
               END-IF
               
               *> 查詢轉入帳戶
               PERFORM UNTIL 1 = 0
                   READ ACCOUNT-FILE
                       AT END
                           EXIT PERFORM
                       NOT AT END
                           IF FUNCTION TRIM(ACC-NUMBER) = FUNCTION TRIM(WS-NEW-ACC-NUMBER)
                               MOVE "Y" TO WS-CUSTOMER-EXISTS
                               
                               *> 儲存轉入帳戶資訊
                               MOVE ACC-BALANCE TO WS-TRANSACTION-AMT  *> 暫存轉入帳戶餘額
                               
                               *> 檢查帳戶狀態
                               IF ACC-STATUS = "C"
                                   DISPLAY "錯誤：轉入帳戶已關閉，無法進行轉帳"
                                   MOVE "N" TO WS-CUSTOMER-EXISTS
                               END-IF
                               IF ACC-STATUS = "S"
                                   DISPLAY "錯誤：轉入帳戶已凍結，無法進行轉帳"
                                   MOVE "N" TO WS-CUSTOMER-EXISTS
                               END-IF
                               EXIT PERFORM
                           END-IF
                   END-READ
               END-PERFORM
               
               CLOSE ACCOUNT-FILE
               
               *> 如果轉入帳戶存在且狀態正常
               IF WS-CUSTOMER-EXISTS = "Y"
                   *> 輸入並驗證轉帳金額
                   PERFORM UNTIL 1 = 0
                       DISPLAY "請輸入轉帳金額: " WITH NO ADVANCING
                       ACCEPT WS-NEXT-ACC-NUMBER  *> 暫存轉帳金額
                       
                       IF WS-NEXT-ACC-NUMBER <= 0
                           DISPLAY "錯誤：轉帳金額必須大於零"
                       ELSE
                           IF WS-NEXT-ACC-NUMBER > WS-NEW-BALANCE
                               DISPLAY "錯誤：餘額不足，可轉出金額為 " WS-NEW-BALANCE
                           ELSE
                               EXIT PERFORM
                           END-IF
                       END-IF
                   END-PERFORM
                   
                   *> 確認操作
                   DISPLAY " "
                   DISPLAY "您將從帳戶 " WS-ACCOUNT-NUMBER " 轉出 " 
                       WS-NEXT-ACC-NUMBER " 元至帳戶 " WS-NEW-ACC-NUMBER
                   DISPLAY "確認轉帳？(Y/N): " WITH NO ADVANCING
                   ACCEPT CONTINUE-CHOICE
                   
                    IF FUNCTION UPPER-CASE(CONTINUE-CHOICE) = "Y"
                        *> 步驟1：讀取所有帳戶記錄到暫存陣列
                        MOVE ZERO TO WS-ACC-COUNT
                        MOVE ZERO TO WS-ACC-IDX
                        OPEN INPUT ACCOUNT-FILE
                        IF NOT ACC-SUCCESS
                            STRING "錯誤：無法開啟帳戶檔案，狀態碼: " ACC-FILE-STATUS
                                DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                            DISPLAY WS-ERROR-MESSAGE
                            EXIT PARAGRAPH
                        END-IF
                        PERFORM UNTIL 1 = 0
                            READ ACCOUNT-FILE
                                AT END
                                    EXIT PERFORM
                                NOT AT END
                                    ADD 1 TO WS-ACC-COUNT
                                    MOVE ACC-NUMBER    TO AE-NUMBER(WS-ACC-COUNT)
                                    MOVE ACC-CUST-ID   TO AE-CUST-ID(WS-ACC-COUNT)
                                    MOVE ACC-TYPE      TO AE-TYPE(WS-ACC-COUNT)
                                    MOVE ACC-BALANCE   TO AE-BALANCE(WS-ACC-COUNT)
                                    MOVE ACC-OPEN-DATE TO AE-OPEN-DATE(WS-ACC-COUNT)
                                    MOVE ACC-STATUS    TO AE-STATUS(WS-ACC-COUNT)
                            END-READ
                        END-PERFORM
                        CLOSE ACCOUNT-FILE

                        *> 步驟2：在陣列中修改來源帳戶（扣款）與目標帳戶（加款）
                        MOVE ZERO TO WS-ACC-IDX
                        PERFORM VARYING WS-ACC-IDX FROM 1 BY 1
                            UNTIL WS-ACC-IDX > WS-ACC-COUNT
                            IF FUNCTION TRIM(AE-NUMBER(WS-ACC-IDX)) =
                               FUNCTION TRIM(WS-ACCOUNT-NUMBER)
                                IF WS-NEXT-ACC-NUMBER > AE-BALANCE(WS-ACC-IDX)
                                    DISPLAY "錯誤：來源帳戶餘額不足，取消轉帳"
                                    EXIT PARAGRAPH
                                END-IF
                                MOVE AE-BALANCE(WS-ACC-IDX) TO TRANS-PREV-BAL
                                COMPUTE AE-BALANCE(WS-ACC-IDX) =
                                    AE-BALANCE(WS-ACC-IDX) - WS-NEXT-ACC-NUMBER
                                MOVE AE-BALANCE(WS-ACC-IDX) TO WS-NEW-BALANCE
                            END-IF
                            IF FUNCTION TRIM(AE-NUMBER(WS-ACC-IDX)) =
                               FUNCTION TRIM(WS-NEW-ACC-NUMBER)
                                MOVE AE-BALANCE(WS-ACC-IDX) TO WS-TRANSACTION-AMT
                                COMPUTE AE-BALANCE(WS-ACC-IDX) =
                                    AE-BALANCE(WS-ACC-IDX) + WS-NEXT-ACC-NUMBER
                            END-IF
                        END-PERFORM

                        *> 步驟3：OUTPUT 重寫整個帳戶檔案
                        OPEN OUTPUT ACCOUNT-FILE
                        IF NOT ACC-SUCCESS
                            STRING "錯誤：無法重新開啟帳戶檔案，狀態碼: " ACC-FILE-STATUS
                                DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                            DISPLAY WS-ERROR-MESSAGE
                            EXIT PARAGRAPH
                        END-IF
                        PERFORM VARYING WS-ACC-IDX FROM 1 BY 1
                            UNTIL WS-ACC-IDX > WS-ACC-COUNT
                            MOVE AE-NUMBER(WS-ACC-IDX)    TO ACC-NUMBER
                            MOVE AE-CUST-ID(WS-ACC-IDX)   TO ACC-CUST-ID
                            MOVE AE-TYPE(WS-ACC-IDX)       TO ACC-TYPE
                            MOVE AE-BALANCE(WS-ACC-IDX)    TO ACC-BALANCE
                            MOVE AE-OPEN-DATE(WS-ACC-IDX)  TO ACC-OPEN-DATE
                            MOVE AE-STATUS(WS-ACC-IDX)     TO ACC-STATUS
                            WRITE ACCOUNT-RECORD
                            IF NOT ACC-SUCCESS
                                STRING "錯誤：寫入帳戶記錄失敗，狀態碼: " ACC-FILE-STATUS
                                    DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                                DISPLAY WS-ERROR-MESSAGE
                            END-IF
                        END-PERFORM
                        CLOSE ACCOUNT-FILE

                        *> 步驟4：建立轉出交易記錄
                        MOVE ZERO TO WS-TRANS-ID-NUM
                        OPEN INPUT TRANS-FILE
                        IF TRANS-SUCCESS
                            PERFORM UNTIL 1 = 0
                                READ TRANS-FILE
                                    AT END
                                        EXIT PERFORM
                                    NOT AT END
                                        ADD 1 TO WS-TRANS-ID-NUM
                                END-READ
                            END-PERFORM
                            CLOSE TRANS-FILE
                        ELSE
                            CLOSE TRANS-FILE
                        END-IF

                        ADD 1 TO WS-TRANS-ID-NUM
                        MOVE WS-TRANS-ID-NUM            TO TRANS-ID
                        MOVE WS-ACCOUNT-NUMBER          TO TRANS-ACC-NUMBER
                        MOVE FUNCTION CURRENT-DATE(1:8) TO TRANS-DATE
                        MOVE FUNCTION CURRENT-DATE(9:6) TO TRANS-TIME
                        MOVE "T"                        TO TRANS-TYPE
                        MOVE WS-NEXT-ACC-NUMBER         TO TRANS-AMOUNT
                        MOVE TRANS-PREV-BAL             TO TRANS-PREV-BAL
                        MOVE WS-NEW-BALANCE             TO TRANS-NEW-BAL
                        STRING "轉帳至帳戶 " WS-NEW-ACC-NUMBER
                            DELIMITED BY SIZE INTO TRANS-DESCRIPTION

                        OPEN EXTEND TRANS-FILE
                        IF NOT TRANS-SUCCESS
                            OPEN OUTPUT TRANS-FILE
                        END-IF
                        IF TRANS-SUCCESS
                            WRITE TRANS-RECORD
                            IF NOT TRANS-SUCCESS
                                STRING "警告：無法記錄轉出交易，狀態碼: " TRANS-FILE-STATUS
                                    DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                                DISPLAY WS-ERROR-MESSAGE
                            END-IF
                        ELSE
                            STRING "警告：無法開啟交易檔案，狀態碼: " TRANS-FILE-STATUS
                                DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                            DISPLAY WS-ERROR-MESSAGE
                        END-IF
                        CLOSE TRANS-FILE

                        *> 步驟5：建立轉入交易記錄
                        INITIALIZE TRANS-RECORD
                        ADD 1 TO WS-TRANS-ID-NUM
                        MOVE WS-TRANS-ID-NUM            TO TRANS-ID
                        MOVE WS-NEW-ACC-NUMBER          TO TRANS-ACC-NUMBER
                        MOVE FUNCTION CURRENT-DATE(1:8) TO TRANS-DATE
                        MOVE FUNCTION CURRENT-DATE(9:6) TO TRANS-TIME
                        MOVE "D"                        TO TRANS-TYPE
                        MOVE WS-NEXT-ACC-NUMBER         TO TRANS-AMOUNT
                        MOVE WS-TRANSACTION-AMT         TO TRANS-PREV-BAL
                        COMPUTE TRANS-NEW-BAL = WS-TRANSACTION-AMT + WS-NEXT-ACC-NUMBER
                        STRING "來自帳戶 " WS-ACCOUNT-NUMBER
                            DELIMITED BY SIZE INTO TRANS-DESCRIPTION

                        OPEN EXTEND TRANS-FILE
                        IF NOT TRANS-SUCCESS
                            OPEN OUTPUT TRANS-FILE
                        END-IF
                        IF TRANS-SUCCESS
                            WRITE TRANS-RECORD
                            IF NOT TRANS-SUCCESS
                                STRING "警告：無法記錄轉入交易，狀態碼: " TRANS-FILE-STATUS
                                    DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                                DISPLAY WS-ERROR-MESSAGE
                            END-IF
                        ELSE
                            STRING "警告：無法開啟交易檔案，狀態碼: " TRANS-FILE-STATUS
                                DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                            DISPLAY WS-ERROR-MESSAGE
                        END-IF
                        CLOSE TRANS-FILE

                        DISPLAY " "
                        DISPLAY "轉帳交易成功!"
                        DISPLAY "--------------------------------"
                        DISPLAY "轉出帳戶: " WS-ACCOUNT-NUMBER
                        DISPLAY "轉入帳戶: " WS-NEW-ACC-NUMBER
                        DISPLAY "轉帳金額: " WS-NEXT-ACC-NUMBER
                        DISPLAY "轉出帳戶新餘額: " WS-NEW-BALANCE
                        DISPLAY "交易時間: " TRANS-DATE " " TRANS-TIME
                        DISPLAY "交易ID:   " TRANS-ID
                        DISPLAY "--------------------------------"
                    ELSE
                        DISPLAY "已取消轉帳操作"
                    END-IF
                ELSE
                    DISPLAY "錯誤：找不到指定的轉入帳戶或帳戶狀態異常"
                END-IF
            ELSE
                DISPLAY "錯誤：找不到指定的轉出帳戶或帳戶狀態異常"
            END-IF
            .
           
       800-CHECK-BALANCE.
           DISPLAY " "
           DISPLAY "==============================="
           DISPLAY "           餘額查詢            "
           DISPLAY "==============================="
           
           *> 初始化變數
           MOVE SPACES TO WS-ERROR-MESSAGE
           
           *> 接收帳戶號碼
           DISPLAY "請輸入帳戶號碼: " WITH NO ADVANCING
           ACCEPT WS-ACCOUNT-NUMBER
           
           *> 檢查帳戶號碼是否為空
           IF FUNCTION LENGTH(FUNCTION TRIM(WS-ACCOUNT-NUMBER)) = 0
               DISPLAY "錯誤：帳戶號碼不可為空"
               EXIT PARAGRAPH
           END-IF
           
           *> 檢查帳戶是否存在
           MOVE "N" TO WS-CUSTOMER-EXISTS  *> 重用此變數作為「帳戶存在」標誌
           
           *> 開啟帳戶檔案
           OPEN INPUT ACCOUNT-FILE
           IF NOT ACC-SUCCESS
               STRING "錯誤：無法開啟帳戶檔案，狀態碼: " ACC-FILE-STATUS
                   DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
               DISPLAY WS-ERROR-MESSAGE
               EXIT PARAGRAPH
           END-IF
           
           *> 查詢帳戶
           PERFORM UNTIL 1 = 0
               READ ACCOUNT-FILE
                   AT END
                       EXIT PERFORM
                   NOT AT END
                       IF FUNCTION TRIM(ACC-NUMBER) = FUNCTION TRIM(WS-ACCOUNT-NUMBER)
                           MOVE "Y" TO WS-CUSTOMER-EXISTS
                           
                           *> 找到帳戶，顯示詳細資訊
                           DISPLAY " "
                           DISPLAY "帳戶資訊:"
                           DISPLAY "--------------------------------"
                           DISPLAY "帳戶號碼: " ACC-NUMBER
                           DISPLAY "客戶ID: " ACC-CUST-ID
                           DISPLAY "帳戶類型: " 
                           IF ACC-TYPE = "S"
                               DISPLAY "儲蓄帳戶"
                           ELSE
                               DISPLAY "支票帳戶"
                           END-IF
                           DISPLAY "帳戶餘額: " ACC-BALANCE " 元"
                           DISPLAY "開戶日期: " 
                               ACC-OPEN-DATE(1:4) "年" 
                               ACC-OPEN-DATE(5:2) "月" 
                               ACC-OPEN-DATE(7:2) "日"
                           DISPLAY "帳戶狀態: " 
                           EVALUATE ACC-STATUS
                               WHEN "A"
                                   DISPLAY "活動中"
                               WHEN "C"
                                   DISPLAY "已關閉"
                               WHEN "S"
                                   DISPLAY "已凍結"
                               WHEN OTHER
                                   DISPLAY "未知"
                           END-EVALUATE
                           DISPLAY "--------------------------------"
                           
                           *> 儲存相關資訊供後續使用
                           MOVE ACC-CUST-ID TO WS-NEW-CUST-ID
                           
                           EXIT PERFORM
                       END-IF
               END-READ
           END-PERFORM
           
           CLOSE ACCOUNT-FILE
           
           IF WS-CUSTOMER-EXISTS = "Y"
               *> 查找客戶名稱
               OPEN INPUT CUSTOMER-FILE
               IF CUST-SUCCESS
                   PERFORM UNTIL 1 = 0
                       READ CUSTOMER-FILE
                           AT END
                               EXIT PERFORM
                           NOT AT END
                               IF CUST-ID = WS-NEW-CUST-ID
                                   DISPLAY "客戶姓名: " CUST-NAME
                                   EXIT PERFORM
                               END-IF
                       END-READ
                   END-PERFORM
                   CLOSE CUSTOMER-FILE
               END-IF
               
               *> 顯示交易記錄
               DISPLAY " "
               DISPLAY "近期交易記錄:"
               DISPLAY "--------------------------------"
               
               *> 先計算交易記錄總數
               MOVE 0 TO WS-TRANS-ID-NUM
               OPEN INPUT TRANS-FILE
               IF TRANS-SUCCESS
                   PERFORM UNTIL 1 = 0
                       READ TRANS-FILE
                           AT END
                               EXIT PERFORM
                           NOT AT END
                               IF FUNCTION TRIM(TRANS-ACC-NUMBER) = 
                                  FUNCTION TRIM(WS-ACCOUNT-NUMBER)
                                   ADD 1 TO WS-TRANS-ID-NUM
                               END-IF
                       END-READ
                   END-PERFORM
                   CLOSE TRANS-FILE
                   
                   IF WS-TRANS-ID-NUM = 0
                       DISPLAY "此帳戶無交易記錄"
                   ELSE
                       *> 顯示交易筆數
                       DISPLAY "交易記錄總數: " WS-TRANS-ID-NUM " 筆"
                       DISPLAY " "
                       
                       *> 顯示交易記錄表頭
                       DISPLAY "交易ID      日期      時間   類型   金額      前餘額    後餘額    交易描述"
                       DISPLAY "--------------------------------------------------------------------------------"
                       
                       *> 再次開啟檔案顯示交易記錄(顯示最近10筆)
                       MOVE 0 TO WS-NEW-BALANCE  *> 用於計數顯示筆數
                       OPEN INPUT TRANS-FILE
                       
                       *> 若要顯示最近的交易，需要讀取全部後從後往前顯示
                       *> 此處簡化，只讀取前10筆
                       PERFORM UNTIL 1 = 0 OR WS-NEW-BALANCE >= 10
                           READ TRANS-FILE
                               AT END
                                   EXIT PERFORM
                               NOT AT END
                                   IF FUNCTION TRIM(TRANS-ACC-NUMBER) = 
                                      FUNCTION TRIM(WS-ACCOUNT-NUMBER)
                                       ADD 1 TO WS-NEW-BALANCE
                                       
                                       *> 格式化顯示交易類型
                                       EVALUATE TRANS-TYPE
                                           WHEN "D"
                                               DISPLAY TRANS-ID "  " 
                                                      TRANS-DATE(1:4) "/" TRANS-DATE(5:2) "/" TRANS-DATE(7:2) "  " 
                                                      TRANS-TIME(1:2) ":" TRANS-TIME(3:2) "  "
                                                      "存款   "
                                                      TRANS-AMOUNT " "
                                                      TRANS-PREV-BAL " "
                                                      TRANS-NEW-BAL " "
                                                      TRANS-DESCRIPTION
                                           WHEN "W"
                                               DISPLAY TRANS-ID "  " 
                                                      TRANS-DATE(1:4) "/" TRANS-DATE(5:2) "/" TRANS-DATE(7:2) "  " 
                                                      TRANS-TIME(1:2) ":" TRANS-TIME(3:2) "  "
                                                      "提款   "
                                                      TRANS-AMOUNT " "
                                                      TRANS-PREV-BAL " "
                                                      TRANS-NEW-BAL " "
                                                      TRANS-DESCRIPTION
                                           WHEN "T"
                                               DISPLAY TRANS-ID "  " 
                                                      TRANS-DATE(1:4) "/" TRANS-DATE(5:2) "/" TRANS-DATE(7:2) "  " 
                                                      TRANS-TIME(1:2) ":" TRANS-TIME(3:2) "  "
                                                      "轉帳   "
                                                      TRANS-AMOUNT " "
                                                      TRANS-PREV-BAL " "
                                                      TRANS-NEW-BAL " "
                                                      TRANS-DESCRIPTION
                                           WHEN OTHER
                                               DISPLAY TRANS-ID "  " 
                                                      TRANS-DATE(1:4) "/" TRANS-DATE(5:2) "/" TRANS-DATE(7:2) "  " 
                                                      TRANS-TIME(1:2) ":" TRANS-TIME(3:2) "  "
                                                      "其他   "
                                                      TRANS-AMOUNT " "
                                                      TRANS-PREV-BAL " "
                                                      TRANS-NEW-BAL " "
                                                      TRANS-DESCRIPTION
                                       END-EVALUATE
                                   END-IF
                           END-READ
                       END-PERFORM
                       
                       CLOSE TRANS-FILE
                       
                       *> 顯示更多交易記錄選項
                       IF WS-TRANS-ID-NUM > 10
                           DISPLAY " "
                           DISPLAY "僅顯示最近10筆交易，總計有 " WS-TRANS-ID-NUM " 筆交易記錄"
                           DISPLAY "是否要查看更多交易記錄？(Y/N): " WITH NO ADVANCING
                           ACCEPT CONTINUE-CHOICE
                           
                           IF FUNCTION UPPER-CASE(CONTINUE-CHOICE) = "Y"
                               DISPLAY " "
                               DISPLAY "要查看多少筆交易記錄？(最多 " WS-TRANS-ID-NUM " 筆): " 
                                   WITH NO ADVANCING
                               ACCEPT WS-NEW-BALANCE
                               
                               IF WS-NEW-BALANCE > 0 AND WS-NEW-BALANCE <= WS-TRANS-ID-NUM
                                   *> 顯示交易記錄表頭
                                   DISPLAY " "
                                   DISPLAY "交易ID      日期      時間   類型   金額      前餘額    後餘額    交易描述"
                                   DISPLAY "--------------------------------------------------------------------------------"
                                   
                                   MOVE 0 TO WS-TRANSACTION-AMT  *> 用於計數顯示筆數
                                   OPEN INPUT TRANS-FILE
                                   
                                   PERFORM UNTIL 1 = 0 OR WS-TRANSACTION-AMT >= WS-NEW-BALANCE
                                       READ TRANS-FILE
                                           AT END
                                               EXIT PERFORM
                                           NOT AT END
                                               IF FUNCTION TRIM(TRANS-ACC-NUMBER) = 
                                                  FUNCTION TRIM(WS-ACCOUNT-NUMBER)
                                                   ADD 1 TO WS-TRANSACTION-AMT
                                                   
                                                   *> 格式化顯示交易類型
                                                   EVALUATE TRANS-TYPE
                                                       WHEN "D"
                                                           DISPLAY TRANS-ID "  " 
                                                                  TRANS-DATE(1:4) "/" TRANS-DATE(5:2) "/" TRANS-DATE(7:2) "  " 
                                                                  TRANS-TIME(1:2) ":" TRANS-TIME(3:2) "  "
                                                                  "存款   "
                                                                  TRANS-AMOUNT " "
                                                                  TRANS-PREV-BAL " "
                                                                  TRANS-NEW-BAL " "
                                                                  TRANS-DESCRIPTION
                                                       WHEN "W"
                                                           DISPLAY TRANS-ID "  " 
                                                                  TRANS-DATE(1:4) "/" TRANS-DATE(5:2) "/" TRANS-DATE(7:2) "  " 
                                                                  TRANS-TIME(1:2) ":" TRANS-TIME(3:2) "  "
                                                                  "提款   "
                                                                  TRANS-AMOUNT " "
                                                                  TRANS-PREV-BAL " "
                                                                  TRANS-NEW-BAL " "
                                                                  TRANS-DESCRIPTION
                                                       WHEN "T"
                                                           DISPLAY TRANS-ID "  " 
                                                                  TRANS-DATE(1:4) "/" TRANS-DATE(5:2) "/" TRANS-DATE(7:2) "  " 
                                                                  TRANS-TIME(1:2) ":" TRANS-TIME(3:2) "  "
                                                                  "轉帳   "
                                                                  TRANS-AMOUNT " "
                                                                  TRANS-PREV-BAL " "
                                                                  TRANS-NEW-BAL " "
                                                                  TRANS-DESCRIPTION
                                                       WHEN OTHER
                                                           DISPLAY TRANS-ID "  " 
                                                                  TRANS-DATE(1:4) "/" TRANS-DATE(5:2) "/" TRANS-DATE(7:2) "  " 
                                                                  TRANS-TIME(1:2) ":" TRANS-TIME(3:2) "  "
                                                                  "其他   "
                                                                  TRANS-AMOUNT " "
                                                                  TRANS-PREV-BAL " "
                                                                  TRANS-NEW-BAL " "
                                                                  TRANS-DESCRIPTION
                                                   END-EVALUATE
                                               END-IF
                                       END-READ
                                   END-PERFORM
                                   
                                   CLOSE TRANS-FILE
                               ELSE
                                   DISPLAY "輸入的筆數無效"
                               END-IF
                           END-IF
                       END-IF
                   END-IF
               ELSE
                   STRING "警告：無法開啟交易檔案，狀態碼: " TRANS-FILE-STATUS
                       DELIMITED BY SIZE INTO WS-ERROR-MESSAGE
                   DISPLAY WS-ERROR-MESSAGE
               END-IF
               
               *> 顯示操作選項
               DISPLAY " "
               DISPLAY "--------------------------------"
               DISPLAY "1. 執行存款"
               DISPLAY "2. 執行提款"
               DISPLAY "3. 執行轉帳"
               DISPLAY "4. 返回主菜單"
               DISPLAY "請選擇操作 (1-4): " WITH NO ADVANCING
               ACCEPT MENU-CHOICE
               
               EVALUATE MENU-CHOICE
                   WHEN 1
                       PERFORM 500-DEPOSIT
                   WHEN 2
                       PERFORM 600-WITHDRAW
                   WHEN 3
                       PERFORM 700-TRANSFER
                   WHEN 4
                       DISPLAY "返回主菜單"
                   WHEN OTHER
                       DISPLAY "無效的選擇，返回主菜單"
               END-EVALUATE
           ELSE
               DISPLAY "錯誤：找不到指定的帳戶號碼"
           END-IF
           .

       900-CLEANUP.
           *> 確保所有檔案已關閉
           DISPLAY " "
           DISPLAY "==============================="
           DISPLAY "        系統關閉中...          "
           DISPLAY "==============================="
           
           *> 顯示系統使用資訊
           DISPLAY "使用時間: " FUNCTION CURRENT-DATE
           
           *> 檢查並關閉客戶檔案
           PERFORM 910-CLOSE-CUSTOMER-FILE
           
           *> 檢查並關閉帳戶檔案
           PERFORM 920-CLOSE-ACCOUNT-FILE
           
           *> 檢查並關閉交易檔案
           PERFORM 930-CLOSE-TRANSACTION-FILE
           
           *> 執行系統資源備份提示
           DISPLAY " "
           DISPLAY "提示：建議定期備份以下檔案："
           DISPLAY "- CUSTOMER.SAM (客戶資料檔案)"
           DISPLAY "- ACCOUNT.SAM (帳戶資料檔案)"
           DISPLAY "- TRANS.SAM (交易記錄檔案)"
           
           *> 顯示退出訊息
           DISPLAY " "
           DISPLAY "==============================="
           DISPLAY "        謝謝使用本系統        "
           DISPLAY "        銀行管理系統 V1.0      "
           DISPLAY "==============================="
           .

       910-CLOSE-CUSTOMER-FILE.
            CLOSE CUSTOMER-FILE.

       920-CLOSE-ACCOUNT-FILE.
            CLOSE ACCOUNT-FILE.

       930-CLOSE-TRANSACTION-FILE.
            CLOSE TRANS-FILE.
            
        950-VALIDATE-ID.
            MOVE "N" TO WS-ID-VALID
            INITIALIZE WS-ID-NO

            *> 步驟1：字首英文字母對應表
            EVALUATE FUNCTION UPPER-CASE(WS-ID-C1)
                WHEN 'A'  MOVE 1 TO WS-ID-N1  MOVE 0 TO WS-ID-N2
                WHEN 'B'  MOVE 1 TO WS-ID-N1  MOVE 1 TO WS-ID-N2
                WHEN 'C'  MOVE 1 TO WS-ID-N1  MOVE 2 TO WS-ID-N2
                WHEN 'D'  MOVE 1 TO WS-ID-N1  MOVE 3 TO WS-ID-N2
                WHEN 'E'  MOVE 1 TO WS-ID-N1  MOVE 4 TO WS-ID-N2
                WHEN 'F'  MOVE 1 TO WS-ID-N1  MOVE 5 TO WS-ID-N2
                WHEN 'G'  MOVE 1 TO WS-ID-N1  MOVE 6 TO WS-ID-N2
                WHEN 'H'  MOVE 1 TO WS-ID-N1  MOVE 7 TO WS-ID-N2
                WHEN 'I'  MOVE 3 TO WS-ID-N1  MOVE 4 TO WS-ID-N2
                WHEN 'J'  MOVE 1 TO WS-ID-N1  MOVE 8 TO WS-ID-N2
                WHEN 'K'  MOVE 1 TO WS-ID-N1  MOVE 9 TO WS-ID-N2
                WHEN 'L'  MOVE 2 TO WS-ID-N1  MOVE 0 TO WS-ID-N2
                WHEN 'M'  MOVE 2 TO WS-ID-N1  MOVE 1 TO WS-ID-N2
                WHEN 'N'  MOVE 2 TO WS-ID-N1  MOVE 2 TO WS-ID-N2
                WHEN 'O'  MOVE 3 TO WS-ID-N1  MOVE 5 TO WS-ID-N2
                WHEN 'P'  MOVE 2 TO WS-ID-N1  MOVE 3 TO WS-ID-N2
                WHEN 'Q'  MOVE 2 TO WS-ID-N1  MOVE 4 TO WS-ID-N2
                WHEN 'R'  MOVE 2 TO WS-ID-N1  MOVE 5 TO WS-ID-N2
                WHEN 'S'  MOVE 2 TO WS-ID-N1  MOVE 6 TO WS-ID-N2
                WHEN 'T'  MOVE 2 TO WS-ID-N1  MOVE 7 TO WS-ID-N2
                WHEN 'U'  MOVE 2 TO WS-ID-N1  MOVE 8 TO WS-ID-N2
                WHEN 'V'  MOVE 2 TO WS-ID-N1  MOVE 9 TO WS-ID-N2
                WHEN 'W'  MOVE 3 TO WS-ID-N1  MOVE 2 TO WS-ID-N2
                WHEN 'X'  MOVE 3 TO WS-ID-N1  MOVE 0 TO WS-ID-N2
                WHEN 'Y'  MOVE 3 TO WS-ID-N1  MOVE 1 TO WS-ID-N2
                WHEN 'Z'  MOVE 3 TO WS-ID-N1  MOVE 3 TO WS-ID-N2
                WHEN OTHER
                    DISPLAY "錯誤：身份證字號首碼必須為英文字母"
                    EXIT PARAGRAPH
            END-EVALUATE

            *> 步驟2：將第2~9碼移入驗證區
            MOVE WS-ID-C2  TO WS-ID-N3
            MOVE WS-ID-C3  TO WS-ID-N4
            MOVE WS-ID-C4  TO WS-ID-N5
            MOVE WS-ID-C5  TO WS-ID-N6
            MOVE WS-ID-C6  TO WS-ID-N7
            MOVE WS-ID-C7  TO WS-ID-N8
            MOVE WS-ID-C8  TO WS-ID-N9
            MOVE WS-ID-C9  TO WS-ID-N10

            *> 步驟3：計算加權總和
            COMPUTE WS-ID-SUM =
                ( WS-ID-N1  * 1 ) +
                ( WS-ID-N2  * 9 ) +
                ( WS-ID-N3  * 8 ) +
                ( WS-ID-N4  * 7 ) +
                ( WS-ID-N5  * 6 ) +
                ( WS-ID-N6  * 5 ) +
                ( WS-ID-N7  * 4 ) +
                ( WS-ID-N8  * 3 ) +
                ( WS-ID-N9  * 2 ) +
                ( WS-ID-N10 * 1 )

            *> 步驟4：計算驗證碼
            DIVIDE WS-ID-SUM BY 10
                GIVING WS-ID-RESULT
                REMAINDER WS-ID-RESULT2
            IF WS-ID-RESULT2 = 0
                MOVE 0 TO WS-ID-CHECK
            ELSE
                COMPUTE WS-ID-CHECK = 10 - WS-ID-RESULT2
            END-IF

            *> 步驟5：比對末碼
            IF WS-ID-CHECK = WS-ID-C10
                MOVE "Y" TO WS-ID-VALID
            ELSE
                DISPLAY "身份證字號驗證失敗（末碼應為 " WS-ID-CHECK "）"
            END-IF
            .

       End Program BANK.
