### **Step 1: Update System and Install Dependencies**
```bash
# Update the system
sudo yum update -y

# Install required development tools and libraries
sudo yum groupinstall "Development Tools" -y
sudo yum install -y gcc gcc-c++ make zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel libffi-devel wget tar zip
```

---

### **Step 2: Install Python 3.13**
```bash
# Download and extract Python 3.13 source code
wget https://www.python.org/ftp/python/3.13.0/Python-3.13.0.tgz
tar xvf Python-3.13.0.tgz
cd Python-3.13.0

# Configure and build Python 3.13
./configure --enable-optimizations
make -j $(nproc)
sudo make altinstall

# Verify Python 3.13 installation
python3.13 --version
```

---

### **Step 3: Set Up Lambda Project**
```bash
# Create a clean directory for the Lambda project
mkdir ~/lambda_project
cd ~/lambda_project

# Set up a virtual environment
python3.13 -m venv venv
source venv/bin/activate

# Verify Python version inside the virtual environment
python --version
```

---

### **Step 4: Install `confluent-kafka` and Download Lambda Handler**
```bash
# Install `confluent-kafka` in the project directory
pip install confluent-kafka -t .

# Download the Lambda handler file
wget -O lambda_function.py https://raw.githubusercontent.com/atingupta2005/kafka-on-aws-Jan-25/main/concepts/day-10/lambda_handler.py
```

---

### **Step 5: Package Lambda Function**
```bash
# Create a zip package with dependencies and the Lambda handler
zip -r lambda_function.zip confluent_kafka confluent_kafka-2.8.0.dist-info confluent_kafka.libs lambda_function.py
```

---

### **Step 6: Deploy Lambda Function**
```bash
# Create an S3 bucket (if not already created)
aws s3 mb s3://atin-lambda-deployment-bucket --region us-east-1

# Upload the deployment package to S3
aws s3 cp lambda_function.zip s3://atin-lambda-deployment-bucket/

# Update the Lambda function runtime
aws lambda update-function-configuration \
    --function-name atin-lambda \
    --runtime python3.13

# Update the Lambda function code
aws lambda update-function-code \
    --function-name atin-lambda \
    --s3-bucket atin-lambda-deployment-bucket \
    --s3-key lambda_function.zip
```

---

### **Step 7: Test Lambda Function**
```bash
# Invoke the Lambda function with a test payload
aws lambda invoke \
    --function-name atin-lambda \
    --payload '{}' \
    output.json

# View the output
cat output.json
```

---

### **Clean Up (Optional)**
```bash
# Deactivate the virtual environment
deactivate

# Remove temporary files (e.g., Python source code and build files)
cd ~
rm -rf Python-3.13.0 Python-3.13.0.tgz
```

---

### **Verification**
- Ensure the Lambda function runs successfully with no import errors or missing dependencies.
- Check CloudWatch logs if any errors persist.