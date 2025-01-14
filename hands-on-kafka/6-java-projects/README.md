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
   sudo yum update
   ```
2. **Install OpenJDK 11 or later:**
   ```bash
   sudo apt install openjdk-11-jdk -y
   sudo yum install java-11-amazon-corretto -y
   sudo alternatives --config java
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
   nano .env
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
   ../gradlew run -PmainClass=io.conduktor.demos.kafka.ProducerDemo
   ```

```bash
../gradlew run -PmainClass=io.conduktor.demos.kafka.ProducerDemoWithCallback
../gradlew run -PmainClass=io.conduktor.demos.kafka.ProducerDemoKeys
../gradlew run -PmainClass=io.conduktor.demos.kafka.ConsumerDemo
../gradlew run -PmainClass=io.conduktor.demos.kafka.ConsumerDemoWithShutdown
../gradlew run -PmainClass=io.conduktor.demos.kafka.ConsumerDemoCooperative
```


---
