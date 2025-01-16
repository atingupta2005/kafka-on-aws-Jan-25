**Hands-On Exercise: Implementing Stream Processing with Kafka Streams and KSQL**

---

### **1. Objective**
This exercise will guide participants in implementing a complete stream processing solution using Kafka Streams and KSQL. The goal is to:
1. Process streaming data using Kafka Streams.
2. Analyze and transform data using KSQL.
3. Validate results through hands-on testing.

---

### **2. Prerequisites**
- An AWS MSK cluster configured with Kafka topics using plaintext communication.
- A development environment with Kafka Streams libraries (e.g., Java SDK).
- Access to KSQL CLI or KSQLDB UI.
- Familiarity with Kafka concepts (e.g., producers, consumers, topics).

---

### **3. Problem Statement**
A retail business wants to:
1. Process incoming transaction data to identify top-selling products.
2. Analyze sales data using SQL queries for generating real-time insights.

---

### **4. Setup and Configuration**

#### **4.1 Create Kafka Topics**
1. **Log in to AWS Console:** Navigate to the MSK service.
2. **Create Input Topic:**
   - Name: `transactions-topic`
   - Partitions: 3 (adjust based on workload)
   - Replication Factor: 3
3. **Create Output Topics:**
   - Name: `top-products-topic` (for Kafka Streams output)
   - Name: `ksql-aggregated-sales-topic` (for KSQL output)

#### **4.2 Set Up KSQLDB Server with AWS MSK**
1. **Deploy KSQLDB Server:**
   - Launch a KSQLDB server instance in the same VPC as your MSK cluster.
   - Use plaintext configuration for communication with MSK brokers.

   Example configuration:
   ```properties
   ksql.streams.bootstrap.servers=<MSK-Broker-Endpoint>
   ksql.streams.security.protocol=PLAINTEXT
   ```

2. **Expose KSQL UI:**
   - Install KSQLDB CLI or use a lightweight UI such as Docker-based KSQLDB UI.
     - **Docker Command:**
       ```bash
       docker run -d --name ksqldb-cli -p 8088:8088 confluentinc/ksqldb-server
       ```

3. **Test Connectivity:**
   - Verify connection to the MSK brokers by running a simple query in the CLI/UI:
     ```sql
     SHOW STREAMS;
     ```

#### **4.3 Set Up Java Development Environment**
1. **Install JDK and Maven:**
   - Ensure Java JDK (version 8 or higher) and Maven are installed.
   - Verify installation:
     ```bash
     java -version
     mvn -version
     ```

2. **Create a Maven Project:**
   - Run:
     ```bash
     mvn archetype:generate -DgroupId=com.kafka.streams -DartifactId=kafka-streams-example -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
     ```

3. **Add Dependencies to `pom.xml`:**
   ```xml
   <dependencies>
       <dependency>
           <groupId>org.apache.kafka</groupId>
           <artifactId>kafka-streams</artifactId>
           <version>3.0.0</version>
       </dependency>
       <dependency>
           <groupId>org.apache.kafka</groupId>
           <artifactId>kafka-clients</artifactId>
           <version>3.0.0</version>
       </dependency>
       <dependency>
           <groupId>org.slf4j</groupId>
           <artifactId>slf4j-log4j12</artifactId>
           <version>1.7.30</version>
       </dependency>
   </dependencies>
   ```

4. **Build and Run the Java Application:**
   - Compile the application:
     ```bash
     mvn clean package
     ```
   - Run the application:
     ```bash
     java -jar target/kafka-streams-example-1.0-SNAPSHOT.jar
     ```

---

### **5. Implementing Kafka Streams**

#### **5.1 Write Kafka Streams Application**
```java
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.kstream.*;

import java.util.Properties;

public class TopSellingProducts {

    public static void main(String[] args) {
        // Step 1: Configure Kafka Streams
        Properties props = new Properties();
        props.put(StreamsConfig.APPLICATION_ID_CONFIG, "top-selling-products-app");
        props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "<MSK-Broker-Endpoint>");
        props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass());
        props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass());

        StreamsBuilder builder = new StreamsBuilder();

        // Step 2: Read from the input topic
        KStream<String, String> transactions = builder.stream("transactions-topic",
                Consumed.with(Serdes.String(), Serdes.String()));

        // Step 3: Transform data to extract product information
        KStream<String, Integer> products = transactions
                .mapValues(value -> Integer.parseInt(value.split(",")[2])) // Assuming CSV format: id,user,product,amount
                .groupBy((key, value) -> value.toString())
                .count(Materialized.as("product-count-store"))
                .toStream();

        // Step 4: Write results to output topic
        products.to("top-products-topic", Produced.with(Serdes.String(), Serdes.Integer()));

        // Step 5: Start the Kafka Streams application
        KafkaStreams streams = new KafkaStreams(builder.build(), props);
        streams.start();

        // Step 6: Add shutdown hook
        Runtime.getRuntime().addShutdownHook(new Thread(streams::close));
    }
}
```

---

### **6. Implementing KSQL Queries**

#### **6.1 Stream Creation**
1. **Access KSQL CLI or UI:**
   - Connect to the KSQLDB server with proper credentials.
2. **Create Stream for Transactions:**
   ```sql
   CREATE STREAM transactions_stream (
       transaction_id STRING,
       user_id STRING,
       product_id STRING,
       amount DOUBLE
   ) WITH (
       KAFKA_TOPIC='transactions-topic',
       VALUE_FORMAT='JSON'
   );
   ```

#### **6.2 Aggregation Query**
1. **Calculate Top-Selling Products:**
   ```sql
   CREATE TABLE top_products AS
   SELECT product_id, COUNT(*) AS total_sales
   FROM transactions_stream
   GROUP BY product_id
   EMIT CHANGES;
   ```
2. **Output Aggregated Results:**
   - Results are stored in the table `top_products` and can be queried in real time.

#### **6.3 Export Results to a Topic:**
```sql
CREATE STREAM aggregated_sales_stream AS
SELECT * FROM top_products
EMIT CHANGES;
```
- **Output Topic:** `ksql-aggregated-sales-topic`

---

### **7. Validation and Testing**

#### **7.1 Test Kafka Streams Application**
1. **Send Sample Data:**
   - Use Kafka CLI to produce sample transactions to `transactions-topic`.
   - Example Command:
     ```bash
     kafka-console-producer --broker-list <MSK-Broker-Endpoint> --topic transactions-topic
     ```
     Sample Data:
     ```json
     {"transaction_id":"txn1","user_id":"user1","product_id":"prod1","amount":20.5}
     {"transaction_id":"txn2","user_id":"user2","product_id":"prod1","amount":15.0}
     ```

2. **Verify Output:**
   - Consume messages from `top-products-topic` to validate results.

#### **7.2 Test KSQL Queries**
1. **Run SELECT Queries:**
   ```sql
   SELECT * FROM top_products EMIT CHANGES;
   ```
2. **Validate Data:**
   - Ensure the top-selling products are correctly aggregated.

---

### **8. Best Practices**
1. **Monitor Applications:**
   - Use AWS CloudWatch to track Kafka Streams and KSQL performance metrics.
2. **Optimize Partitioning:**
   - Ensure input topics are well-partitioned for scalability.
3. **Fault Tolerance:**
   - Validate changelog topic replication and retention for both Kafka Streams and KSQL.
4. **Test Incrementally:**
   - Validate each step with sample data before proceeding to the next.

