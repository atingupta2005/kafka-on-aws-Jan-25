### Kafka Integration with AWS Services Using AWS CLI

#### **Introduction**
Apache Kafka’s robust event streaming capabilities can be seamlessly integrated with AWS Managed Streaming for Apache Kafka (MSK) and other AWS services to create scalable, secure, and efficient data pipelines. This document outlines how to use AWS MSK Connect, an integral part of AWS MSK, to stream data to Amazon S3 and trigger AWS Lambda for real-time processing, using AWS CLI for automation.

---

### **Using AWS MSK Connect to Stream Data to Amazon S3**

##### **Overview**
AWS MSK Connect simplifies integrating Kafka with external systems using connectors. By leveraging the **S3 Sink Connector**, data from Kafka topics can be reliably stored in Amazon S3 buckets, enabling downstream analytics or long-term archiving.

##### **Steps to Stream Data to Amazon S3**

1. **Set Up the S3 Bucket**

   Use the following commands to create and configure an S3 bucket:

   ```bash
   # Variables
   BUCKET_NAME="msks3agbktjan25"
   REGION="ap-southeast-2"

   # Create an S3 bucket
   aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION \
     --create-bucket-configuration LocationConstraint=$REGION
   
   # Verify the bucket creation
   aws s3 ls
   ```

2. **Create an IAM Role for MSK Connect**
    - ROLE_NAME: KafkaConnectS3
    - Chose Custom trust relationship and take content from file - trust-relationship.json

   # Attach the policies: AdministratorAccess, AmazonMSKFullAccess, AmazonS3FullAccess

   # Get the role ARN

3. **Create an MSK Connect S3 Sink Connector**
  - Create Endpoint (Gateway) and chose s3 (com.amazonaws.us-east-1.s3) and select all subnets and also select the routes (Very important)

   - Upload the `confluentinc-kafka-connect-s3-10.5.19.zip` file to an S3 bucket.
      - Download from: https://www.confluent.io/hub/confluentinc/kafka-connect-s3
   - Navigate to **MSK Connect** in the AWS Console.
   - Select **Custom Plugins** and upload the plugin JAR file.
   - Create a new custom plugin from the uploaded file.
   - After the plugin is created, choose **Create Connector** and select the uploaded custom plugin.
   - Make sure to create Cloudwatch log group and enable cloud watch logs in connector
   - Enter the following connector properties:
      - Make sure to update the bucket name, region and name to be the name of connector

   ```properties
    name=msk-connect-s3-connector
    topics=raw_logs
    s3.region=us-east-1
    s3.bucket.name=msks3connectorag
    connector.class=io.confluent.connect.s3.S3SinkConnector
    format.class=io.confluent.connect.s3.format.json.JsonFormat
    flush.size=1
    schema.compatibility=NONE
    tasks.max=1
    s3.part.size=5242880
    partitioner.class=io.confluent.connect.storage.partitioner.DefaultPartitioner
    storage.class=io.confluent.connect.s3.storage.S3Storage
    topics.dir=kafkatraining
    log4j.logger.org.apache.kafka.connect=DEBUG
    log4j.logger.com.amazonaws=DEBUG
    connect.s3.httpclient.request.timeout.ms=10000
    connect.s3.httpclient.connection.timeout.ms=10000
    behavior.on.null.values=ignore
   ```

   - Assign the `KafkaConnectS3` IAM role (created earlier) to the connector.

4. **Monitor and Validate the Integration**

   Verify that data is being written to the S3 bucket
---

### **Triggering AWS Lambda from AWS MSK to Process Real-Time Data**

##### **Overview**
AWS Lambda can process data from AWS MSK in real time, enabling event-driven architectures. This is ideal for use cases such as data enrichment, anomaly detection, or microservices.

##### **Steps to Trigger Lambda Using AWS Console**

1. **Set Up an AWS Lambda Function**
   - Go to the **Lambda Console**.
   - Click **Create Function**.
   - Choose **Author from scratch**.
   - Provide a function name (e.g., `KafkaProcessingLambda`).
   - Select the **Runtime** (e.g., Python 3.x).
   - Create a new or use an existing **Execution Role** with the necessary permissions:
     - Attach the `AWSLambdaBasicExecutionRole` policy.
   - Click **Create Function**.

2. **Write the Lambda Function Code**
   - Use the inline editor to add the following code:
     ```python
     import json

     def lambda_handler(event, context):
         for record in event['records']:
             payload = json.loads(record['value'])
             print(f"Processing record: {payload}")
     ```
   - Deploy the changes.

3. Edit the role created and add policy - MSKPolicy

4. **Set Up an Event Source Mapping**
   - Go to the Lambda function page.
   - Click **Add Trigger**.
   - Select **MSK** as the source.
   - Configure the MSK cluster:
     - Provide the **MSK Cluster ARN**.
     - Specify the Kafka topic name (e.g., `ag-topic1`).
     - Set the **Batch Size** (e.g., `100`).
   - Click **Add** to complete the trigger setup.

5. **Test the Integration**
   - Produce events to the Kafka topic using your producer application.
   - Verify the Lambda function’s execution by checking its **CloudWatch Logs**:
     - Navigate to **CloudWatch Console** > **Log Groups**.
     - Look for logs related to your Lambda function.

---


Here are the steps to create **Interface Endpoints** in your VPC:

### Steps to Create Interface Endpoints:

1. **Go to VPC Console**:
   - Open the **Amazon VPC console**.

2. **Create Lambda Interface Endpoint**:
   - In the VPC console, go to **Endpoints**.
   - Click **Create Endpoint**.
   - For **Service category**, select **AWS services**.
   - Search for **com.amazonaws.us-east-1.lambda** (replace `us-east-1` with your region).
   - Choose **Interface** for **Type**.
   - Select the **VPC** and **subnets** where Lambda runs.
   - Enable **Private DNS** if required.
   - Click **Create Endpoint**.

3. **Create STS Interface Endpoint**:
   - Repeat the above steps, but search for **com.amazonaws.us-east-1.sts**.

5. **Verify**:
   - Ensure the endpoints are created and properly associated with the correct subnets in your VPC.

This will ensure Lambda can access the necessary services privately within your VPC.