Create a vm out of aws network

Create MSK Cluster: Enable only IAM and disable everything else. Also disable plain text encryption. Only enable TSL/SSL

Edit MSK Cluster and enable public access

Create Policy

Attach policy to user

Generate keys of the user

cd ~

sudo apt update
sudo apt install zip unzip tree -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws --version

aws configure

export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=

sudo apt update
sudo apt install -y openjdk-11-jdk
java -version

curl -O https://archive.apache.org/dist/kafka/3.6.0/kafka_2.13-3.6.0.tgz
tar -xvzf kafka_2.13-3.6.0.tgz
mv kafka_2.13-3.6.0 ~/kafka

cat ~/.bashrc
echo 'export PATH=$PATH:~/kafka/bin' >> ~/.bashrc
echo $USER
echo $PATH
echo $CLASSPATH
echo 'export CLASSPATH=$CLASSPATH:/home/ec2-user/kafka/libs/aws-msk-iam-auth.jar' >> ~/.bashrc
cat ~/.bashrc
source ~/.bashrc
echo $PATH
echo $CLASSPATH

kafka-topics.sh --version

cd ~
ls ~/kafka/libs/a*
curl -L -o ~/kafka/libs/aws-msk-iam-auth.jar https://github.com/aws/aws-msk-iam-auth/releases/download/v2.2.0/aws-msk-iam-auth-2.2.0-all.jar

jar tf ~/kafka/libs/aws-msk-iam-auth.jar | grep IAMClientCallbackHandler

nano ~/client.properties

security.protocol=SASL_SSL
sasl.mechanism=AWS_MSK_IAM
sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;
sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler


aws kafka list-clusters

aws kafka describe-cluster --cluster-arn <cluster-arn>

aws kafka get-bootstrap-brokers --cluster-arn <cluster-arn>

export BS_SERVER=""

kafka-topics.sh --bootstrap-server $BS_SERVER --list --command-config ~/client.properties


kafka-topics.sh --create \
   --bootstrap-server $BS_SERVER \
   --replication-factor 2 \
   --partitions 1 \
   --topic test-topic \
   --command-config ~/client.properties

kafka-topics.sh --bootstrap-server $BS_SERVER --list --command-config ~/client.properties

