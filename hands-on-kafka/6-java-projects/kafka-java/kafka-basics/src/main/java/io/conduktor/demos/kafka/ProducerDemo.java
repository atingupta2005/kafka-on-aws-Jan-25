package io.conduktor.demos.kafka;

import org.apache.kafka.clients.admin.AdminClient;
import org.apache.kafka.clients.admin.NewTopic;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Collections;
import java.util.Properties;
import java.util.concurrent.ExecutionException;
import io.github.cdimascio.dotenv.Dotenv;

public class ProducerDemo {

    private static final Logger log = LoggerFactory.getLogger(ProducerDemo.class.getSimpleName());
    private static final String TOPIC_NAME = "demo_java";

    public static void main(String[] args) {
        log.info("I am a Kafka Producer!");

        // Load environment variables
        Dotenv dotenv = Dotenv.configure().directory("./").load();
        String bootstrapServers = dotenv.get("KAFKA_BROKER_IP");
        if (bootstrapServers == null || bootstrapServers.isEmpty()) {
            log.error("KAFKA_BROKER_IP is not set or empty in the .env file!");
            throw new RuntimeException("KAFKA_BROKER_IP is not set in the .env file");
        }

        // Create Producer Properties
        Properties properties = new Properties();
        properties.setProperty("bootstrap.servers", bootstrapServers);
        properties.setProperty("key.serializer", StringSerializer.class.getName());
        properties.setProperty("value.serializer", StringSerializer.class.getName());
        properties.setProperty("acks", "all");

        // Create the Topic if it doesn't exist
        createTopic(bootstrapServers, TOPIC_NAME);

        // Create the Producer
        KafkaProducer<String, String> producer = new KafkaProducer<>(properties);

        // Create a Producer Record
        ProducerRecord<String, String> producerRecord =
                new ProducerRecord<>(TOPIC_NAME, "hello world");

        // Send the data
        producer.send(producerRecord, (metadata, exception) -> {
            if (exception == null) {
                log.info("Message sent successfully: " +
                        "Topic = " + metadata.topic() +
                        ", Partition = " + metadata.partition() +
                        ", Offset = " + metadata.offset());
            } else {
                log.error("Error while producing message", exception);
            }
        });

        // Flush and close the producer
        producer.flush();
        producer.close();
    }

    private static void createTopic(String bootstrapServers, String topicName) {
        // AdminClient properties
        Properties adminProperties = new Properties();
        adminProperties.setProperty("bootstrap.servers", bootstrapServers);

        // Create AdminClient
        try (AdminClient adminClient = AdminClient.create(adminProperties)) {
            // Define the topic to be created
            NewTopic topic = new NewTopic(topicName, 1, (short) 3); // 1 partition, replication factor of 3

            // Create the topic if it doesn't exist
            adminClient.createTopics(Collections.singletonList(topic))
                       .all()
                       .get();
            log.info("Topic '{}' created successfully.", topicName);
        } catch (ExecutionException e) {
            if (e.getCause() instanceof org.apache.kafka.common.errors.TopicExistsException) {
                log.info("Topic '{}' already exists.", topicName);
            } else {
                log.error("Error while creating topic '{}': ", topicName, e);
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            log.error("Thread interrupted while creating topic '{}': ", topicName, e);
        }
    }
}
