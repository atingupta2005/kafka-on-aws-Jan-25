### Hands-On Exercise: Debugging Kafka Producer and Consumer Issues

#### **Objective**
1. Identify and debug common producer and consumer issues in a Kafka sandbox environment.
2. Apply best practices to resolve issues such as message duplication, consumer lag, and connection errors.

---

### **Pre-Requisites**

1. A running Kafka environment (local setup or a managed service like MSK).
2. Kafka CLI tools installed on your local machine.
3. Basic knowledge of Kafka producers and consumers.

---

### **Step 1: Setting Up the Sandbox Environment**

##### **1.1 Create a Kafka Topic**
Create a new Kafka topic named `debug-topic` with 3 partitions and a replication factor of 2:
```bash
kafka-topics.sh --create \
    --bootstrap-server $BS_SERVER \
    --replication-factor 2 \
    --partitions 3 \
    --topic debug-topic
```

##### **1.2 Start a Simple Producer and Consumer**
1. **Producer:**
   ```bash
   kafka-console-producer.sh --broker-list $BS_SERVER --topic debug-topic
   ```
   Type a few messages into the producer console, such as:
   ```
   message1
   message2
   message3
   ```

2. **Consumer:**
   ```bash
   kafka-console-consumer.sh --bootstrap-server $BS_SERVER \
       --topic debug-topic \
       --group debug-group \
       --from-beginning
   ```

3. Verify that the consumer displays the messages you type into the producer console.

---

### **Step 2: Simulating and Debugging Producer Issues**

##### **2.1 Issue: Message Duplication**
- **Simulation:**
   1. Configure the producer with `acks=1` and introduce network latency or instability.
   2. Send the same message multiple times by triggering retries.

   Example producer configuration:
   ```java
   props.put("acks", "1");
   props.put("retries", 5);
   props.put("linger.ms", 0);
   props.put("enable.idempotence", false);
   ```

- **Debugging Steps:**
   1. Use the Kafka CLI to inspect the topic:
      ```bash
      kafka-console-consumer.sh --bootstrap-server $BS_SERVER \
          --topic debug-topic \
          --from-beginning
      ```
   2. Check for duplicate messages in the output.
   3. Modify the producer configuration to enable idempotence:
      ```java
      props.put("enable.idempotence", true);
      ```

##### **2.2 Issue: Lost Messages**
- **Simulation:**
   1. Configure the producer with `acks=0` (fire-and-forget mode).
   2. Send multiple messages and shut down the broker during message transmission.

- **Debugging Steps:**
   1. Restart the broker and verify message loss by consuming from the topic.
   2. Adjust the producer configuration to use `acks=all` and retry settings:
      ```java
      props.put("acks", "all");
      props.put("retries", 5);
      ```

---

### **Step 3: Simulating and Debugging Consumer Issues**

##### **3.1 Issue: Consumer Lag**
- **Simulation:**
   1. Start a producer that sends messages at a high rate:
      ```bash
      kafka-producer-perf-test.sh --topic debug-topic \
          --num-records 10000 --record-size 100 --throughput 1000 \
          --producer.config producer.properties
      ```
   2. Use a single consumer to process messages:
      ```bash
      kafka-console-consumer.sh --bootstrap-server $BS_SERVER \
          --topic debug-topic \
          --group debug-group
      ```

- **Debugging Steps:**
   1. Monitor consumer lag:
      ```bash
      kafka-consumer-groups.sh --bootstrap-server $BS_SERVER --describe --group debug-group
      ```
   2. Add more consumers to the group to reduce lag:
      ```bash
      kafka-console-consumer.sh --bootstrap-server $BS_SERVER \
          --topic debug-topic \
          --group debug-group
      ```
   3. Optimize consumer configuration by increasing `fetch.min.bytes` and `fetch.max.wait.ms` to improve throughput.

##### **3.2 Issue: Consumer Group Rebalancing**
- **Simulation:**
   1. Start 3 consumers in the same group.
   2. Stop one consumer abruptly to trigger a rebalance.

- **Debugging Steps:**
   1. Monitor rebalancing logs in the Kafka broker and consumer logs.
   2. Configure **static group membership** by adding `group.instance.id` to the consumer configuration.
   3. Increase the session timeout to avoid frequent rebalancing:
      ```java
      props.put("session.timeout.ms", 30000);
      ```

---

---

### **Step 4: Cleanup**
1. Delete the topic:
   ```bash
   kafka-topics.sh --bootstrap-server $BS_SERVER --delete --topic debug-topic
   ```
2. Shut down the sandbox environment to free resources.

---

### **Conclusion**
In this hands-on exercise, you simulated and debugged common producer and consumer issues, including message duplication, lost messages, consumer lag, and group rebalancing. By applying the troubleshooting techniques, you gained practical experience in identifying and resolving Kafka issues effectively.

