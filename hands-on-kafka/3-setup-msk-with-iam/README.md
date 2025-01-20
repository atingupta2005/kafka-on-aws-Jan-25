### **Setting Up MSK Cluster with IAM Authentication on a VM Outside AWS Network**

This guide provides detailed steps to set up a Virtual Machine (VM) outside of the AWS network, create an MSK cluster, configure the VM with the necessary software, and enable communication with the MSK cluster using IAM authentication.

---

### **Prerequisites**

- A Linux VM (outside AWS network) with `sudo` privileges.
- AWS account with IAM user access to manage MSK clusters.
- AWS CLI installed and configured (Ottional).
- Kafka and OpenJDK 11 installation on the VM.
- Basic understanding of Kafka, IAM roles, and MSK configuration.

---

### **Step 1: Create a VM Outside of AWS Network**

You can create a VM on any platform (e.g., on-premise, VMware, or a third-party cloud provider). Ensure it is configured with the following:

1. **VM Setup:**
   - Set up the VM with your preferred Linux distribution (Ubuntu 22 or Amazon Linux).
   - Ensure the VM has internet access for downloading necessary packages and configurations.

2. **System Requirements:**
   - Minimum 2 GB RAM, 1 vCPU, and 20 GB disk space.
   - Access to the internet for software installation.

---

### **Step 2: Create MSK Cluster**

1. **Create MSK Cluster:**
   - Log in to the AWS Management Console.
   - Navigate to **Amazon MSK** and create a new cluster.
   - Enable **IAM authentication** and **disable other authentication options**.
   - Disable **plain text encryption**.
   - **Enable TLS/SSL encryption** for secure communication with the MSK cluster.

2. **Enable Public Access for MSK Cluster:**
   - After creating the MSK cluster, edit its configuration to **enable public access**. This allows the VM outside AWS to communicate with the MSK cluster securely.

---

### **Step 3: Create and Attach Policy to IAM User**

1. **Create IAM Policy for MSK Access (Only if required):**
   In AWS IAM, create a policy that grants access to the MSK cluster. Replace `<cluster-arn>` with your actual cluster ARN.
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "kafka:DescribeCluster",
           "kafka:ListTopics",
           "kafka:DescribeTopic",
           "kafka:GetBootstrapBrokers"
         ],
         "Resource": "*"
       }
     ]
   }
   ```

2. **Attach Policy to IAM User (Only if required):**
   - This step is only needed if IAM User don't already have required permissions.
   Attach the policy to the IAM user that will be interacting with the MSK cluster.

3. **Generate Keys for IAM User:**
   - Generate **access keys** for the IAM user for programmatic access to AWS resources.
   - Store the keys securely as they will be used later for authentication.

---

### **Step 4: Install and Configure AWS CLI on the VM**
- Export credentials in the shell:
   ```bash
   export AWS_ACCESS_KEY_ID=<your-access-key-id>
   export AWS_SECRET_ACCESS_KEY=<your-secret-access-key>
   ```

---

### **Step 5: Install OpenJDK 11 and Kafka on the VM**
1. **Install OpenJDK 11 for Amazon Linux:**
```
sudo yum update -y
sudo yum install java-11-amazon-corretto-devel -y
cd ~
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

1. **Install OpenJDK 11 for Ubuntu:**
   On your VM, install OpenJDK 11:

   ```bash
   sudo apt update
   sudo apt install -y openjdk-11-jdk
   java -version
   ```

2. **Install Kafka:**
   Download and install Kafka by following these steps:

   ```bash
   curl -O https://archive.apache.org/dist/kafka/3.6.0/kafka_2.13-3.6.0.tgz
   tar -xvzf kafka_2.13-3.6.0.tgz
   mv kafka_2.13-3.6.0 ~/kafka
   ```

3. **Set classpath for IAM JAR File:**
   To make Kafka accessible from anywhere, modify your `.bashrc` file:

   ```bash
   echo 'export PATH=$PATH:~/kafka/bin' >> ~/.bashrc
   ls ls -al ~/kafka/libs/
   echo 'export CLASSPATH=$CLASSPATH:/home/$USER/kafka/libs/aws-msk-iam-auth.jar' >> ~/.bashrc
   source ~/.bashrc
   ```

4. **Verify Kafka Installation:**
   Check if Kafka is installed properly by running:

   ```bash
   kafka-topics.sh --version
   ```

---

### **Step 6: Configure IAM Authentication for Kafka**

1. **Download IAM Authentication Library:**
   Download the `aws-msk-iam-auth` JAR file:

   ```bash
   mkdir -p ~/kafka/libs
   curl -L -o ~/kafka/libs/aws-msk-iam-auth.jar https://github.com/aws/aws-msk-iam-auth/releases/download/v2.2.0/aws-msk-iam-auth-2.2.0-all.jar
   ls -al ~/kafka/libs/
   ls -al ~/kafka/libs/aws-msk-iam-auth.jar
      ```

2. **Verify JAR File:**
   Ensure that the JAR file contains the IAM client handler:

   ```bash
   jar tf ~/kafka/libs/aws-msk-iam-auth.jar | grep IAMClientCallbackHandler
   ```

3. **Create Kafka Client Properties File:**
   Create a configuration file `client.properties` in your home directory to use IAM authentication:

   ```bash
   nano ~/client.properties
   ```

   Add the following content:

   ```properties
   security.protocol=SASL_SSL
   sasl.mechanism=AWS_MSK_IAM
   sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;
   sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler
   ```

---

### **Step 7: Interact with MSK Cluster**

1. **List Kafka Topics:**
   List the Kafka topics using the `client.properties` file:

   ```bash
   kafka-topics.sh --bootstrap-server $BS_SERVER --list --command-config ~/client.properties
   ```

2. **Create a Kafka Topic:**
   Create a new topic called `test-topic` with replication factor 2 and 1 partition:

   ```bash
   kafka-topics.sh --create \
      --bootstrap-server $BS_SERVER \
      --replication-factor 2 \
      --partitions 1 \
      --topic test-topic \
      --command-config ~/client.properties
   ```

3. **Verify Kafka Topic Creation:**
   List all topics again to verify the `test-topic` was successfully created:

   ```bash
   kafka-topics.sh --bootstrap-server $BS_SERVER --list --command-config ~/client.properties
   ```

---

### **Step 8: Troubleshooting**

1. **Check IAM Policies:**
   Ensure the IAM user has the necessary policies attached and that your access keys are correctly configured.

2. **Check Network Connectivity:**
   Verify that your VM can reach the MSK cluster's bootstrap brokers by testing the network connection using `telnet` or similar tools.

---

### **Conclusion**

You have successfully set up a Linux VM (outside AWS network), configured it to communicate with an MSK cluster using IAM authentication, and tested Kafka topics. The VM is now ready for use with AWS MSK, and you can use it to manage Kafka topics and produce/consume messages.

If you encounter any issues, review the logs and verify your IAM roles, Kafka configurations, and connectivity to the MSK cluster.
