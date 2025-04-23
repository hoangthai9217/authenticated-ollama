#!/bin/bash

# Define log file - changing to a macOS appropriate location
LOG_FILE="$HOME/Library/Logs/service_monitor.log"

# Source user profile to apply any needed environment variables
source "$HOME/.zshrc" 2>/dev/null || source "$HOME/.bash_profile" 2>/dev/null || source "$HOME/.bashrc" 2>/dev/null

# Create log directory for Caddy with appropriate permissions for macOS
mkdir -p "$HOME/Library/Logs/caddy"
# Using user/group instead of caddy-specific ones since macOS doesn't use the same user scheme
chown $(whoami):staff "$HOME/Library/Logs/caddy"

echo "Starting all services..." >> "$LOG_FILE"

# Function to check if a process is running on a specific port
is_port_in_use() {
    lsof -i:$1 >/dev/null 2>&1
    return $?
}

# Check if Ollama is already running (listens on port 11434)
if is_port_in_use 11434; then
    echo "$(date): Ollama is already running on port 11434, using existing instance" >> "$LOG_FILE"
    # Get the PID of the process using port 11434
    OLLAMA_PID=$(lsof -ti:11434)
    echo "$(date): Using existing Ollama with PID $OLLAMA_PID" >> "$LOG_FILE"
else
    # Start Ollama in the background
    ollama serve &
    OLLAMA_PID=$!
    echo "$(date): Started Ollama with PID $OLLAMA_PID" >> "$LOG_FILE"
fi

# Start Caddy in the background (using a more macOS-appropriate config path)
CADDY_CONFIG="$HOME/Caddy/Caddyfile"
caddy run --config "$CADDY_CONFIG" &
CADDY_PID=$!
echo "$(date): Started Caddy with PID $CADDY_PID" >> "$LOG_FILE"

# Start Uvicorn with FastAPI app
/opt/anaconda3/envs/llms/bin/uvicorn app.main:app --host 0.0.0.0 --port 9090 &
UVICORN_PID=$!
echo "$(date): Started Uvicorn with PID $UVICORN_PID" >> "$LOG_FILE"

# Function to check process status
check_process() {
    if ! wait $1 2>/dev/null; then
        STATUS=$?
        echo "$(date): Process $2 ($1) has exited with status $STATUS" >> "$LOG_FILE"
        return $STATUS
    fi
}

# Handle shutdown signals - using SIGTERM and SIGINT which are supported on macOS
trap "echo 'Received shutdown signal, stopping all services...' >> $LOG_FILE; kill $OLLAMA_PID $CADDY_PID $UVICORN_PID; exit 0" SIGTERM SIGINT

# Wait for all services to start and monitor them
# Using `ps -p` with macOS-appropriate format
while true; do
    if ! ps -p $OLLAMA_PID > /dev/null 2>&1; then
        echo "$(date): Ollama service is not running, checking if another instance is running" >> "$LOG_FILE"
        # Check if another Ollama process has taken over the port
        if is_port_in_use 11434; then
            OLLAMA_PID=$(lsof -ti:11434)
            echo "$(date): Another Ollama instance is running with PID $OLLAMA_PID, using it" >> "$LOG_FILE"
        else
            # Only start Ollama if no other instance is running on port 11434
            echo "$(date): No Ollama instance found, starting new one" >> "$LOG_FILE"
            ollama serve &
            OLLAMA_PID=$!
            echo "$(date): Started new Ollama with PID $OLLAMA_PID" >> "$LOG_FILE"
        fi
    fi
    
    if ! ps -p $CADDY_PID > /dev/null 2>&1; then
        echo "$(date): Caddy service is not running, restarting" >> "$LOG_FILE"
        caddy run --config "$CADDY_CONFIG" &
        CADDY_PID=$!
        echo "$(date): Restarted Caddy with PID $CADDY_PID" >> "$LOG_FILE"
    fi
    
    if ! ps -p $UVICORN_PID > /dev/null 2>&1; then
        echo "$(date): Uvicorn service is not running, restarting" >> "$LOG_FILE"
        /opt/anaconda3/envs/llms/bin/uvicorn app.main:app --host 0.0.0.0 --port 9090 &
        UVICORN_PID=$!
        echo "$(date): Restarted Uvicorn with PID $UVICORN_PID" >> "$LOG_FILE"
    fi
    
    sleep 5
done