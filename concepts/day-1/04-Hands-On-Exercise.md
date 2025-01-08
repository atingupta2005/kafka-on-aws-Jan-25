### Hands-On Exercise: Setting Up and Using Kafka

#### **Objective**
By the end of this hands-on exercise, you will:
1. Set up a basic Kafka environment.
2. Create and test a simple producer-consumer setup using **Amazon Managed Streaming for Apache Kafka (MSK)**.

---

### **Step 1: Setting Up a Basic Kafka Environment**

##### **1.1 Create an Amazon MSK Cluster**
1. **Log in to the AWS Management Console.**
2. Navigate to **Amazon MSK** (search for "MSK" in the AWS services menu).
3. Click **Create cluster** and select **Custom create**.
4. Configure the following settings:
   - **Cluster Name**: `basic-kafka-cluster`
   - **Broker Instance Type**: `kafka.t3.small` (for a small-scale exercise)
   - **Number of Brokers**: 3 (for high availability)
5. Under **Networking**, ensure the cluster is deployed in a VPC with proper subnet and security group configurations to allow communication.
6. Enable **TLS/Plaintext** communication.
7. Click **Create cluster** and wait for the cluster to be ready (this may take several minutes).

##### **1.2 Install Kafka CLI Tools**
1. Install the Kafka CLI tools on your EC2 instance:
   - After creating EC2 instance, we also need to assign a custom role having custom policy. Refer - MSKPolicy.json
   - Download Kafka binaries from the [Apache Kafka download page](https://kafka.apache.org/downloads).
   - Extract the files and add the `bin` directory to your system's PATH.
```
sudo yum update -y
sudo yum install java-11-amazon-corretto-devel -y
wget https://archive.apache.org/dist/kafka/3.6.0/kafka_2.13-3.6.0.tgz
tar -xzf kafka_2.13-3.6.0.tgz
sudo mkdir -p /usr/local/kafka
sudo cp -r kafka_2.13-3.6.0/* /usr/local/kafka
echo 'export KAFKA_HOME=/usr/local/kafka' >> ~/.bashrc
echo 'export PATH=$PATH:$KAFKA_HOME/bin' >> ~/.bashrc
source ~/.bashrc
echo $KAFKA_HOME
echo $PATH
```
2. Test the installation by running:
   ```bash
   kafka-topics.sh --version
   ```

##### **1.3 Connect to the MSK Cluster**
1. Use the **Bootstrap Servers** information from your MSK cluster details.
2. Edit the `client.properties` file to include:
   - sudo nano /usr/local/kafka/config/client.properties
```
security.protocol=PLAINTEXT
```

3. Test the connection by listing the topics:
```bash
aws kafka list-clusters
aws kafka describe-cluster --cluster-arn arn:aws:kafka:us-east-1:891377046325:cluster/ag-cluster-3/47ce9685-f4b1-4ae9-bf6b-ec0862054d77-13
aws kafka get-bootstrap-brokers --cluster-arn  arn:aws:kafka:us-east-1:891377046325:cluster/ag-cluster-3/47ce9685-f4b1-4ae9-bf6b-ec0862054d77-13
export BS_SERVER="b-2.agcluster3.dfkesh.c13.kafka.us-east-1.amazonaws.com:9092,b-1.agcluster3.dfkesh.c13.kafka.us-east-1.amazonaws.com:9092"
```

```
kafka-topics.sh --bootstrap-server $BS_SERVER --list
kafka-topics.sh --bootstrap-server $BS_SERVER --list --command-config /usr/local/kafka/config/client.properties
```

---

### **Step 2: Simple Producer-Consumer Setup**

##### **2.1 Create a Topic**
1. Use the Kafka CLI to create a new topic called `test-topic`:
   ```bash
   kafka-topics.sh --create \
       --bootstrap-server $BS_SERVER \
       --replication-factor 2 \
       --partitions 1 \
       --topic test-topic
   ```

2. Verify the topic creation:
   ```bash
   kafka-topics.sh --bootstrap-server $BS_SERVER --list
   ```

##### **2.2 Start a Kafka Producer**
1. Open a terminal and run the Kafka producer:
   ```bash
   kafka-console-producer.sh --broker-list $BS_SERVER --topic test-topic
   ```

2. Type some messages into the producer console. Example:
   ```
   Hello, Kafka!
   This is a test message.
   ```

##### **2.3 Start a Kafka Consumer**
1. Open another terminal and run the Kafka consumer:
   ```bash
   kafka-console-consumer.sh --bootstrap-server $BS_SERVER \
       --topic test-topic \
       --from-beginning
   ```

2. Observe the messages sent by the producer appearing in the consumer console.

---

### **Verification and Cleanup**

##### **3.1 Verify the Setup**
- Confirm that the messages typed in the producer console appear in the consumer console.
- Experiment by sending multiple messages and observing the real-time delivery.

##### **3.2 Cleanup Resources**
1. Delete the Kafka topic:
   ```bash
   kafka-topics.sh --bootstrap-server $BS_SERVER --delete --topic test-topic
   ```
2. Delete the MSK cluster from the AWS Management Console to avoid incurring charges.

---

### **Conclusion**
In this hands-on exercise, you:
- Set up a basic Kafka environment using Amazon MSK.
- Created a topic, sent messages using a producer, and consumed messages in real-time using a consumer.
- Gained practical experience with Kafka’s core producer-consumer workflow.
