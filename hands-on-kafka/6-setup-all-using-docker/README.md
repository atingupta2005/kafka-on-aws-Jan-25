# **ksqlDB with Kafka and Docker Compose**

This repository provides a complete setup for running **ksqlDB**, **Kafka**, **Zookeeper**, and **ksqlDB-UI** using Docker Compose. It is configured to integrate with AWS Managed Streaming for Apache Kafka (MSK) using **IAM-based security**.

---

## **Folder Structure**

```
/my-ksql-setup
├── Dockerfile                 # Dockerfile to build ksqlDB server
├── docker-compose.yml         # Docker Compose configuration file
├── ksql-config/               # Configuration directory for ksqlDB
│   └── ksql-server.properties # ksqlDB server configuration
```

---

## **Setup Instructions**

### **1. Prerequisites**

1. Install **Docker** and **Docker Compose** on your machine.
   - [Install Docker](https://docs.docker.com/get-docker/)
   - [Install Docker Compose](https://docs.docker.com/compose/install/)

2. Ensure you have AWS credentials with the necessary permissions for MSK:
   - `kafka-cluster:Connect`
   - `kafka-cluster:DescribeCluster`
   - `kafka-cluster:DescribeTopic`
   - `kafka-cluster:ReadData`
   - `kafka-cluster:WriteData`

---

### **2. Configuration**

1. **Update `ksql-server.properties`**:
   - In the `ksql-config/ksql-server.properties` file, update the following:
     ```properties
     ksql.bootstrap.servers=<MSK-Broker-Endpoint>
     ksql.streams.bootstrap.servers=<MSK-Broker-Endpoint>
     ksql.security.protocol=SASL_SSL
     ksql.sasl.mechanism=AWS_MSK_IAM
     ksql.sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;
     ```

2. **Set Environment Variables**:
   - In `docker-compose.yml`, replace placeholders with your AWS credentials:
     ```yaml
     AWS_REGION: <your-region>
     AWS_ACCESS_KEY_ID: <your-access-key-id>
     AWS_SECRET_ACCESS_KEY: <your-secret-access-key>
     AWS_SESSION_TOKEN: <your-session-token> # Optional if using temporary credentials
     ```

---

### **3. Running the Setup**

1. Navigate to the project directory:
   ```bash
   cd /path/to/my-ksql-setup
   ```

2. Start the services:
   ```bash
   docker-compose up -d --build
   ```

3. Verify that all containers are running:
   ```bash
   docker ps
   ```

---

### **4. Access Services**

- **Zookeeper:** `localhost:2181`
- **Kafka Broker:** `localhost:9092`
- **ksqlDB Server:** `http://localhost:8088`
- **ksqlDB-UI:** `http://localhost:8089`

---

## **Usage**

### **1. Verify Kafka Connection**
Run the following query in ksqlDB-UI or via the ksqlDB REST API to list Kafka topics:
```sql
SHOW TOPICS;
```

### **2. Create a Stream**
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

### **3. Query Real-Time Data**
```sql
SELECT * FROM pageviews EMIT CHANGES;
```

---

## **Troubleshooting**

### **Common Issues**
1. **Connection Issues:**
   - Verify the `bootstrap.servers` endpoint in `ksql-server.properties`.
   - Check network connectivity to the MSK cluster.

2. **IAM Authentication Errors:**
   - Ensure AWS credentials have the necessary permissions.
   - Verify that the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are correctly set in `docker-compose.yml`.

3. **Service Logs:**
   - Use the following commands to inspect logs:
     ```bash
     docker logs kafka
     docker logs ksqldb-server
     docker logs ksqldb-ui
     ```

---

## **Cheatsheet**

| Task                        | Command                                      |
|-----------------------------|----------------------------------------------|
| Show all topics             | `SHOW TOPICS;`                              |
| Create a stream             | `CREATE STREAM ...;`                        |
| Query a stream              | `SELECT * FROM stream_name EMIT CHANGES;`   |
| Show running queries        | `SHOW QUERIES;`                             |
| Terminate a query           | `TERMINATE <query-id>;`                     |
| Drop a stream               | `DROP STREAM <stream-name>;`                |

---

## **License**
This project is licensed under the MIT License. See the `LICENSE` file for details.

