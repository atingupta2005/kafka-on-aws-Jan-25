FROM confluentinc/ksqldb-server:latest

# Switch to root user to modify file permissions
USER root

# Copy the custom entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Ensure the script is executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose the ksqlDB server port
EXPOSE 8088
