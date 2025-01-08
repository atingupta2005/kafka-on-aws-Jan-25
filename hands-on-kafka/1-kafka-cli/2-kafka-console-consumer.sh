rm -rf ~/kafka-ey-24
cd ~
git clone https://github.com/atingupta2005/kafka-ey-24
cd kafka-ey-24/hands-on-kafka/1-kafka-cli

# create a topic with 3 partitions
/usr/local/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --topic second_topic --create --partitions 3

# consuming
/usr/local/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic second_topic

# other terminal
/usr/local/kafka/bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --producer-property partitioner.class=org.apache.kafka.clients.producer.RoundRobinPartitioner --topic second_topic

# consuming from beginning
/usr/local/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic second_topic --from-beginning

# display key, values and timestamp in consumer
/usr/local/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic second_topic --formatter kafka.tools.DefaultMessageFormatter --property print.timestamp=true --property print.key=true --property print.value=true --property print.partition=true --from-beginning