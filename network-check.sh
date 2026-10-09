#!/usr/bin/env bash

# Setup logging
LOG_DIR="logs"
LOG_FILE="${LOG_DIR}/network-check.log"
mkdir -p "$LOG_DIR"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

HOST="$1"
PORT="$2"

# 1. Validate host input
if [ -z "$HOST" ]; then
    echo "Error: Host parameter is required." >&2
    echo "Usage: $0 <hostname-or-ip> [port]" >&2
    log_message "ERROR: Missing host argument."
    exit 2
fi

log_message "START: Network check for host '$HOST'"
echo "=========================================="
echo "          NETWORK DIAGNOSTIC TOOL         "
echo "=========================================="

# 2. Host Resolution (Prefer IPv4)
echo -n "Resolving host ($HOST)... "
RESOLVED_IP=$(getent ahostsv4 "$HOST" 2>/dev/null | awk '{ print $1 }' | head -n 1)

# Fallback if ahostsv4 is unavailable or returns empty
if [ -z "$RESOLVED_IP" ]; then
    RESOLVED_IP=$(getent hosts "$HOST" | awk '{ print $1 }' | head -n 1)
fi

if [ -n "$RESOLVED_IP" ]; then
    echo "Resolved to: $RESOLVED_IP"
    log_message "RESOLVED: $HOST -> $RESOLVED_IP"
else
    echo "FAILED"
    echo "Error: Could not resolve hostname '$HOST'." >&2
    log_message "ERROR: Resolution failed for '$HOST'."
    exit 1
fi

# 3. Basic Connectivity Check (Ping)
echo -n "Ping test ($RESOLVED_IP)... "
PING_CMD="ping -c 2 -W 2"
if [[ "$RESOLVED_IP" =~ : ]]; then
    PING_CMD="ping6 -c 2 -W 2"
fi

if $PING_CMD "$RESOLVED_IP" >/dev/null 2>&1; then
    echo "SUCCESS"
    log_message "PING: $RESOLVED_IP responded successfully."
else
    echo "FAILED"
    log_message "PING: $RESOLVED_IP failed to respond."
fi

# 4. Network Interface Info
echo -e "\n--- Network Interfaces ---"
if command -v ip >/dev/null 2>&1; then
    ip -brief addr show 2>/dev/null || ip addr show
elif command -v ifconfig >/dev/null 2>&1; then
    ifconfig
else
    echo "Interface information unavailable."
fi

# 5. Optional TCP Port Check
if [ -n "$PORT" ]; then
    echo -e "\n--- TCP Port Check ---"
    # Validate port integer and range (1-65535)
    if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
        echo "Error: Invalid port '$PORT'. Port must be an integer between 1 and 65535." >&2
        log_message "ERROR: Invalid port number '$PORT'."
        exit 2
    fi

    echo -n "Checking TCP connection to $HOST:$PORT... "
    
    # Try netcat if available, fallback to bash socket check
    if command -v nc >/dev/null 2>&1; then
        nc -z -w 3 "$HOST" "$PORT" >/dev/null 2>&1
        PORT_STATUS=$?
    else
        timeout 3 bash -c "</dev/tcp/$HOST/$PORT" >/dev/null 2>&1
        PORT_STATUS=$?
    fi

    if [ $PORT_STATUS -eq 0 ]; then
        echo "OPEN"
        log_message "PORT: $HOST:$PORT is OPEN."
    else
        echo "CLOSED / UNREACHABLE"
        log_message "PORT: $HOST:$PORT is CLOSED or timeout."
        exit 1
    fi
fi

echo "=========================================="
exit 0