#!/bin/bash

# Create a lock file
LOCK_FILE="/tmp/watch.sh.lock"
PID_FILE="/tmp/watch.sh.pid"

# Check if script is already running
if [ -f "$LOCK_FILE" ]; then
    EXISTING_PID=$(cat "$PID_FILE" 2>/dev/null)
    if [ -n "$EXISTING_PID" ] && kill -0 "$EXISTING_PID" 2>/dev/null; then
        echo "watch.sh is already running (PID: $EXISTING_PID)"
        echo "Stopping previous instance..."
        kill "$EXISTING_PID"
        sleep 1
    fi
fi

# Store current PID
echo $$ > "$PID_FILE"
touch "$LOCK_FILE"

# Check if inotifywait is installed
if ! command -v inotifywait >/dev/null 2>&1; then
    echo "Error: inotifywait is not installed. Please install inotify-tools package."
    exit 1
fi

# Check if websocat is installed
if ! command -v websocat >/dev/null 2>&1; then
    echo "Error: websocat is not installed. Please install websocat package."
    exit 1
fi

echo "Starting WebSocket server on port 3001..."
# Start WebSocket server using websocat with logging
websocat -b --text -v tcp-listen:3001 broadcast:mirror: 2>&1 | while read line; do
    if [[ $line == *"New peer"* ]]; then
        echo "Browser connected to WebSocket server"
    elif [[ $line == *"Peer disconnected"* ]]; then
        echo "Browser disconnected from WebSocket server"
    fi
done &
WEBSOCAT_PID=$!

# Cleanup function
cleanup() {
    echo "Cleaning up processes..."
    kill $WEBSOCAT_PID 2>/dev/null
    rm -f "$LOCK_FILE" "$PID_FILE"
    pkill -P $$ 2>/dev/null
    echo "Cleanup complete"
    exit 0
}

# Set up traps for various signals
trap cleanup EXIT SIGINT SIGTERM

echo "Watching for file changes..."
# Watch for file changes
while true; do
    CHANGED_FILE=$(inotifywait -r -e modify,create,delete --exclude '\.git|\.swp' --format '%w%f' .)
    echo "File changed: $CHANGED_FILE"
    echo "Sending reload message to browser..."
    if echo "reload" | websocat --no-close ws://localhost:3001; then
        echo "Reload message sent successfully"
    else
        echo "Failed to send reload message"
    fi
done
