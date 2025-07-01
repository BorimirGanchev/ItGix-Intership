#!/bin/bash

# Get script directory and ensure logs folder exists
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"

# Generate log filename with timestamp
LOG_FILE="$LOG_DIR/monitor-$(date +%F-%H%M).log"

# Write system info to log
{
  echo "===== System Monitoring Report: $(date) ====="
  echo ""
  echo "[CPU Load]"
  uptime
  echo ""
  echo "[Memory Usage]"
  free -h
  echo ""
  echo "[Disk Usage]"
  df -h
} > "$LOG_FILE"

echo "Log saved to $LOG_FILE"