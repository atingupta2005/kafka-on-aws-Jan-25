curl -fsSL https://get.docker.com -o install-docker.sh
sudo sh install-docker.sh
sudo usermod -aG docker $USER
exit

mkdir -p ~/.docker/cli-plugins/

curl -SL https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose

chmod +x ~/.docker/cli-plugins/docker-compose

docker compose version


git clone https://github.com/atingupta2005/kafka-stack-docker-compose

# Get public ip address of the cloud vm and update below

cd kafka-stack-docker-compose

cat .env

echo "EXTERNAL_PUBLIC_IP=52.170.103.92" >> .env

cat .env

docker compose -f full-stack-zk-multiple-kafka-multiple-full-stack-ag.yml up -d

Conduktor Platform: 
 - A GUI tool for managing Kafka and its ecosystem.
 - http://<public-ip>:8080

login:
admin@admin.io
admin

ksqlDB Server
- SQL engine for processing Kafka streams and tables
- http://<public-ip>:8088.

ksqlDB UI
- Provides a user interface for querying and monitoring ksqlDB. 
  - http://<public-ip>:18080


Zookeeper 1: Accessible on port 2181. Used for Kafka metadata synchronization. Connect via zookeeper:<public-ip>:2181.
Zookeeper 2: Accessible on port 2182. Secondary Zookeeper instance. Connect via zookeeper:<public-ip>:2182.
Zookeeper 3: Accessible on port 2183. Tertiary Zookeeper instance. Connect via zookeeper:<public-ip>:2183.
Kafka Broker 1: Accessible on port 9092. Public access for Kafka broker 1. Connect via PLAINTEXT://<public-ip>:9092.
Kafka Broker 2: Accessible on port 9093. Public access for Kafka broker 2. Connect via PLAINTEXT://<public-ip>:9093.
Kafka Broker 3: Accessible on port 9094. Public access for Kafka broker 3. Connect via PLAINTEXT://<public-ip>:9094.
Schema Registry: Accessible on port 8081. Used to manage Avro schemas for Kafka producers and consumers. Connect via http://<public-ip>:8081.
Kafka REST Proxy: Accessible on port 8082. Enables REST-based interaction with Kafka topics and messages. Connect via http://<public-ip>:8082.
Kafka Connect: Accessible on port 8083. REST API for managing Kafka Connect tasks and configurations. Connect via http://<public-ip>:8083.
