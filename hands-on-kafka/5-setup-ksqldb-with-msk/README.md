**Setup ksqlDB with AWS MSK**

---

### **1. What is ksqlDB?**

#### **Overview**
ksqlDB is a purpose-built, open-source database designed for real-time stream processing using Apache Kafka. It enables users to process, analyze, and transform Kafka topics using SQL-like queries. ksqlDB is a distributed, scalable, and fault-tolerant system that simplifies building event-driven applications.

#### **Key Features**
- **SQL-like Queries:** Query Kafka streams and tables without requiring custom code.
- **Stream Processing:** Perform filtering, transformations, joins, and aggregations.
- **Stateful Operations:** Manage state across streams and tables for complex computations.
- **Interactive CLI and UI:** Simplified interfaces for querying and managing.

---

### **2. How to Set Up ksqlDB Easily**

#### **Using Docker Compose (Recommended)**

1. **Create a `Dockerfile` for ksqlDB Server:**
   ```dockerfile
   FROM confluentinc/ksqldb-server:latest
   EXPOSE 8088
   CMD ["/etc/confluent/docker/run"]
   ```

2. **Create a `docker-compose.yml` File:**
   ```yaml
   version: '3.7'
   services:
     ksqldb-server:
       build: .
       ports:
         - "8088:8088"
       environment:
         KSQL_CONFIG_DIR: /etc/ksqldb
         KSQL_BOOTSTRAP_SERVERS: <MSK-Broker-Endpoint>
         AWS_REGION: <your-region>
         AWS_ACCESS_KEY_ID: <your-access-key-id>
         AWS_SECRET_ACCESS_KEY: <your-secret-access-key>
         AWS_SESSION_TOKEN: <your-session-token> # If using temporary credentials
       volumes:
         - ./ksql-config:/etc/ksqldb

     ksqldb-ui:
       image: quay.io/ksqldb/ksqldb-ui:latest
       ports:
         - "8089:8080"
       environment:
         KSQLDB_SERVER: http://ksqldb-server:8088
   ```

3. **Create a `ksql-config` Directory:**
   - Place any custom configurations for ksqlDB inside this directory.

4. **Run Docker Compose:**
   ```bash
   docker-compose up -d
   ```

5. **Verify Installation:**
   - Access the ksqlDB server at `http://localhost:8088`.
   - Access the ksqlDB-UI at `http://localhost:8089`.

---

### **3. Connecting ksqlDB to AWS MSK**

#### **Configuration Steps**
1. **Identify MSK Broker Endpoints:**
   - Navigate to the AWS MSK console and copy the bootstrap server endpoints.

2. **Set Up IAM Authentication:**
   - Enable IAM-based security in your MSK cluster settings.
   - Attach the required IAM policies to the role or user running the ksqlDB service:
     ```json
     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Action": [
             "kafka-cluster:Connect",
             "kafka-cluster:DescribeCluster",
             "kafka-cluster:DescribeTopic",
             "kafka-cluster:ReadData",
             "kafka-cluster:WriteData"
           ],
           "Resource": "arn:aws:kafka:<region>:<account-id>:cluster/<cluster-name>/*"
         }
       ]
     }
     ```

3. **Update ksqlDB Configuration Files:**
   - Add the following properties to `ksql-server.properties` in `ksql-config`:
     ```properties
     ksql.bootstrap.servers=<MSK-Broker-Endpoint>
     ksql.streams.bootstrap.servers=<MSK-Broker-Endpoint>
     ksql.security.protocol=SASL_SSL
     ksql.sasl.mechanism=AWS_MSK_IAM
     ksql.sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;
     ```

4. **Test Connectivity:**
   - Execute a simple query to list available topics:
     ```sql
     SHOW TOPICS;
     ```

---

### **4. Installing ksqlDB-UI and Connecting to ksqlDB Server**

#### **Steps to Install ksqlDB-UI with Docker Compose**
1. **Ensure ksqlDB-UI is Defined in `docker-compose.yml`:**
   ```yaml
   ksqldb-ui:
     image: quay.io/ksqldb/ksqldb-ui:latest
     ports:
       - "8089:8080"
     environment:
       KSQLDB_SERVER: http://ksqldb-server:8088
   ```

2. **Run the UI Service:**
   - Start the UI alongside the ksqlDB server:
     ```bash
     docker-compose up -d
     ```

3. **Access the UI:**
   - Navigate to `http://localhost:8089` in your browser.

---

### **5. How to Use ksqlDB-UI**

#### **Using the Query Editor**
1. **Create a Stream:**
   ```sql
   CREATE STREAM pageviews (
       user_id STRING,
       page_id STRING,
       view_time BIGINT
   ) WITH (
       KAFKA_TOPIC='pageviews-topic',
       VALUE_FORMAT='JSON'
   );
   ```

2. **Query Data in Real Time:**
   ```sql
   SELECT * FROM pageviews EMIT CHANGES;
   ```

3. **Save Queries:**
   - Use the UI to save frequently used queries.

#### **Real-Time Monitoring:**
- View active queries, topics, and consumer groups in the UI dashboard.

---

### **6. How to Use the ksqlDB Server Web Interface**

#### **Overview of Features**
- **Interactive Querying:** Write and execute queries directly.
- **Stream/Table Management:** Create, view, and manage streams and tables.
- **Query Monitoring:** Track the status and performance of running queries.

#### **Steps to Use:**
1. Access the server interface at `http://localhost:8088`.
2. Use REST API endpoints for advanced management.
   - Example: Fetch running queries
     ```bash
     curl -X GET http://localhost:8088/query
     ```

---

### **7. Troubleshooting**

#### **Common Issues and Fixes**
1. **Connection Issues:**
   - Verify the `bootstrap.servers` property and network configuration.
2. **Query Errors:**
   - Check topic schema compatibility (e.g., JSON vs. AVRO).
3. **IAM Authentication Issues:**
   - Ensure the IAM role or user has appropriate permissions.
   - Verify AWS credentials are correctly configured.
4. **UI Not Responding:**
   - Ensure the UI and server endpoints are correctly linked.

---

### **8. Important Commands**

#### **Stream and Table Management:**
- Create a Stream:
  ```sql
  CREATE STREAM users (
      id STRING,
      name STRING
  ) WITH (KAFKA_TOPIC='users-topic', VALUE_FORMAT='JSON');
  ```
- Create a Table:
  ```sql
  CREATE TABLE user_counts AS
  SELECT id, COUNT(*) AS cnt FROM users GROUP BY id EMIT CHANGES;
  ```

#### **Query Management:**
- Show Streams:
  ```sql
  SHOW STREAMS;
  ```
- Terminate a Query:
  ```sql
  TERMINATE <query-id>;
  ```

---

### **9. Cheatsheet**

| Task                        | Command                                      |
|-----------------------------|----------------------------------------------|
| Show all topics             | `SHOW TOPICS;`                              |
| Create a stream             | `CREATE STREAM ...;`                        |
| Query a stream              | `SELECT * FROM stream_name EMIT CHANGES;`   |
| Show running queries        | `SHOW QUERIES;`                             |
| Terminate a query           | `TERMINATE <query-id>;`                     |
| Drop a stream               | `DROP STREAM <stream-name>;`                |

---
