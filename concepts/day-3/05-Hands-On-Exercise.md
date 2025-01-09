### Hands-On Exercise: Setting Up and Troubleshooting a Kafka Cluster Using AWS MSK

#### **Objective**
This hands-on exercise will guide you through:
1. Setting up a basic Kafka cluster using AWS Managed Streaming for Apache Kafka (MSK).
2. Identifying and resolving common installation issues during the setup process.

---

### **Part 1: Setting Up a Basic Kafka Cluster Using MSK**

##### **Step 1.1: Create an MSK Cluster**
1. **Log in to the AWS Management Console.**
   - Ensure you have the required permissions to create and manage MSK clusters.

2. Navigate to **Amazon MSK**.
   - Search for "MSK" in the AWS services menu.

3. Click **Create Cluster** and select **Custom create**.

4. Configure the cluster settings:
   - **Cluster Name:** `basic-msk-cluster`
   - **Broker Instance Type:** `kafka.t3.small` (suitable for a small-scale test setup).
   - **Number of Brokers:** 3 (ensures high availability).

5. Configure the **Networking and Security** settings:
   - Select a VPC and subnets.
   - Choose or create a security group to allow inbound traffic on port `9092` (Kafka default port).
   - Enable **Plaintext**

6. Review the configuration and click **Create Cluster**.
   - Wait for the cluster status to change to **Active** (this may take a few minutes).

##### **Step 1.2: Set Up Kafka Clients**
1. **Install Kafka CLI tools on your local machine:**
   - Download Kafka binaries from the [Apache Kafka download page](https://kafka.apache.org/downloads).
   - Extract the files and add the `bin` directory to your system PATH.

2. **Obtain the Bootstrap Servers:**
   - Go to the MSK cluster details in the AWS Management Console.
   - Copy the list of bootstrap servers.

3. **Create a Kafka configuration file:**
   - Create a file named `client.properties` with the following content:
     ```
     bootstrap.servers=<bootstrap-server-endpoints>
     security.protocol=PLAINTEXT
     ```

##### **Step 1.3: Create a Kafka Topic**
1. Use the Kafka CLI to create a topic named `test-topic`:
   ```bash
   kafka-topics.sh --create \
       --bootstrap-server <bootstrap-servers> \
       --replication-factor 3 \
       --partitions 3 \
       --topic test-topic \
       --command-config client.properties
   ```

2. Verify that the topic has been created:
   ```bash
   kafka-topics.sh --list \
       --bootstrap-server <bootstrap-servers> \
       --command-config client.properties
   ```

##### **Step 1.4: Start a Producer and Consumer**
1. **Start a Producer:**
   ```bash
   kafka-console-producer.sh --broker-list <bootstrap-servers> \
       --topic test-topic \
       --producer.config client.properties
   ```
   - Type a few messages into the producer console to send them to Kafka.

2. **Start a Consumer:**
   ```bash
   kafka-console-consumer.sh --bootstrap-server <bootstrap-servers> \
       --topic test-topic \
       --from-beginning \
       --consumer.config client.properties
   ```
   - Verify that the consumer receives the messages sent by the producer.

---

### **Part 2: Troubleshooting and Resolving Installation Issues**

#### **Scenario 1: Producers and Consumers Fail to Connect**

**Symptoms:**
- Connection timeout or "Connection refused" errors.

**Possible Causes and Solutions:**
1. **Incorrect Bootstrap Servers:**
   - Ensure the correct bootstrap server endpoints are used.

2. **Security Group Restrictions:**
   - Update the security group to allow inbound traffic on port `9092` (or configured Kafka ports).

3. **VPC/Subnet Configuration:**
   - Ensure the client is in the same VPC as the MSK cluster or configure VPC peering.

---

#### **Scenario 2: Kafka Service Failures**

**Symptoms:**
- Brokers fail to start, or you see errors like "OutOfMemoryError."

**Possible Causes and Solutions:**
1. **Insufficient Resources:**
   - Check the instance type and memory allocation. Upgrade to a larger instance type if required.

---

#### **Scenario 3: Consumer Lag**

**Symptoms:**
- Consumers fall behind the producer, resulting in delayed message processing.

**Possible Causes and Solutions:**
1. **Insufficient Consumers:**
   - Add more consumers to the group to distribute the workload.

2. **Slow Processing Logic:**
   - Optimize the consumer application logic to reduce processing time per message.

---

### **Part 3: Validation and Cleanup**

#### **Validation**
1. Confirm that producers and consumers can successfully communicate.
2. Check the MSK cluster metrics in Amazon CloudWatch for:
   - Broker CPU and memory usage.
   - Consumer lag.
   - Under-replicated partitions.

#### **Cleanup**
1. Delete the Kafka topic:
   ```bash
   kafka-topics.sh --delete \
       --bootstrap-server <bootstrap-servers> \
       --topic test-topic \
       --command-config client.properties
   ```

2. Delete the MSK cluster from the AWS Management Console to avoid incurring charges.

---

### **Conclusion**
By completing this exercise, you have learned how to set up a basic Kafka cluster using AWS MSK and troubleshoot common installation issues. This hands-on experience provides a solid foundation for managing Kafka clusters in real-world scenarios.
