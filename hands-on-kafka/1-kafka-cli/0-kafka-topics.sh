rm -rf ~/kafka-ey-24
cd ~
git clone https://github.com/atingupta2005/kafka-ey-24
cd kafka-ey-24/hands-on-kafka/1-kafka-cli

/usr/local/kafka/bin/kafka-topics.sh 

/usr/local/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --list 

/usr/local/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --topic first_topic --create

/usr/local/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --topic second_topic --create --partitions 3

/usr/local/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --topic third_topic --create --partitions 3 --replication-factor 2

# Create a topic (working)
/usr/local/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --topic third_topic --create --partitions 3 --replication-factor 1

# List topics
/usr/local/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --list 

# Describe a topic
/usr/local/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --topic first_topic --describe

# Delete a topic 
/usr/local/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --topic first_topic --delete
# (only works if delete.topic.enable=true)
