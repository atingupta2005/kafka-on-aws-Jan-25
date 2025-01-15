### Apache Kafka – Producer Retries and `max.in.flight.requests.per.connection`

In Apache Kafka, producers handle data writing to topic partitions. Kafka automatically determines the target broker and partition for each message and recovers from broker failures, ensuring resilience and reliability. This capability is a key factor behind Kafka’s popularity.

In this discussion, we focus on two critical producer settings: **Producer Retries** and **`max.in.flight.requests.per.connection`**.

---

#### **Producer Retries**

Transient failures, such as the `NotEnoughReplicas` exception, require special handling to avoid data loss. Developers must handle such exceptions in the producer's callback, or the message will be lost.

##### **Understanding `NotEnoughReplicas` Exception**

Kafka producers offer three acknowledgment modes:
- **`acks=0`**: Potential for data loss.
- **`acks=1`**: Limited data loss.
- **`acks=all`**: No data loss, ensuring maximum safety when paired with `min.insync.replicas`.

The `min.insync.replicas` setting determines the minimum number of in-sync replicas (including the leader) required to acknowledge a write. For instance:
- **`min.insync.replicas=2`**: At least two brokers must confirm the data write.
- Combined with **`acks=all`** and **`replication.factor=3`**, one broker can fail without causing data write errors.

If fewer brokers are available than specified by `min.insync.replicas`, the producer receives a `NotEnoughReplicas` exception. It is then the producer's responsibility to retry sending the data until the write succeeds.

---

#### **Retries Setting**

The `retries` configuration allows producers to automatically retry sending messages in case of failures. By default, `retries=0`, meaning no retries. Setting it to a high value, such as `Integer.MAX_VALUE`, enables indefinite retries until success. However, retries may lead to **message reordering**, particularly for key-based ordering.

To mitigate this, another setting, `max.in.flight.requests.per.connection`, is used.

---

#### **`max.in.flight.requests.per.connection`**

This setting controls how many requests can be sent concurrently to a single partition. The default value is **5**, which may result in out-of-order messages. To maintain strict ordering, set **`max.in.flight.requests.per.connection=1`**. However, this might slightly impact throughput.

For Kafka versions 0.11 and later, the **Idempotent Producer** provides a better alternative to ensure message ordering and avoid duplicates, even with retries.

---

### Summary

To maximize reliability:
- Use **`acks=all`** and configure **`min.insync.replicas`** for data safety.
- Increase **`retries`** to handle transient failures.
- Set **`max.in.flight.requests.per.connection=1`** for strict ordering, or use an **Idempotent Producer** for modern Kafka setups.

By combining these settings, Kafka producers can achieve high availability, safety, and consistency.