#!/bin/bash

echo "Starting TRON Node with local configuration..."
cd /home/pagcoin/java-tron/java-tron-1.0.0

# Start the TRON node with our local configuration
echo "Starting TRON Full Node..."
java -Xms1024m -Xmx2048m -XX:+UseConcMarkSweepGC -XX:+PrintGCDetails -Xloggc:gc.log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=5 -XX:GCLogFileSize=10M -jar lib/framework-1.0.0.jar -c local_config.conf &

# Store the PID
TRON_PID=$!
echo "TRON Node started with PID: $TRON_PID"

# Wait a bit for the node to initialize
sleep 10

# Check if the node is running and responsive
echo "Checking if TRON node is responsive..."
sleep 5

echo "Checking HTTP API endpoints..."
echo "Full Node API (port 8090): http://localhost:8090"
echo "Solidity Node API (port 8091): http://localhost:8091"
echo "Event Server (port 8092): http://localhost:8092"

# Test the endpoints
echo "Testing Full Node API..."
curl -s -X POST http://localhost:8090/wallet/getnowblock || echo "Full Node not ready yet"

echo ""
echo "TRON Node is starting up..."
echo "You can check the logs in: /home/pagcoin/java-tron/java-tron-1.0.0/logs/"
echo "To stop the node, run: kill $TRON_PID"