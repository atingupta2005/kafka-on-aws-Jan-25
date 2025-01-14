FROM confluentinc/ksqldb-server:latest

# Copy additional debugging tools (optional)
RUN yum update && yum install -y net-tools curl vim

# Copy the custom entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Ensure the script is executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose the ksqlDB server port
EXPOSE 8088
