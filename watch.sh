#!/bin/bash

# Check if inotifywait is installed
if ! command -v inotifywait >/dev/null 2>&1; then
    echo "Error: inotifywait is not installed. Please install inotify-tools package."
    exit 1
fi

# Start WebSocket server using socat
socat TCP-LISTEN:3001,fork,reuseaddr SYSTEM:"echo -e 'HTTP/1.1 101 Web Socket Protocol Handshake\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: dummy\r\n\r\n'; cat" &
SOCAT_PID=$!

# Cleanup on script exit
cleanup() {
    kill $SOCAT_PID
    exit 0
}
trap cleanup EXIT

# Watch for file changes
while true; do
    inotifywait -r -e modify,create,delete --exclude '\.git|\.swp' .
    # Send a message through all active WebSocket connections
    for conn in /proc/$SOCAT_PID/fd/*; do
        if [ -e "$conn" ]; then
            printf '\x81\x05Hello' > $conn 2>/dev/null
        fi
    done
done
