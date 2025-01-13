# **Comprehensive Guide to Configuring SASL SCRAM in AWS MSK**

## **Overview of SASL SCRAM**

- **SASL (Simple Authentication and Security Layer):** A framework for adding authentication support to protocols like Kafka.
- **SCRAM (Salted Challenge Response Authentication Mechanism):** A secure mechanism under SASL. It protects passwords by using:
  - Salted and hashed passwords stored securely.
  - A challenge-response mechanism to authenticate users.

SASL SCRAM is often used for secure authentication in Kafka while ensuring that plain-text credentials are not transmitted.

---

## **Understanding Trust Store**

- A **Trust Store** is a file containing a collection of public certificates from trusted Certificate Authorities (CAs).
- Kafka clients use a trust store to validate the identity of brokers during SSL/TLS communication.
- In AWS MSK, AWS Certificate Manager (ACM) issues the certificates for brokers. You must add the ACM root certificate to your client’s trust store.

---

## **Step 1: Prerequisites**

Before starting, ensure the following:
1. **Cluster Encryption:**  
   Ensure your MSK cluster is configured to use TLS encryption. SASL SCRAM requires SSL for secure communication.

2. **Tools and Permissions:**
   - AWS CLI installed and configured:
     ```bash
     aws configure
     ```
   - IAM permissions to manage MSK, Secrets Manager, and KMS.

3. **Custom KMS Key:**  
   MSK requires a custom AWS KMS key to encrypt secrets. You can create one using the **KMS Console** or CLI:
   ```bash
   aws kms create-key --description "MSK KMS Key"
   ```

---

## **Step 2: Create a Secret in AWS Secrets Manager**

### **Using AWS Console**

1. Open the **AWS Secrets Manager** console.
2. Click **Store a new secret**.
3. Choose **Other type of secrets (e.g., API key)**.
4. Enter your credentials in JSON format:
   ```json
   {
     "username": "atin",
     "password": "atin-secret"
   }
   ```
   Replace `atin` and `atin-secret` with your desired username and password.

5. **Encryption Key:**
   - Under **Encryption Key**, choose an existing custom KMS key or create a new one.
   - **Important:** Do not use the default KMS key. MSK requires a custom key.

6. **Secret Name:**
   - Enter a name starting with `AmazonMSK_`. Example:
     - `AmazonMSK_AtinClusterSecret`.

7. Click **Next**.
8. Review and click **Store**.

---

## **Step 3: Associate the Secret with Your MSK Cluster**

### **Using AWS Console**

1. Open the **MSK Console** and navigate to your cluster.
2. Select the cluster you want to configure.
3. Under **Cluster settings**, locate the **SASL/SCRAM authentication** section.
4. Click **Associate a secret**.
5. Paste the **ARN** of the secret created in Step 2.
6. Save your changes.

---

## **Step 4: Configure Kafka Clients**

After associating the secret, configure your Kafka clients to authenticate using SASL SCRAM.
 - mkdir -p ~/kafka-client/
 - nano ~/kafka-client/kafka-client.properties


### **Kafka Client Properties**
Add the following to your Kafka client configuration:
```properties
security.protocol=SASL_SSL
sasl.mechanism=SCRAM-SHA-512
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="atin" \
    password="atin-secret";
ssl.truststore.location=/home/ec2-user/truststore.jks
ssl.truststore.password=Aws123456
```

### **Trust Store Configuration**

1. **Download ACM Root Certificate:**
   Download the ACM root certificate from the [AWS documentation](https://docs.aws.amazon.com/msk/latest/developerguide/msk-cluster-tls.html).
```
curl -o ~/root.pem https://www.amazontrust.com/repository/AmazonRootCA1.pem

cat ~/root.pem
openssl x509 -in root.pem -text -noout
```

2. **Create Trust Store:**
   Use `keytool` to import the root certificate into a Java Keystore (JKS):
   ```bash
   keytool -import -trustcacerts -alias AWSMSKRoot -file ~/root.pem -keystore ~/truststore.jks
   chmod 600 ~/truststore.jks
   ```
3. **Distribute Trust Store:**
   - Provide the `truststore.jks` file and its password to your Kafka clients.

4. **Some commands**
```
keytool -list -keystore ~/truststore.jks
keytool -list -v -keystore ~/truststore.jks -alias AWSMSKRoot
```
---

## **Step 5: Testing and Validation**

1. **Test Kafka Producer:**
   Use a Kafka producer with the SASL SCRAM configuration to send messages to a topic:
   ```bash
   export BS_SERVER="b-2.agcluster3.dfkesh.c13.kafka.us-east-1.amazonaws.com:9092,b-1.agcluster3.dfkesh.c13.kafka.us-east-1.amazonaws.com:9092"
   ```

   ```bash
   kafka-topics.sh --create \
       --bootstrap-server $BS_SERVER \
       --replication-factor 2 \
       --partitions 1 \
       --topic test-topic \
       --command-config ~/kafka-client/kafka-client.properties
   ```

   ```bash
   kafka-topics.sh --bootstrap-server $BS_SERVER --list --command-config ~/kafka-client/kafka-client.properties
   ```

   ```bash
   kafka-console-producer.sh --broker-list $BS_SERVER --topic test-topic \
     --producer.config ~/kafka-client/kafka-client.properties
   ```

2. **Test Kafka Consumer:**
   Use a Kafka consumer to read messages:
   ```bash
   kafka-console-consumer.sh --bootstrap-server $BS_SERVER --topic test-topic \
     --consumer.config ~/kafka-client/kafka-client.properties
   ```

---

## **Step 6: Monitoring and Troubleshooting**

1. **Monitor Logs:**
   - Use Amazon CloudWatch to view MSK logs for authentication errors or connection issues.

2. **Common Issues and Solutions:**
   - **Invalid Credentials:** Ensure the username and password match the secret.
   - **Trust Store Errors:** Verify that the client is using the correct trust store with the ACM certificate.

3. **Update Secrets:**
   - To update credentials, modify the secret in Secrets Manager. Restart the clients after updating.

---

## **Conclusion**

This detailed guide provides a comprehensive approach to setting up SASL SCRAM in AWS MSK, covering both **console steps** and **CLI commands**. It ensures secure communication between Kafka clients and brokers using encrypted and authenticated channels.