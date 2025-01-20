**Hands-On Exercise: Setting Up Security and Compliance Features in AWS MSK**

---

### **1. Objective**
This hands-on exercise guides participants through the process of implementing security and compliance features in AWS Managed Streaming for Apache Kafka (MSK). The goal is to:
1. Secure communication and data storage.
2. Configure authentication and authorization.
3. Enable monitoring and logging for compliance.

---

### **2. Prerequisites**
- An AWS account with permissions to manage MSK clusters.
- A pre-configured MSK cluster or permissions to create one.
- Familiarity with basic Kafka concepts (e.g., brokers, topics).
- AWS CLI and Java SDK installed for client configurations.

---

### **3. Implementation Steps**

#### **Step 1: Enable Encryption in AWS MSK**
##### **Encryption in Transit**
1. **Navigate to the AWS MSK Console:**
   - Go to the **Amazon MSK** service in the AWS Management Console.
2. **Create or Edit a Cluster:**
   - Select **Create Cluster** or edit an existing cluster.
3. **Enable TLS:**
   - In the **Networking** section, enable **TLS encryption** for communication between clients and brokers.
4. **Update Client Configuration:**
   - Configure Kafka clients to use `SASL_SSL` or `SSL`.
   - Example configuration:
     ```properties
     security.protocol=SSL
     ssl.truststore.location=/path/to/truststore.jks
     ssl.truststore.password=truststore-password
     ```

##### **Encryption at Rest**
1. **KMS Configuration:**
   - During cluster creation, select **Encryption at Rest**.
   - Use the default AWS-managed key or a customer-managed KMS key.
2. **Key Rotation:**
   - If using a customer-managed key, enable automatic key rotation in KMS.

---

#### **Step 2: Set Up Authentication and Authorization**
##### **IAM Authentication**
1. **Enable IAM Access Control:**
   - During cluster creation, enable **IAM access control**.
2. **Create IAM Policies:**
   - Define policies to control access to topics, for example:
     ```json
     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Action": [
             "kafka-cluster:Connect",
             "kafka-cluster:WriteData",
             "kafka-cluster:ReadData"
           ],
           "Resource": "arn:aws:kafka:region:account-id:cluster/cluster-name/*"
         }
       ]
     }
     ```
3. **Assign Policies:**
   - Attach the policy to IAM roles or users used by Kafka clients.
4. **Client Configuration:**
   - Use AWS SDKs to generate IAM tokens.
   - Example:
     ```properties
     security.protocol=SASL_SSL
     sasl.mechanism=AWS_MSK_IAM
     sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;
     ```

##### **SASL/SCRAM Authentication**
1. **Add SASL/SCRAM Credentials:**
   - Create secrets in AWS Secrets Manager and associate them with your MSK cluster.
   - Example CLI command:
     ```bash
     aws kafka create-scram-secret --cluster-arn <cluster-arn> --secret-name <secret-name>
     ```
2. **Update Client Configuration:**
   - Configure clients to use the username and password stored in Secrets Manager.
   - Example:
     ```properties
     security.protocol=SASL_SSL
     sasl.mechanism=SCRAM-SHA-512
     sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="<username>" password="<password>";
     ```

---

#### **Step 3: Enable Monitoring and Logging**
##### **Broker Logs**
1. **Enable Logging:**
   - During cluster creation, enable broker logging to:
     - **CloudWatch Logs**: For centralized monitoring.
     - **S3**: For long-term storage and analysis.
     - **OpenSearch**: For advanced log querying and visualization.
2. **Configure Log Group or Bucket Policies:**
   - Ensure the destination (e.g., S3 bucket) has appropriate permissions for MSK.

##### **Monitoring with CloudWatch**
1. **Enable Metrics:**
   - In the MSK console, enable enhanced monitoring for key metrics.
2. **Set Up Dashboards:**
   - Use CloudWatch dashboards to monitor metrics like:
     - **BytesInPerSec**: Data ingestion rate.
     - **UnderReplicatedPartitions**: Replication health.
3. **Create Alarms:**
   - Set alarms for critical events like high replication lag or broker failures.

---

#### **Step 4: Configure Topic Policies for Compliance**
1. **Data Retention Policies:**
   - Set topic-level retention policies to limit data storage duration:
     ```bash
     kafka-configs --zookeeper <zookeeper-endpoint> --alter --entity-type topics --entity-name <topic-name> --add-config retention.ms=604800000
     ```
     *(Example: Retain data for 7 days)*
2. **Access Control:**
   - Use IAM policies or topic-level ACLs to restrict access based on roles.

---

### **4. Validation and Testing**

#### **4.1 Test Encryption**
1. **Client Connectivity:**
   - Use a Kafka producer to send messages to an encrypted cluster.
2. **Inspect Logs:**
   - Verify that logs show secure TLS connections.

#### **4.2 Test Authentication**
1. **IAM Authentication:**
   - Attempt to connect using an IAM role with no permissions to ensure access is denied.
2. **SASL/SCRAM:**
   - Verify that clients without correct credentials cannot connect.

#### **4.3 Test Logging and Monitoring**
1. **CloudWatch Logs:**
   - Check for broker connection logs and message flow events.
2. **Set Alarm Trigger:**
   - Simulate an issue (e.g., broker downtime) and validate CloudWatch alarms.

---

### **5. Best Practices for Security and Compliance in MSK**
1. **Enable Both Encryption at Rest and In Transit:**
   - Always encrypt sensitive data.
2. **Implement Principle of Least Privilege:**
   - Restrict access to only the required users and roles.
3. **Regularly Rotate Credentials:**
   - Rotate SASL/SCRAM credentials and IAM keys periodically.
4. **Enable Monitoring and Alerts:**
   - Use CloudWatch alarms for proactive issue detection.
5. **Review Logs Regularly:**
   - Audit access patterns and detect anomalies.
6. **Data Masking:**
   - Mask sensitive fields at the producer level to reduce exposure.

---
