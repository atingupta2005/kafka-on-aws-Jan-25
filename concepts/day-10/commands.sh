# 1. Create a clean working directory for your Lambda project
mkdir lambda_project
cd lambda_project

# 2. Create a virtual environment (for isolating dependencies)
python -m venv venv

# 3. Activate the virtual environment
source venv/bin/activate  # For Linux/Mac
# For Windows:
# venv\Scripts\activate

# 4. Verify the Python version (ensure it matches the Lambda runtime, e.g., Python 3.8 or 3.9)
python --version

# 5. Install the `confluent-kafka` library into the virtual environment (local testing)
pip install confluent-kafka

# 6. Create a `python` directory (Lambda-compatible dependency structure)
mkdir python

# 7. Install `confluent-kafka` into the `python` directory (for Lambda packaging)
pip install confluent-kafka -t python

# 8. Download the Lambda handler file into the project directory
wget -O lambda_function.py https://raw.githubusercontent.com/atingupta2005/kafka-on-aws-Jan-25/main/concepts/day-10/lambda_handler.py

# 9. Package the dependencies and Lambda handler into a zip file
zip -r lambda_function.zip python lambda_function.py

# 10. Deactivate the virtual environment (optional but recommended)
deactivate
