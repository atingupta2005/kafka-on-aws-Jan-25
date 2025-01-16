**Hands-On Exercise: Scaling Kafka Clusters and Setting Up Backup and Recovery in AWS MSK**

---

### **1. Objective**
This hands-on exercise focuses on:
- Scaling Kafka clusters in AWS MSK to manage increased workloads.
- Setting up simple and practical backup and recovery mechanisms for data reliability.
- Troubleshooting common Kafka issues in a pre-configured setup.

---

### **2. Prerequisites**
- Access to an AWS account with permissions to create and modify MSK resources.
- Basic knowledge of Kafka topics, partitions, and replication.
- Familiarity with AWS CloudWatch.
- A pre-configured AWS MSK cluster with a sample topic.

---

### **3. Scaling Kafka Clusters in AWS MSK**

#### **3.1 Scaling the Cluster**
1. **Navigate to MSK in AWS Console:**
   - Go to the **Amazon MSK** section in the AWS Management Console.
   - Select the pre-configured cluster.

2. **Add Brokers to the Cluster:**
   - Click **Edit Cluster** and increase the number of brokers in the cluster.
   - AWS MSK will automatically provision the additional brokers.

3. **Verify Partition Distribution:**
   - Use AWS CloudWatch to monitor metrics like **`UnderReplicatedPartitions`** to ensure proper replication. *(Note: Metric names may vary across AWS MSK versions.)*

4. **Test the Cluster:**
   - Produce and consume messages using sample topics to verify load balancing and replication after scaling.

---

### **4. Troubleshooting Kafka Issues**

#### **4.1 Common Issues and Resolutions**
1. **Under-Replicated Partitions:**
   - **Issue:** Partitions are not fully replicated across brokers.
   - **Solution:** Monitor **`UnderReplicatedPartitions`** and ensure replication factor settings are adequate.

2. **Consumer Lag:**
   - **Issue:** Consumers are falling behind in processing messages.
   - **Solution:** Monitor **`OffsetLag`** and adjust consumer configurations such as `max.poll.records`.

3. **Broker Resource Bottlenecks:**
   - **Issue:** High CPU or memory usage on brokers.
   - **Solution:** Scale the cluster or optimize producer and consumer configurations.

