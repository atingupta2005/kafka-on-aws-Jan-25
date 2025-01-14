FROM confluentinc/ksqldb-server:latest

# Switch to root user to modify file permissions
USER root

# Copy the custom entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Ensure the script is executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch back to the default non-root user
USER appuser

# Expose the ksqlDB server port
EXPOSE 8088

# Use the custom entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
