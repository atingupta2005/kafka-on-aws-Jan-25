**ksqlDB Cheatsheet: Financial Data Focused Use Cases with Complete Examples**

---

### **Core Commands**

#### **1. List All Streams and Topics**
- **Streams**:
  ```sql
  SHOW STREAMS;
  ```
- **Topics**:
  ```sql
  SHOW TOPICS;
  ```

---

### **Financial Transaction Streams**

#### **2. Create a Stream for Bank Transactions**
Create a stream for bank transactions:
```sql
CREATE STREAM bank__transactions (
    transaction_id STRING,
    account_id STRING,
    transaction_amount DOUBLE,
    transaction_type STRING,
    transaction_timestamp BIGINT,
    currency STRING,
    location STRUCT<
        city STRING,
        country STRING>
) WITH (
    KAFKA_TOPIC = 'bank__transactions',
    PARTITIONS = 2,
    REPLICAS = 1,
    VALUE_FORMAT = 'JSON'
);
```

#### **Insert Bank Transaction Data**
Populate the stream with realistic bank transaction data:
```sql
INSERT INTO bank__transactions (
    transaction_id, account_id, transaction_amount, transaction_type, 
    transaction_timestamp, currency, location)
VALUES
    ('BT1001', 'AC001', 5000.00, 'DEPOSIT', 1672549200000, 'USD', STRUCT(city := 'New York', country := 'USA'));

INSERT INTO bank__transactions (
    transaction_id, account_id, transaction_amount, transaction_type, 
    transaction_timestamp, currency, location)
VALUES
    ('BT1002', 'AC002', 200.00, 'WITHDRAWAL', 1672552800000, 'USD', STRUCT(city := 'London', country := 'UK'));

INSERT INTO bank__transactions (
    transaction_id, account_id, transaction_amount, transaction_type, 
    transaction_timestamp, currency, location)
VALUES
    ('BT1003', 'AC003', 750.00, 'TRANSFER', 1672556400000, 'EUR', STRUCT(city := 'Berlin', country := 'Germany'));

INSERT INTO bank__transactions (
    transaction_id, account_id, transaction_amount, transaction_type, 
    transaction_timestamp, currency, location)
VALUES
    ('BT1004', 'AC004', 1500.00, 'DEPOSIT', 1672560000000, 'USD', STRUCT(city := 'San Francisco', country := 'USA'));

INSERT INTO bank__transactions (
    transaction_id, account_id, transaction_amount, transaction_type, 
    transaction_timestamp, currency, location)
VALUES
    ('BT1005', 'AC005', 300.00, 'WITHDRAWAL', 1672563600000, 'GBP', STRUCT(city := 'Manchester', country := 'UK'));
```

---

### **Advanced Financial Use Cases**

#### **3. Transaction Summaries by Account**
Summarize total deposits, withdrawals, and transfers by account:
```sql
CREATE TABLE transaction_summaries AS
SELECT account_id,
       SUM(CASE WHEN transaction_type = 'DEPOSIT' THEN transaction_amount ELSE CAST(0 AS DOUBLE) END) AS total_deposits,
       SUM(CASE WHEN transaction_type = 'WITHDRAWAL' THEN transaction_amount ELSE CAST(0 AS DOUBLE) END) AS total_withdrawals,
       SUM(CASE WHEN transaction_type = 'TRANSFER' THEN transaction_amount ELSE CAST(0 AS DOUBLE) END) AS total_transfers
FROM bank__transactions
GROUP BY account_id;
```

#### **4. Currency-Based Analysis**
Aggregate total transaction amounts by currency:
```sql
CREATE TABLE currency_totals AS
SELECT currency, SUM(transaction_amount) AS total_amount
FROM bank__transactions
GROUP BY currency;
```

#### **Insert Additional Transactions for Analysis**
```sql
INSERT INTO bank__transactions (
    transaction_id, account_id, transaction_amount, transaction_type, 
    transaction_timestamp, currency, location)
VALUES
    ('BT2001', 'AC006', 10000.00, 'DEPOSIT', 1672605600000, 'USD', STRUCT(city := 'Miami', country := 'USA'));

INSERT INTO bank__transactions (
    transaction_id, account_id, transaction_amount, transaction_type, 
    transaction_timestamp, currency, location)
VALUES
    ('BT2002', 'AC007', 500.00, 'WITHDRAWAL', 1672609200000, 'EUR', STRUCT(city := 'Paris', country := 'France'));

INSERT INTO bank__transactions (
    transaction_id, account_id, transaction_amount, transaction_type, 
    transaction_timestamp, currency, location)
VALUES
    ('BT2003', 'AC008', 250.00, 'TRANSFER', 1672612800000, 'GBP', STRUCT(city := 'Edinburgh', country := 'UK'));

INSERT INTO bank__transactions (
    transaction_id, account_id, transaction_amount, transaction_type, 
    transaction_timestamp, currency, location)
VALUES
    ('BT2004', 'AC009', 3000.00, 'DEPOSIT', 1672616400000, 'USD', STRUCT(city := 'Los Angeles', country := 'USA'));

INSERT INTO bank__transactions (
    transaction_id, account_id, transaction_amount, transaction_type, 
    transaction_timestamp, currency, location)
VALUES
    ('BT2005', 'AC010', 1200.00, 'WITHDRAWAL', 1672620000000, 'EUR', STRUCT(city := 'Rome', country := 'Italy'));
```

---

### **Fraud Detection and Alerts**

#### **5. Detect High-Value Transactions**
Identify transactions exceeding a specific threshold:
```sql
CREATE STREAM high_value_transactions AS
SELECT transaction_id, account_id, transaction_amount, transaction_type
FROM bank__transactions
WHERE transaction_amount > 5000;
```

#### **6. Geo-Based Fraud Alerts**
Detect unusual transaction locations:
```sql
CREATE STREAM geo_fraud_alerts AS
SELECT transaction_id, account_id, location
FROM bank__transactions
WHERE location->country NOT IN ('USA', 'UK', 'Germany', 'France');
```

---

### **Session Analysis for Accounts**
Analyze user sessions with financial transactions:
```sql
CREATE TABLE account_sessions AS
SELECT account_id,
       WINDOWSTART AS session_start,
       WINDOWEND AS session_end,
       COUNT(*) AS total_transactions,
       SUM(transaction_amount) AS session_total
FROM bank__transactions
WINDOW SESSION (15 MINUTES)
GROUP BY account_id;
```

#### **Insert Session Data**
```sql
INSERT INTO bank__transactions (
    transaction_id, account_id, transaction_amount, transaction_type, 
    transaction_timestamp, currency, location)
VALUES
    ('BT3001', 'AC011', 400.00, 'TRANSFER', 1672630800000, 'USD', STRUCT(city := 'New York', country := 'USA'));

INSERT INTO bank__transactions (
    transaction_id, account_id, transaction_amount, transaction_type, 
    transaction_timestamp, currency, location)
VALUES
    ('BT3002', 'AC011', 600.00, 'DEPOSIT', 1672631400000, 'USD', STRUCT(city := 'New York', country := 'USA'));

INSERT INTO bank__transactions (
    transaction_id, account_id, transaction_amount, transaction_type, 
    transaction_timestamp, currency, location)
VALUES
    ('BT3003', 'AC012', 1200.00, 'WITHDRAWAL', 1672632000000, 'GBP', STRUCT(city := 'London', country := 'UK'));
```

---

### **Risk Assessment Metrics**

#### **7. Calculate Account Risk Levels**
Assign risk levels based on transaction patterns:
```sql
CREATE TABLE account_risk_levels AS
SELECT account_id,
       CASE
           WHEN SUM(transaction_amount) > 10000 THEN 'HIGH'
           WHEN SUM(transaction_amount) BETWEEN 5000 AND 10000 THEN 'MEDIUM'
           ELSE 'LOW'
       END AS risk_level
FROM bank__transactions
GROUP BY account_id;
```

---

### **Extended Geo-Analysis**

#### **8. Transactions by Country**
```sql
CREATE TABLE transactions_by_country AS
SELECT location->country AS country, COUNT(*) AS total_transactions,
       SUM(transaction_amount) AS total_revenue
FROM bank__transactions
GROUP BY location->country;
```

#### **Insert Data for Comprehensive Analysis**
```sql
INSERT INTO bank__transactions (
    transaction_id, account_id, transaction_amount, transaction_type, 
    transaction_timestamp, currency, location)
VALUES
    ('BT4001', 'AC013', 8000.00, 'DEPOSIT', 1672640000000, 'USD', STRUCT(city := 'Toronto', country := 'Canada'));

INSERT INTO bank__transactions (
    transaction_id, account_id, transaction_amount, transaction_type, 
    transaction_timestamp, currency, location)
VALUES
    ('BT4002', 'AC014', 2200.00, 'WITHDRAWAL', 1672643600000, 'EUR', STRUCT(city := 'Vienna', country := 'Austria'));

INSERT INTO bank__transactions (
    transaction_id, account_id, transaction_amount, transaction_type, 
    transaction_timestamp, currency, location)
VALUES
    ('BT4003', 'AC015', 500.00, 'TRANSFER', 1672647200000, 'GBP', STRUCT(city := 'Dublin', country := 'Ireland'));

INSERT INTO bank__transactions (
    transaction_id, account_id, transaction_amount, transaction_type, 
    transaction_timestamp, currency, location)
VALUES
    ('BT4004', 'AC016', 3500.00, 'DEPOSIT', 1672650800000, 'USD', STRUCT(city := 'San Diego', country := 'USA'));

INSERT INTO bank__transactions (
    transaction_id, account_id, transaction_amount, transaction_type, 
    transaction_timestamp, currency, location)
VALUES
    ('BT4005', 'AC017', 150.00, 'WITHDRAWAL', 1672654400000, 'AUD', STRUCT(city := 'Sydney', country := 'Australia'));
```

---
