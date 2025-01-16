### **1. Kafka Topic**
#### **Concept**:
- A Kafka topic is a **log of events**. Producers write data to topics, and consumers read from them. It’s the core storage mechanism in Kafka.

#### **Example**:
Imagine a banking application where all transactions are recorded in a Kafka topic named `bank_transactions`.

**Events in `bank_transactions`:**
```json
{"transaction_id": "T1", "account_id": "A1", "transaction_amount": 500, "transaction_type": "DEBIT"}
{"transaction_id": "T2", "account_id": "A2", "transaction_amount": 1000, "transaction_type": "CREDIT"}
{"transaction_id": "T3", "account_id": "A1", "transaction_amount": 300, "transaction_type": "DEBIT"}
```

**Explanation**:
- **Producer**: Writes these events to the topic.
- **Consumer**: Reads these events from the topic.

---

### **2. Kafka Stream (KStream)**
#### **Concept**:
- A **KStream** is a continuous, unbounded stream of records from a Kafka topic.
- It’s **stateless**, meaning each record is processed independently.

#### **Example**:
You want to filter out transactions where the amount exceeds ₹500.

**Code:**
```java
KStream<String, Transaction> transactions = builder.stream("bank_transactions");

transactions.filter((key, value) -> value.getTransactionAmount() > 500)
           .to("large_transactions");
```

**Explanation**:
1. The `builder.stream("bank_transactions")` creates a **KStream** from the `bank_transactions` topic.
2. The `filter` operation processes each record and passes only those where `transaction_amount > 500`.
3. The filtered records are written to a new topic, `large_transactions`.

**Result in `large_transactions`:**
```json
{"transaction_id": "T2", "account_id": "A2", "transaction_amount": 1000, "transaction_type": "CREDIT"}
```

---

### **3. Kafka Table (KTable)**
#### **Concept**:
- A **KTable** represents the **latest state** for each key in a topic. It’s stateful and acts like a materialized view.

#### **Example**:
Track the **current balance** for each account.

**Input Topic (`account_balances`):**
```json
{"account_id": "A1", "balance": 5000}
{"account_id": "A2", "balance": 3000}
{"account_id": "A1", "balance": 4500}  // Updated balance
```

**Code:**
```java
KTable<String, Double> accountBalances = builder.table("account_balances");

accountBalances.toStream().foreach((key, value) -> 
    System.out.println("Account: " + key + ", Balance: " + value));
```

**Explanation**:
1. The `builder.table("account_balances")` creates a **KTable**.
2. The KTable tracks the latest balance for each account (`account_id` is the key).
3. The `.toStream()` converts the KTable back to a stream for real-time output.

**Output:**
```
Account: A1, Balance: 4500
Account: A2, Balance: 3000
```

---

### **4. Stream-Table Join**
#### **Concept**:
- Combine a **stream** with a **table** to enrich events in the stream with the current state stored in the table.

#### **Example**:
Add account balances to transactions in real time.

**Input Stream (`bank_transactions`):**
```json
{"transaction_id": "T1", "account_id": "A1", "transaction_amount": 500}
{"transaction_id": "T2", "account_id": "A2", "transaction_amount": 1000}
```

**Input Table (`account_balances`):**
```json
{"account_id": "A1", "balance": 4500}
{"account_id": "A2", "balance": 3000}
```

**Code:**
```java
KStream<String, Transaction> transactions = builder.stream("bank_transactions");
KTable<String, Double> accountBalances = builder.table("account_balances");

transactions.join(accountBalances, (transaction, balance) -> {
    transaction.setBalance(balance);
    return transaction;
}).to("enriched_transactions");
```

**Explanation**:
1. The `join` operation enriches each transaction with the **current balance** from the table.
2. The enriched transactions are written to `enriched_transactions`.

**Result in `enriched_transactions`:**
```json
{"transaction_id": "T1", "account_id": "A1", "transaction_amount": 500, "balance": 4500}
{"transaction_id": "T2", "account_id": "A2", "transaction_amount": 1000, "balance": 3000}
```

---

### **5. KTable-KTable Join**
#### **Concept**:
- Join two KTables to combine their states.

#### **Example**:
Combine user profile data (`user_profiles`) with their preferences (`user_preferences`).

**User Profiles:**
```json
{"user_id": "U1", "name": "Alice"}
{"user_id": "U2", "name": "Bob"}
```

**User Preferences:**
```json
{"user_id": "U1", "preference": "Email"}
{"user_id": "U2", "preference": "SMS"}
```

**Code:**
```java
KTable<String, String> profiles = builder.table("user_profiles");
KTable<String, String> preferences = builder.table("user_preferences");

profiles.join(preferences, (profile, preference) -> profile + " prefers " + preference)
        .toStream().to("user_details");
```

**Result in `user_details`:**
```json
{"user_id": "U1", "details": "Alice prefers Email"}
{"user_id": "U2", "details": "Bob prefers SMS"}
```

---

### **Relationships Between Concepts**

| **Concept**   | **Derived From**       | **Stateful?** | **Use Case**                          |
|---------------|-------------------------|---------------|---------------------------------------|
| **Topic**     | Base storage unit       | No            | Durable log of events.               |
| **KStream**   | Topic                   | No            | Stateless, real-time processing.     |
| **KTable**    | Topic (changelog)       | Yes           | Current state for each key.          |
| **Materialized View** | KTable           | Yes           | Queryable current state.             |

---

### **Summary**
1. Use **topics** to store and share data between producers and consumers.
2. Use **streams (KStream)** for stateless, real-time processing.
3. Use **tables (KTable)** for stateful processing or when you care about the latest state for each key.
4. Combine **streams and tables** for enriched, powerful real-time applications.
