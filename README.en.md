[English](README.en.md) | [繁體中文](README.md)

# COBOL Bank Management System

This project is a simple bank management system developed in COBOL. The system uses Line Sequential Files for data storage and provides features such as customer data management, account opening, deposits, withdrawals, transfers, balance inquiries, and recent transaction details.

> [!WARNING]
> This project is designed solely as a code syntax demonstration and does not implement any data encryption or security mechanisms (sensitive information such as ID card numbers, phone numbers, balances, and transaction details are stored in plain text). Do not use this project directly in actual production or commercial environments.

## Quick Start

### Environment Requirements

This system is recommended to run in an environment with the GnuCOBOL compiler installed (e.g., Debian/Ubuntu in Windows Subsystem for Linux - WSL).

1. **Install GnuCOBOL**
   Run the following commands in the WSL/Linux terminal to install the compiler:
   ```bash
   sudo apt-get update
   sudo apt-get -y install gnucobol
   ```

2. **Verify Installation**
   ```bash
   cobc --version
   ```

### Compilation & Execution

1. **Compile Code**
   In the project root directory, use `cobc` to compile [BANK.cbl](./BANK.cbl) into an executable:
   ```bash
   cobc -x -free BANK.cbl -o BANK
   ```
   * `-x`: Instructs the compiler to generate a standalone executable.
   * `-free`: Compiles the COBOL source code using free format.
   * `-o BANK`: Specifies the output executable name as `BANK`.

2. **Run Program**
   ```bash
   ./BANK
   ```

## Features

The system provides the following core features, which can be selected from the main menu:

- **Add Customer Data**: Generates a unique 6-digit Customer ID, records ID card number, name, address, and phone number. The system features a built-in **Taiwan ID Card weighted checksum validation mechanism** to ensure the validity of input data.
- **Open New Account**: Validates whether the Customer ID exists, generates a unique 10-digit account number, supports savings and checking accounts, and allows setting an initial deposit.
- **Deposit Operation**: Deposits funds into a specified account, updates the balance, and records the transaction.
- **Withdrawal Operation**: Withdraws funds from a specified account (automatically checks for sufficient balance), updates the balance, and records the transaction.
- **Transfer Operation**: Supports transferring funds between two accounts, deducting from the source account balance, adding to the destination account balance, and recording two separate transaction details (transfer-out and transfer-in).
- **Query Balance & Transaction Details**: Displays basic account info, associated customer info, and reads/displays the latest 5 transaction records for the account using ring buffer technology.
- **Exit System**: Safely closes all open files and exits.

## File Configuration

| File Name | Format | Description |
| :--- | :--- | :--- |
| [CUSTOMER.SAM](./CUSTOMER.SAM) | Line Sequential | Stores customer basic data. |
| [ACCOUNT.SAM](./ACCOUNT.SAM) | Line Sequential | Stores account and balance information. |
| [TRANS.SAM](./TRANS.SAM) | Line Sequential | Stores all transaction history records. |
| [TEMP-ACCOUNT.SAM](./TEMP-ACCOUNT.SAM) | Line Sequential | Temporary account file used during transactions to implement safe file updates. |

## Related Documentation

- [Data Structures](./docs/data_structures.en.md)
- [System Operation & Compilation Guide](./docs/operation_manual.en.md)
