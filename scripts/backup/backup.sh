#!/bin/bash

# Backup Script
# This script creates compressed backups of specified directories

set -e

# Configuration
BACKUP_SOURCE="${1:-$HOME}"
BACKUP_DEST="${2:-$HOME/backups}"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="backup_${DATE}.tar.gz"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 [source_directory] [backup_destination]"
    echo "Example: $0 /home/user/documents /home/user/backups"
    exit 1
}

# Function to log messages
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Main backup function
perform_backup() {
    log "Starting backup process..."
    log "Source: $BACKUP_SOURCE"
    log "Destination: $BACKUP_DEST"
    
    # Create backup destination if it doesn't exist
    if [ ! -d "$BACKUP_DEST" ]; then
        log "Creating backup destination directory: $BACKUP_DEST"
        mkdir -p "$BACKUP_DEST"
    fi
    
    # Check if source exists
    if [ ! -d "$BACKUP_SOURCE" ]; then
        error "Source directory does not exist: $BACKUP_SOURCE"
        exit 1
    fi
    
    # Create backup
    log "Creating backup archive: $BACKUP_NAME"
    if tar -czf "$BACKUP_DEST/$BACKUP_NAME" -C "$(dirname "$BACKUP_SOURCE")" "$(basename "$BACKUP_SOURCE")"; then
        BACKUP_SIZE=$(du -h "$BACKUP_DEST/$BACKUP_NAME" | cut -f1)
        log "Backup completed successfully!"
        log "Backup file: $BACKUP_DEST/$BACKUP_NAME"
        log "Backup size: $BACKUP_SIZE"
    else
        error "Backup failed!"
        exit 1
    fi
    
    # Remove old backups (keep last 5)
    log "Cleaning up old backups (keeping last 5)..."
    cd "$BACKUP_DEST"
    ls -t backup_*.tar.gz 2>/dev/null | tail -n +6 | xargs -r rm
    
    log "Backup process completed!"
}

# Check for help flag
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    usage
fi

# Execute backup
perform_backup
