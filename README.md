
# COBOL Batch Program.

This README provides a comprehensive guide to setting up the environment, preparing the database, and running a COBOL program that processes customer and transaction data. The program generates a summary report based on the input data.

---

## **System Requirements**
1. **VirtualBox** (for setting up a virtual machine)
   - [Download VirtualBox](https://www.virtualbox.org/)

2. **Ubuntu 24.04 LTS**
   - [Download Ubuntu](https://ubuntu.com/download/desktop)

3. **SQLite3**
   - Installed within the Ubuntu virtual machine.

4. **GnuCOBOL**
   - Installed for COBOL program compilation and execution.

---

## **Setup Guide**

### Step 1: Setting Up Ubuntu in VirtualBox
1. Install VirtualBox.
2. Create a new virtual machine:
   - Name: `UbuntuCobol`
   - Type: `Linux`
   - Version: `Ubuntu 64-bit`
   - Base Memory: Allocate at least 4GB. Recommended: 8192 MB
   - Processors: Set at least 1. Recommeneded: 2.
   - Video memory: 128 MB
   - Storage: Create a virtual hard disk of at least 64GB.

3. Boot the virtual machine with the downloaded Ubuntu ISO.
4. Follow the installation wizard to set up Ubuntu.

### Step 2: Install Required Tools
1. Open a terminal in Ubuntu and update the package list:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. Install SQLite3:
   ```bash
   sudo apt install sqlite3 -y
   ```

3. Install GnuCOBOL:
   ```bash
   sudo apt install open-cobol -y
   ```

---

## **Database Setup**

### Step 1: Create the Database
1. Use SQLite3 to create a database:
   ```bash
   sqlite3 database.db
   ```

2. Create the required tables (a file name `schema.sql`) by executing the following SQL commands:
   ```sql
   CREATE TABLE CUSTOMER (
       CUSTOMERID INTEGER PRIMARY KEY,
       NAME TEXT NOT NULL,
       EMAIL TEXT NOT NULL,
       SIGNUPDATE DATE NOT NULL
   );

   CREATE TABLE TRANSACTIONS (
       TRANSACTIONID INTEGER PRIMARY KEY,
       CUSTOMERID INTEGER NOT NULL,
       TRANSACTIONDATE DATE NOT NULL,
       AMOUNT DECIMAL(10,2) NOT NULL,
       TRANSACTIONTYPE TEXT NOT NULL,
       FOREIGN KEY (CUSTOMERID) REFERENCES CUSTOMER (CUSTOMERID)
   );
   ```

3. Insert sample data (file renamed `data.sql`):
   ```bash
   sqlite3 database.db < data.sql
   ```

---

## **Python Script for Data Export**

The provided Python script exports data from the `CUSTOMER` and `TRANSACTIONS` tables into fixed-width text files (`customer_data.txt` and `transaction_data.txt`) that can be processed by the COBOL program.

### Script Usage
1. Save the script as `export_data.py`.
2. Run the script:
   ```bash
   python3 export_data.py
   ```
3. Output files:
   - `customer_data.txt`
   - `transaction_data.txt`

---

## **COBOL Program**

### Overview
The COBOL program processes the fixed-width files and generates a CSV report summarizing:
1. Total transactions for each customer.
2. Total revenue (sum of `AMOUNT` where `TRANSACTIONTYPE = 'Purchase'`).
3. Total refunds (count of `TRANSACTIONTYPE = 'Refund'`).

### Compilation
1. Save the COBOL program as `summary_report.cbl`.
2. Compile the program:
   ```bash
   cobc -x summary_report.cbl
   ```

### Execution
Run the program:
```bash
./summary_report
```

---

## **File Formats**

### Input Files
1. **Customer Data (`customer_data.txt`)**
   - Fixed-width format:
     - CUSTOMERID: 6 characters, zero-padded.
     - NAME: 50 characters, space-padded.
     - EMAIL: 100 characters, space-padded.
     - SIGNUPDATE: 10 characters, space-padded.

2. **Transaction Data (`transaction_data.txt`)**
   - Fixed-width format:
     - TRANSACTIONID: 8 characters, zero-padded.
     - CUSTOMERID: 6 characters, zero-padded.
     - TRANSACTIONDATE: 10 characters, space-padded.
     - AMOUNT: 12 characters, zero-padded, with decimals removed (compatible with `PIC 9(10)V99`).
     - TRANSACTIONTYPE: 20 characters, space-padded.

### Output File
**Report (`report.csv`)**
- CSV format:
  - Fields:
    - CustomerID
    - Name
    - TotalTransactions
    - TotalRevenue
    - NumberOfRefunds

---

## **Logic in COBOL**

### 1. File Handling
- Opens and reads the input files (`customer_data.txt`, `transaction_data.txt`).
- Processes records one by one, matching transactions to customers.

### 2. Summary Computation
- Computes totals for transactions, revenue, and refunds.

### 3. Output
- Writes the computed summary to a CSV file (`report.csv`).

---

## **Testing and Validation**
1. Validate the input files (`customer_data.txt` and `transaction_data.txt`) for correct formatting.
2. Verify the CSV report against the raw data to ensure accuracy.

---

## **Troubleshooting**
1. **"File not found" error during execution:**
   - Ensure the input files are in the same directory as the COBOL program.
2. **Incorrect decimal formatting:**
   - Check the Python script to ensure `AMOUNT` is properly converted to `PIC 9(10)V99` format.