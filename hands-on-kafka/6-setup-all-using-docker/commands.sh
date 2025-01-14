# Load environment variables from .env file
export $(grep -v '^#' .env | xargs)

# Start the environment
docker-compose up -d --build

# Verify running containers
docker ps

# Create a Kafka topic
docker exec -it kafka-broker-1 kafka-topics --bootstrap-server ${CLOUD_VM_PUBLIC_IP}:${KAFKA_BROKER_1_PORT} --create --topic test-topic --partitions 3 --replication-factor 3

# List Kafka topics
docker exec -it kafka-broker-1 kafka-topics --bootstrap-server ${CLOUD_VM_PUBLIC_IP}:${KAFKA_BROKER_1_PORT} --list

# Describe a Kafka topic
docker exec -it kafka-broker-1 kafka-topics --bootstrap-server ${CLOUD_VM_PUBLIC_IP}:${KAFKA_BROKER_1_PORT} --describe --topic test-topic

# Access ksqlDB CLI
docker exec -it ksqldb-server ksql http://localhost:${KSQLDB_SERVER_PORT}

# List topics in ksqlDB CLI
SHOW TOPICS;

# Create a stream in ksqlDB
CREATE STREAM test_stream (id STRING, name STRING) WITH (KAFKA_TOPIC='test-topic', VALUE_FORMAT='JSON');

# List streams in ksqlDB
SHOW STREAMS;

# Query the stream in real-time (ksqlDB CLI)
SELECT * FROM test_stream EMIT CHANGES;

# View Zookeeper logs
docker logs zookeeper

# View Kafka Broker logs
docker logs kafka-broker-1
docker logs kafka-broker-2
docker logs kafka-broker-3

# View ksqlDB Server logs
docker logs ksqldb-server

# View ksqlDB UI logs
docker logs ksqldb-ui

# Stop the environment
docker-compose down

# Remove volumes (optional)
docker-compose down -v
