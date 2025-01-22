# 1. Connect to your Amazon Linux EC2 instance

# 2. Update the system and install required tools
sudo yum update -y
sudo yum install -y python3 python3-pip python3-devel gcc gcc-c++ wget zip

# 3. Create a clean working directory
mkdir lambda_project
cd lambda_project

# 4. Create a virtual environment (optional but recommended for isolation)
python3 -m venv venv
source venv/bin/activate

# 5. Install the `confluent-kafka` library into the current directory
pip install confluent-kafka -t .

# 6. Verify the `confluent_kafka` directory is present
ls
# Expected output: confluent_kafka/ confluent_kafka-<version>.dist-info/ ...

# 7. Add the Lambda handler file
wget -O lambda_function.py https://raw.githubusercontent.com/atingupta2005/kafka-on-aws-Jan-25/main/concepts/day-10/lambda_handler.py

# 8. Package everything into a zip file
zip -r lambda_function.zip * -x "venv/*"

# 9. Verify the zip file contents
unzip -l lambda_function.zip
# Expected output:
# confluent_kafka/
# confluent_kafka-<version>.dist-info/
# lambda_function.py

# 10. Upload the zip file to S3
aws s3 mb s3://<your-bucket-name> --region us-east-1
aws s3 cp lambda_function.zip s3://<your-bucket-name>/

# 11. Deploy the Lambda function
aws lambda update-function-code \
    --function-name <your-function-name> \
    --s3-bucket <your-bucket-name> \
    --s3-key lambda_function.zip

# 12. Set the Lambda handler
# In AWS Lambda Console, set the handler to:
# lambda_function.lambda_handler
