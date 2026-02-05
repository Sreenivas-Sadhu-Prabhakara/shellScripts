#!/bin/bash

# Log Rotation Script
# Rotates and compresses log files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
LOG_DIR="${1:-.}"
MAX_SIZE=10485760  # 10MB in bytes
KEEP_ROTATIONS=5

# Display usage
usage() {
    echo -e "${BLUE}Log Rotation Script${NC}"
    echo ""
    echo "Usage: $0 [log_directory]"
    echo ""
    echo "This script rotates log files larger than 10MB"
    echo "and keeps the last 5 rotations compressed."
    echo ""
    echo "Example:"
    echo "  $0 /var/log/myapp"
    echo ""
    exit 1
}

# Check if directory exists
if [ ! -d "$LOG_DIR" ]; then
    echo -e "${RED}Error: Directory does not exist: $LOG_DIR${NC}"
    exit 1
fi

# Function to get file size in bytes
get_file_size() {
    stat -f%z "$1" 2>/dev/null || stat -c%s "$1" 2>/dev/null
}

# Function to rotate a single log file
rotate_log() {
    local logfile="$1"
    local basename=$(basename "$logfile")
    local dirname=$(dirname "$logfile")
    
    echo -e "${YELLOW}Rotating:${NC} $logfile"
    
    # Shift existing rotated logs
    for i in $(seq $((KEEP_ROTATIONS - 1)) -1 1); do
        if [ -f "${logfile}.$i.gz" ]; then
            mv "${logfile}.$i.gz" "${logfile}.$((i + 1)).gz"
        fi
    done
    
    # Delete oldest rotation (after shifting, rotation 6 is the oldest when keeping 5)
    if [ -f "${logfile}.$((KEEP_ROTATIONS + 1)).gz" ]; then
        rm -f "${logfile}.$((KEEP_ROTATIONS + 1)).gz"
        echo -e "${GREEN}  Deleted oldest rotation${NC}"
    fi
    
    # Rotate current log
    if [ -f "$logfile" ]; then
        cp "$logfile" "${logfile}.1"
        gzip "${logfile}.1"
        > "$logfile"  # Truncate the original log file
        echo -e "${GREEN}  Created new rotation: ${logfile}.1.gz${NC}"
    fi
}

# Main function
main() {
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║              LOG ROTATION UTILITY                     ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Log Directory:${NC} $LOG_DIR"
    echo -e "${GREEN}Max Size:${NC} $(numfmt --to=iec-i --suffix=B $MAX_SIZE 2>/dev/null || echo "$MAX_SIZE bytes")"
    echo -e "${GREEN}Keep Rotations:${NC} $KEEP_ROTATIONS"
    echo ""
    
    # Find log files that need rotation
    ROTATED_COUNT=0
    
    while IFS= read -r -d '' logfile; do
        SIZE=$(get_file_size "$logfile")
        
        if [ "$SIZE" -gt "$MAX_SIZE" ]; then
            rotate_log "$logfile"
            ROTATED_COUNT=$((ROTATED_COUNT + 1))
        fi
    done < <(find "$LOG_DIR" -maxdepth 1 -type f -name "*.log" -print0 2>/dev/null)
    
    if [ $ROTATED_COUNT -eq 0 ]; then
        echo -e "${GREEN}No log files need rotation${NC}"
    else
        echo -e "\n${GREEN}Total files rotated: $ROTATED_COUNT${NC}"
    fi
    
    # Show summary of rotated logs
    echo -e "\n${BLUE}=== Rotated Log Summary ===${NC}"
    find "$LOG_DIR" -name "*.log.*.gz" -type f -exec ls -lh {} \; 2>/dev/null | \
        awk '{printf "%s %s %s\n", $5, $9, $6" "$7}' || echo "No rotated logs found"
    
    echo -e "\n${GREEN}Log rotation completed!${NC}"
}

# Check for help flag
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    usage
fi

# Run main function
main
