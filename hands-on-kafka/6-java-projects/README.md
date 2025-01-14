# How to setup on Windows
```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

```
choco install intellijidea-community -y
choco install oraclejdk -y
choco install git -y
```

```
exit
```


```
git clone https://github.com/atingupta2005/kafka-ey-24
```

```
exit
```

---

# How to setup on ubuntu
Here’s a step-by-step guide for setting up and running the project in **Ubuntu**:

---

### **1. Install Java**
1. **Update the package list:**
   ```bash
   sudo apt update
   ```
2. **Install OpenJDK 11 or later:**
   ```bash
   sudo apt install openjdk-11-jdk -y
   ```
3. **Verify the installation:**
   ```bash
   java -version
   ```
   You should see a version like `openjdk version "11.x.x"`.

---

### **2. Set the IP Address via Environment Variable**
You can configure the Kafka broker IP address as an environment variable and retrieve it in your code:

1. **Export the environment variable:**
   ```bash
   export KAFKA_BROKER_IP="your.kafka.broker.ip:9092"
   ```

2. Save and recompile the project when changes are made.

---

### **3. Download Dependencies**
Use the Gradle wrapper to resolve dependencies and build the project:

1. **Navigate to the project root:**
   ```bash
   cd kafka-java
   ```

2. **Grant execute permission to `gradlew`:**
   ```bash
   chmod +x gradlew
   ```

3. **Build the project:**
   ```bash
   ./gradlew build
   ```

---

### **4. Run the Code**
Run the `ProducerDemo` class:

1. Navigate to the `kafka-basics` module:
   ```bash
   cd kafka-basics
   ```

2. Execute the `ProducerDemo` class:
   ```bash
   ../gradlew run --args='ProducerDemo'
   ```
---

### **5. Verify Output**
- If the code runs successfully, you’ll see log output indicating that the producer sent the message.
- Use Kafka tools (e.g., `kafka-console-consumer.sh`) to check the `demo_java` topic for the sent message.

Let me know if you encounter any issues!