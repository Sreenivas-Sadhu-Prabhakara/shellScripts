#!/bin/bash

# File Cleanup Script
# Cleans up temporary files and old logs

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DAYS_OLD=7
DRY_RUN=false

# Display usage
usage() {
    echo -e "${BLUE}File Cleanup Script${NC}"
    echo ""
    echo "Usage: $0 [options] [directory]"
    echo ""
    echo "Options:"
    echo "  -d DAYS     Number of days old for files to delete (default: 7)"
    echo "  -n          Dry run - show what would be deleted without deleting"
    echo "  -h          Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -d 30 /tmp              # Clean files older than 30 days in /tmp"
    echo "  $0 -n /var/log             # Dry run for /var/log"
    echo ""
    exit 1
}

# Parse command line arguments
while getopts "d:nh" opt; do
    case $opt in
        d)
            DAYS_OLD=$OPTARG
            ;;
        n)
            DRY_RUN=true
            ;;
        h)
            usage
            ;;
        \?)
            echo -e "${RED}Invalid option: -$OPTARG${NC}" >&2
            usage
            ;;
    esac
done

shift $((OPTIND-1))

TARGET_DIR="${1:-.}"

# Function to format size
format_size() {
    numfmt --to=iec-i --suffix=B "$1" 2>/dev/null || echo "$1 bytes"
}

# Function to clean temporary files
clean_temp_files() {
    echo -e "${BLUE}=== Cleaning Temporary Files ===${NC}"
    
    # Find patterns
    PATTERNS=(
        "*.tmp"
        "*.temp"
        "*.log.*"
        "*~"
        ".DS_Store"
        "Thumbs.db"
    )
    
    TOTAL_SIZE=0
    FILE_COUNT=0
    
    for pattern in "${PATTERNS[@]}"; do
        while IFS= read -r -d '' file; do
            SIZE=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
            TOTAL_SIZE=$((TOTAL_SIZE + SIZE))
            FILE_COUNT=$((FILE_COUNT + 1))
            
            if [ "$DRY_RUN" = true ]; then
                echo -e "${YELLOW}[DRY RUN] Would delete:${NC} $file ($(format_size $SIZE))"
            else
                echo -e "${GREEN}Deleting:${NC} $file ($(format_size $SIZE))"
                rm -f "$file"
            fi
        done < <(find "$TARGET_DIR" -type f -name "$pattern" -mtime "+$DAYS_OLD" -print0 2>/dev/null)
    done
    
    if [ $FILE_COUNT -eq 0 ]; then
        echo -e "${GREEN}No temporary files found${NC}"
    else
        echo -e "${GREEN}Total files: $FILE_COUNT${NC}"
        echo -e "${GREEN}Total size: $(format_size $TOTAL_SIZE)${NC}"
    fi
}

# Function to clean old logs
clean_old_logs() {
    echo -e "\n${BLUE}=== Cleaning Old Log Files ===${NC}"
    
    TOTAL_SIZE=0
    FILE_COUNT=0
    
    while IFS= read -r -d '' file; do
        SIZE=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
        TOTAL_SIZE=$((TOTAL_SIZE + SIZE))
        FILE_COUNT=$((FILE_COUNT + 1))
        
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY RUN] Would delete:${NC} $file ($(format_size $SIZE))"
        else
            echo -e "${GREEN}Deleting:${NC} $file ($(format_size $SIZE))"
            rm -f "$file"
        fi
    done < <(find "$TARGET_DIR" -type f -name "*.log" -mtime "+$DAYS_OLD" -print0 2>/dev/null)
    
    if [ $FILE_COUNT -eq 0 ]; then
        echo -e "${GREEN}No old log files found${NC}"
    else
        echo -e "${GREEN}Total log files: $FILE_COUNT${NC}"
        echo -e "${GREEN}Total size: $(format_size $TOTAL_SIZE)${NC}"
    fi
}

# Function to clean empty directories
clean_empty_dirs() {
    echo -e "\n${BLUE}=== Cleaning Empty Directories ===${NC}"
    
    DIR_COUNT=0
    
    while IFS= read -r -d '' dir; do
        DIR_COUNT=$((DIR_COUNT + 1))
        
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY RUN] Would remove:${NC} $dir"
        else
            echo -e "${GREEN}Removing:${NC} $dir"
            rmdir "$dir" 2>/dev/null || true
        fi
    done < <(find "$TARGET_DIR" -type d -empty -print0 2>/dev/null)
    
    if [ $DIR_COUNT -eq 0 ]; then
        echo -e "${GREEN}No empty directories found${NC}"
    else
        echo -e "${GREEN}Total empty directories: $DIR_COUNT${NC}"
    fi
}

# Main function
main() {
    if [ ! -d "$TARGET_DIR" ]; then
        echo -e "${RED}Error: Directory does not exist: $TARGET_DIR${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║              FILE CLEANUP UTILITY                     ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Target Directory:${NC} $TARGET_DIR"
    echo -e "${GREEN}Days Old:${NC} $DAYS_OLD"
    echo -e "${GREEN}Mode:${NC} $([ "$DRY_RUN" = true ] && echo "DRY RUN" || echo "ACTIVE")"
    echo ""
    
    if [ "$DRY_RUN" = false ]; then
        read -p "Continue with cleanup? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Cleanup cancelled${NC}"
            exit 0
        fi
    fi
    
    clean_temp_files
    clean_old_logs
    clean_empty_dirs
    
    echo -e "\n${GREEN}Cleanup completed!${NC}"
}

# Run main function
main
