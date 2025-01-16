**Kafka Streams in Action: Hands-On Exercise**

---

### **1. Objective**
This hands-on exercise guides participants in building a stream processing application using Kafka Streams on AWS MSK. The goal is to process, transform, and analyze real-time data streams, culminating in actionable insights.

---

### **2. Prerequisites**
- An AWS MSK cluster with topics set up.
- Familiarity with Kafka Streams concepts (e.g., streams, tables, state stores).
- Access to a development environment with Kafka Streams libraries (e.g., Java).

---

### **3. Problem Statement**
A social media platform needs to analyze hashtags in real-time to identify trending topics. This involves:
1. Ingesting posts containing hashtags.
2. Counting occurrences of each hashtag within a time window.
3. Outputting the top trending hashtags to a Kafka topic.

---

### **4. Solution Design**

#### **4.1 Data Flow**
1. **Input Topic:**
   - Kafka topic (e.g., `posts-topic`) containing user-generated content.
   - Sample message structure:
     ```json
     {
       "postId": "post123",
       "content": "#KafkaStreams is awesome! #RealTime"
     }
     ```

2. **Processing Logic:**
   - Extract hashtags from the `content` field.
   - Count occurrences of each hashtag over a sliding time window (e.g., 1 minute).

3. **Output Topic:**
   - Kafka topic (e.g., `trending-hashtags-topic`) containing trending hashtags and their counts.
   - Sample message structure:
     ```json
     {
       "hashtag": "#KafkaStreams",
       "count": 150,
       "windowStart": 1678901200000,
       "windowEnd": 1678901260000
     }
     ```

#### **4.2 Processing Framework**
- Use Kafka Streams to:
  - Consume data from `posts-topic`.
  - Extract and process hashtags.
  - Aggregate counts over a sliding time window.
  - Publish results to `trending-hashtags-topic`.

---

### **5. Implementation Steps**

#### **5.1 Kafka Streams Application Code**
```java
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.kstream.*;

import java.time.Duration;
import java.util.Arrays;
import java.util.Properties;

public class TrendingHashtagsApp {

    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(StreamsConfig.APPLICATION_ID_CONFIG, "trending-hashtags-app");
        props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "<MSK-Broker-Endpoint>");
        props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass());
        props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass());

        StreamsBuilder builder = new StreamsBuilder();

        // Step 1: Consume posts from the input topic
        KStream<String, String> posts = builder.stream("posts-topic",
                Consumed.with(Serdes.String(), Serdes.String()));

        // Step 2: Extract hashtags and flatten the stream
        KStream<String, String> hashtags = posts.flatMapValues(content ->
                Arrays.asList(content.split(" "))
                        .stream()
                        .filter(word -> word.startsWith("#"))
                        .toList()
        );

        // Step 3: Group hashtags and count occurrences within a sliding window
        KTable<Windowed<String>, Long> hashtagCounts = hashtags
                .groupBy((key, hashtag) -> hashtag, Grouped.with(Serdes.String(), Serdes.String()))
                .windowedBy(SlidingWindows.ofTimeDifferenceAndGrace(Duration.ofMinutes(1), Duration.ofSeconds(30)))
                .count(Materialized.with(Serdes.String(), Serdes.Long()));

        // Step 4: Write trending hashtags to the output topic
        hashtagCounts.toStream()
                .map((windowedKey, count) -> KeyValue.pair(windowedKey.key(), count))
                .to("trending-hashtags-topic", Produced.with(Serdes.String(), Serdes.Long()));

        KafkaStreams streams = new KafkaStreams(builder.build(), props);
        streams.start();

        Runtime.getRuntime().addShutdownHook(new Thread(streams::close));
    }
}
```

#### **5.2 Deploy and Run**
1. **Create Kafka Topics:**
   - Create `posts-topic` and `trending-hashtags-topic` in the AWS MSK cluster.

2. **Deploy the Application:**
   - Package the application and deploy it in an environment with access to the MSK cluster.

3. **Send Sample Data:**
   - Produce posts to `posts-topic` using a producer script or Kafka CLI.

4. **Monitor Results:**
   - Consume messages from `trending-hashtags-topic` to verify trending hashtag counts.

---

### **6. Exercise Validation**
1. **Verify Data Processing:**
   - Ensure hashtags are correctly extracted and aggregated from incoming posts.

2. **Monitor Outputs:**
   - Validate that trending hashtags and counts are published to `trending-hashtags-topic`.

3. **Handle Failures:**
   - Simulate application restarts and verify that stateful operations are fault-tolerant using changelog topics.

---

### **7. Best Practices**
1. **Optimize Sliding Windows:**
   - Adjust the window size and grace period to balance accuracy and resource usage.
2. **Monitor Performance:**
   - Use AWS CloudWatch to monitor Kafka Streams application performance.
3. **Ensure Fault Tolerance:**
   - Verify that changelog topics have sufficient replication for recovery.
4. **Partition Input Topics:**
   - Ensure `posts-topic` is partitioned appropriately to distribute the workload.

