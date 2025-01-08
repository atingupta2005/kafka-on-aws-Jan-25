rm -rf ~/kafka-ey-24
cd ~
git clone https://github.com/atingupta2005/kafka-ey-24
cd kafka-ey-24/hands-on-kafka/1-kafka-cli

# look at the documentation again
/usr/local/kafka/bin/kafka-consumer-groups.sh

# describe the consumer group
/usr/local/kafka/bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-first-application

# Dry Run: reset the offsets to the beginning of each partition
/usr/local/kafka/bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group my-first-application --reset-offsets --to-earliest --topic third_topic --dry-run

# execute flag is needed
/usr/local/kafka/bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group my-first-application --reset-offsets --to-earliest --topic third_topic --execute

# describe the consumer group again
/usr/local/kafka/bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-first-application

# consume from where the offsets have been reset
/usr/local/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic third_topic --group my-first-application

# describe the group again
/usr/local/kafka/bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-first-application