python -m venv venv

source venv/bin/activate

python --version

pip install confluent-kafka

mkdir lambda_function

cd lambda_function

pip install confluent-kafka -t .

wget https://raw.githubusercontent.com/atingupta2005/kafka-on-aws-Jan-25/refs/heads/main/concepts/day-10/lambda_handler.py

zip -r lambda_function.zip .
