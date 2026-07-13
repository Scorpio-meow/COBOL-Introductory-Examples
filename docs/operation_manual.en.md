[English](operation_manual.en.md) | [繁體中文](operation_manual.md)

# Bank Management System - System Operation & Compilation Guide

This document explains how to set up the execution environment, compile the COBOL source code, and operate the menu functions of the Bank Management System, while providing deep insights into the core algorithms and technical designs within the system.

> [!WARNING]
> This project is designed solely as a code syntax demonstration and does not implement any data encryption or security mechanisms (sensitive information such as ID card numbers, phone numbers, balances, and transaction details are stored in plain text). Do not use this project directly in actual production or commercial environments.

---

## 1. Environment Setup & Installation (WSL Debian/Ubuntu)

If you are using Windows, it is recommended to run the GnuCOBOL compiler through the **Windows Subsystem for Linux (WSL)** with a Debian or Ubuntu distribution.

### Step 1: Enable WSL in Windows
1. Open PowerShell as Administrator.
2. Run the following command to enable the WSL feature:
   ```powershell
   Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
   ```
3. Restart your computer as prompted by the system.

### Step 2: Install and Start a Linux Distribution
1. Open PowerShell and enter the following command to install the Debian distribution:
   ```powershell
   wsl --install -d Debian
   ```
2. After the installation is complete, the Linux terminal will open automatically. Follow the prompts to set up your username and password.

### Step 3: Install the GnuCOBOL Compiler
1. In the Linux terminal, run the package update commands:
   ```bash
   sudo apt-get update
   sudo apt-get upgrade
   ```
2. Install the GnuCOBOL compiler:
   ```bash
   sudo apt-get -y install gnucobol
   ```
3. Verify that the compiler is successfully installed and check its version:
   ```bash
   cobc --version
   ```

---

## 2. Program Compilation & Execution

The COBOL source code for this project is located in [BANK.cbl](../BANK.cbl). Please follow these steps to compile and run it:

### Step 1: Compile the COBOL Program
Enter the project directory in the Linux terminal and run the following compilation command:
```bash
cobc -x -free BANK.cbl -o BANK
```
* `-x`: Generates a standalone executable binary file named `BANK`.
* `-free`: Instructs the compiler to use free format for COBOL code. This frees the code from traditional COBOL column 1-6 and 72-80 format restrictions, making it easier to read and modify in modern editors.
* `-o BANK`: Specifies the output filename as `BANK`.

### Step 2: Run the Program
Enter the following command in the terminal to start the system:
```bash
./BANK
```

---

## 3. System Menu Operation Instructions

After running the program, the system will display the following main menu interface:

```text
===============================
      Bank Management Menu     
===============================
1. Add Customer Data
2. Open New Account
3. Deposit
4. Withdraw
5. Transfer
6. Query Balance
9. Exit System
===============================
Please enter your choice (1-9): 
```

### Feature 1: Add Customer Data
* **Description**: Create basic personal information for a new customer.
* **Workflow**:
  1. Enter `1` and press Enter.
  2. The system will automatically calculate and display the Customer ID to be generated (e.g., `New Customer ID: 000005`).
  3. Enter the following fields in sequence:
     * **ID Card Number**: Must match the format (an uppercase letter followed by 9 digits, e.g., `A123456789`). The system will automatically perform validation for Taiwan ID Card numbers. If the format is invalid, you will be prompted to re-enter.
     * **Customer Name**: Enter the customer's name (cannot be empty).
     * **Customer Address**: Enter the customer's contact address.
     * **Contact Phone**: Enter the phone number.
  4. After confirming that the information is correct, enter `Y` to save. The system will write the data to [CUSTOMER.SAM](../CUSTOMER.SAM).

### Feature 2: Open New Account
* **Description**: Open a new savings or checking account for an existing customer.
* **Workflow**:
  1. Enter `2` and press Enter.
  2. Enter the **Customer ID** to be associated with the account.
  3. The system validates whether the Customer ID exists in [CUSTOMER.SAM](../CUSTOMER.SAM):
     * If it does not exist, an error message is displayed, and you are returned to the main menu.
     * If it exists, a unique account number is generated, and you are prompted to select the account type:
       * Enter `S`: Open a Savings Account (Savings)
       * Enter `C`: Open a Checking Account (Checking)
  4. Enter the **Initial Deposit** amount.
  5. The system automatically retrieves the current system date as the opening date, sets the account status to Active, writes to [ACCOUNT.SAM](../ACCOUNT.SAM), and records an "Initial Deposit" entry in the transaction history file [TRANS.SAM](../TRANS.SAM).

### Feature 3: Deposit Operation
* **Description**: Deposit funds into a specified account.
* **Workflow**:
  1. Enter `3` and press Enter.
  2. Enter the **Account Number** for the deposit.
  3. The system validates whether the account number exists, and whether it is Closed or Suspended.
  4. Enter the **Deposit Amount** (must be greater than zero).
  5. The system updates the account balance using the safe temporary file mechanism and records a transaction of type `D` (Deposit) with the description "Counter Deposit" in [TRANS.SAM](../TRANS.SAM).

### Feature 4: Withdrawal Operation
* **Description**: Withdraw funds from a specified account.
* **Workflow**:
  1. Enter `4` and press Enter.
  2. Enter the **Account Number**.
  3. The system validates the account status and prompts for the **Withdrawal Amount**.
  4. The system checks if the account balance is sufficient:
     * If the balance is insufficient, an error message is displayed, and the withdrawal is aborted.
     * If the balance is sufficient, the balance is updated, and a transaction of type `W` (Withdrawal) with the description "Counter Withdrawal" is recorded in [TRANS.SAM](../TRANS.SAM).

### Feature 5: Transfer Operation
* **Description**: Transfer funds from a source account to a destination account.
* **Workflow**:
  1. Enter `5` and press Enter.
  2. Enter the **Source Account Number** and **Destination Account Number** (they cannot be the same, and both account statuses must be Active).
  3. Enter the **Transfer Amount**.
  4. The system checks if the source account balance is sufficient:
     * If insufficient, an error is displayed and the transfer exits.
     * If sufficient, the source account balance is deducted, and the destination account balance is increased.
  5. The system writes two transaction records to [TRANS.SAM](../TRANS.SAM):
     * A transaction of type `T` (Transfer) with the description "Transfer to Account: [Destination Account]" is written for the source account.
     * A transaction of type `T` (Transfer) with the description "Transfer from Account: [Source Account]" is written for the destination account.

### Feature 6: Query Balance
* **Description**: Display current account status, associated customer information, and the latest 5 transaction details.
* **Workflow**:
  1. Enter `6` and press Enter.
  2. Enter the **Account Number**.
  3. The system displays:
     * **Account Info**: Account number, Customer ID, type, balance, opening date, status.
     * **Customer Info**: Name, ID card number, address, phone.
     * **Latest 5 Transaction Records**: Date, time, type (deposit/withdrawal/transfer), amount, balances before/after transaction, and description.

### Feature 9: Exit System
* **Description**: End program execution.
* **Workflow**:
  1. Enter `9` and press Enter.
  2. The system safely closes all open data files, displays `Thank you for using the system, goodbye!` and exits.

---

## 4. System Design & Technical Implementation Details

### Taiwan ID Card Validation Algorithm

The system automatically performs a validity check on the ID card number field (1 uppercase letter + 9 digits) when adding a customer. The algorithm is implemented in the `950-VALIDATE-ID` paragraph:

1. **Letter to Value Mapping**:
   The first letter is converted into a 2-digit number. The tens digit is stored in `WS-ID-N1`, and the units digit is stored in `WS-ID-N2`. The mapping table is as follows:
   * `A` -> 10, `B` -> 11, ..., `I` -> 34, `O` -> 35, `W` -> 32, `Z` -> 33 (some letters have special mappings, such as I, O, W, Z).

2. **Weighted Multiplication Formula**:
   The remaining 2nd to 10th digits (`N3` to `N10`, where `N10` is the last digit of the ID card) are multiplied by fixed weights and summed up with the mapped values of the letter:
   $$\text{Sum} = (N1 \times 1) + (N2 \times 9) + (N3 \times 8) + (N4 \times 7) + (N5 \times 6) + (N6 \times 5) + (N7 \times 4) + (N8 \times 3) + (N9 \times 2) + (N10 \times 1)$$

3. **Remainder & Check**:
   * Calculate remainder: $\text{Remainder} = \text{Sum} \bmod 10$.
   * Calculate checksum: If $\text{Remainder} = 0$, checksum is $0$; otherwise, checksum is $10 - \text{Remainder}$.
   * The system compares this checksum with the 10th digit of the ID card (the last digit). The validation passes only if they match exactly.

### Safe File Update Mechanism

To prevent raw account data files from being corrupted due to abnormal program termination during file writes, the system implements a temporary safe update mechanism:

1. **Write to Temp File**: When performing any transaction, the program opens [ACCOUNT.SAM](../ACCOUNT.SAM) in read-only mode, and simultaneously opens a temporary file [TEMP-ACCOUNT.SAM](../TEMP-ACCOUNT.SAM) for writing.
2. **Data Migration & Update**: The program copies unchanged account data directly to the temporary file. When it reads the account involved in the current transaction, it writes the updated balance and fields to the temporary file.
3. **Rename & Overwrite**: After all writes are confirmed complete, the program closes both files and calls the COBOL system function:
   ```cobol
   CALL "CBL_RENAME_FILE" USING "TEMP-ACCOUNT.SAM" "ACCOUNT.SAM"
   ```
   This safely overwrites the old data with the temporary file, ensuring file read/write consistency.

### Recent Transaction Ring Buffer

In a memory-constrained environment, to extract and display the latest 5 transactions for an account in the most efficient way, the system adopts a Ring Buffer design:

1. **Declare Static Array**: Declare a table structure containing 5 elements in the `Working-Storage Section`:
   ```cobol
   05  WS-RING-ENTRY  OCCURS 5 TIMES.
       10  WR-ID      PIC X(12).
       ...
   ```
2. **Sequential Read & Circular Overwrite**:
   The system sequentially reads the entire transaction file [TRANS.SAM](../TRANS.SAM). Whenever it reads a transaction that matches the queried account number, the system increments the matching transaction counter `WS-TRANS-TOTAL` and calculates the write index in the array using the following formula:
   $$\text{Write-Index} = (\text{WS-TRANS-TOTAL} - 1 \bmod 5) + 1$$
   Then, it overwrites the record into `WS-RING-ENTRY(Write-Index)`.
3. **Sequential Output**:
   Once the file read is complete, if the total number of transactions is less than 5, the system outputs from index 1 to index `WS-TRANS-TOTAL`. If it is greater than or equal to 5, the system calculates the starting index of the oldest transaction in the ring buffer and sequentially outputs 5 records, completing the pagination display from oldest to newest with extremely low memory usage.
