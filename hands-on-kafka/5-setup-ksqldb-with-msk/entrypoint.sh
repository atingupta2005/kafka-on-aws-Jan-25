#!/bin/bash

if [ "$DEBUG_MODE" = "true" ]; then
  echo "Debug mode enabled. Starting a bash shell..."
  tail -f /dev/null  # Keeps the container running for debugging
else
  echo "Starting ksqlDB Server..."
  exec /etc/confluent/docker/ksqldb-server  # Correct entrypoint for ksqlDB
fi
