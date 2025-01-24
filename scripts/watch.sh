#!/usr/bin/env bash

set -e  # Exit on error

# Configuration
PIPE="/tmp/livereload_pipe"
PORT=3001
LOCKFILE="/tmp/livereload.lock"
LOGFILE="/tmp/livereload.log"
LAST_FILE="/tmp/livereload_last_file"

# Ensure only one instance runs
if [ -f "$LOCKFILE" ]; then
    pid=$(cat "$LOCKFILE")
    if ps -p "$pid" > /dev/null 2>&1; then
        echo "Live reload server is already running (PID: $pid)"
        exit 1
    fi
    # Clean up stale lock file
    rm -f "$LOCKFILE"
fi

# Create lock file
echo $$ > "$LOCKFILE"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}

# Cleanup function
cleanup() {
    log "Shutting down live reload server..."
    rm -f "$PIPE" "$LOCKFILE" "$LAST_FILE"
    kill $(jobs -p) 2>/dev/null || true
    exit 0
}

# Error handler
error() {
    log "Error on line $1"
    cleanup
}

# Set up error handling
trap 'error $LINENO' ERR
trap cleanup EXIT INT TERM

# Create named pipe if it doesn't exist
if [[ ! -p "$PIPE" ]]; then
    mkfifo "$PIPE"
fi

log "Starting live reload server on port $PORT"

# Start SSE server
(
    # Only allow 5 connection attempts per second
    while sleep 0.2; do
        {
            # Send initial SSE headers
            echo -e "HTTP/1.1 200 OK\r"
            echo -e "Content-Type: text/event-stream\r"
            echo -e "Cache-Control: no-cache\r"
            echo -e "Connection: keep-alive\r"
            echo -e "Access-Control-Allow-Origin: *\r\n"
            
            # Keep reading from pipe
            while true; do
                if read line < "$PIPE"; then
                    echo "data: $line"
                    echo ""
                fi
            done
        } | nc -k -l 127.0.0.1 "$PORT"
    done
) &

server_pid=$!
log "Server process started (PID: $server_pid)"

# Watch for file changes
log "Starting file watcher for ./app directory"
fswatch --event Created --event Updated --event Removed -o ./app | while read -r filepath event_type; do
    if [[ ! -f "$LOCKFILE" ]]; then
        log "Lock file missing, shutting down..."
        break
    fi
    
    # Extract filename from path
    filename=$(basename "$filepath")
    
    # Check if this file was just handled
    if [[ -f "$LAST_FILE" ]]; then
        last_handled=$(cat "$LAST_FILE")
        if [[ "$filename" == "$last_handled" ]]; then
            continue
        fi
    fi
    
    # Update last handled file
    echo "$filename" > "$LAST_FILE"
    
    log "File $event_type: $filename"
    echo "reload" > "$PIPE"
    
    # Wait briefly then clear the last file
    sleep 0.1
    rm -f "$LAST_FILE"
done &

watcher_pid=$!
log "File watcher process started (PID: $watcher_pid)"

# Keep script running and handle signals
while true; do
    # Check if processes are still running
    if ! kill -0 $server_pid 2>/dev/null || ! kill -0 $watcher_pid 2>/dev/null; then
        log "A required process has died, shutting down..."
        cleanup
    fi
    sleep 1
done
