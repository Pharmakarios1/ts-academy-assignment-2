#!/usr/bin/env bash

# Setup logging
LOG_DIR="logs"
LOG_FILE="${LOG_DIR}/system-info.log"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] Executed system-info.sh" >> "$LOG_FILE"

# Collect System Info
HOSTNAME=$(hostname)
CURRENT_USER=$(whoami)
DATETIME=$(date)
OS_NAME=$(uname -s)
KERNEL_VER=$(uname -r)
UPTIME_VAL=$(uptime -p 2>/dev/null || uptime)
CPU_INFO=$(lscpu | grep "Model name:" | sed 's/Model name:\s*//' | head -n 1)
[ -z "$CPU_INFO" ] && CPU_INFO=$(grep -m 1 "model name" /proc/cpuinfo | awk -F: '{print $2}' | xargs)
MEM_INFO=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
CWD=$(pwd)

# Display Output
echo "=========================================="
echo "          SYSTEM INFORMATION              "
echo "=========================================="
echo "Hostname:         $HOSTNAME"
echo "Current User:     $CURRENT_USER"
echo "Date/Time:        $DATETIME"
echo "Operating System: $OS_NAME"
echo "Kernel Version:   $KERNEL_VER"
echo "Uptime:           $UPTIME_VAL"
echo "CPU Model:        $CPU_INFO"
echo "Memory (Used/Tot): $MEM_INFO"
echo "Working Directory: $CWD"
echo "=========================================="
