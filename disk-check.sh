#!/usr/bin/env bash

# Setup logging
LOG_DIR="logs"
LOG_FILE="${LOG_DIR}/disk-check.log"
mkdir -p "$LOG_DIR"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

THRESHOLD="$1"
PATH_TO_CHECK="${2:-/}"

# Validate threshold argument exists
if [ -z "$THRESHOLD" ]; then
    echo "Error: Threshold is required." >&2
    echo "Usage: $0 <threshold 1-100> [path]" >&2
    log_message "ERROR: Missing threshold argument."
    exit 2
fi

# Validate threshold is an integer between 1 and 100
if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || [ "$THRESHOLD" -lt 1 ] || [ "$THRESHOLD" -gt 100 ]; then
    echo "Error: Threshold must be an integer between 1 and 100." >&2
    log_message "ERROR: Invalid threshold '$THRESHOLD'."
    exit 2
fi

# Validate path exists
if [ ! -d "$PATH_TO_CHECK" ]; then
    echo "Error: Path '$PATH_TO_CHECK' does not exist." >&2
    log_message "ERROR: Path '$PATH_TO_CHECK' not found."
    exit 2
fi

# Get current disk usage percentage for target path
USAGE=$(df -P "$PATH_TO_CHECK" | tail -n 1 | awk '{print $5}' | tr -d '%')

if [ -z "$USAGE" ]; then
    echo "Error: Could not retrieve disk usage for $PATH_TO_CHECK." >&2
    log_message "ERROR: Failed to fetch disk usage."
    exit 1
fi

echo "Disk usage for '$PATH_TO_CHECK': ${USAGE}% (Threshold: ${THRESHOLD}%)"

if [ "$USAGE" -ge "$THRESHOLD" ]; then
    echo "WARNING: Disk usage (${USAGE}%) reached or exceeded threshold (${THRESHOLD}%)."
    log_message "WARNING: Path '$PATH_TO_CHECK' usage ${USAGE}% >= threshold ${THRESHOLD}%"
    exit 1
else
    echo "OK: Disk usage (${USAGE}%) is below threshold (${THRESHOLD}%)."
    log_message "OK: Path '$PATH_TO_CHECK' usage ${USAGE}% < threshold ${THRESHOLD}%"
    exit 0
fi
