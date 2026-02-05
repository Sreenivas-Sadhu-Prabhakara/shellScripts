#!/bin/bash

# Git Helper Script
# Provides useful git operations for common workflows

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Display usage
usage() {
    echo -e "${BLUE}Git Helper Script${NC}"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  status      - Show detailed git status"
    echo "  sync        - Sync with remote (pull + push)"
    echo "  cleanup     - Clean up merged branches"
    echo "  stats       - Show repository statistics"
    echo "  backup      - Create a backup of current branch"
    echo "  recent      - Show recent commits"
    echo ""
    exit 1
}

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository${NC}"
        exit 1
    fi
}

# Show detailed status
show_status() {
    echo -e "${BLUE}=== Git Repository Status ===${NC}"
    echo -e "${GREEN}Branch:${NC} $(git branch --show-current)"
    echo -e "${GREEN}Remote:${NC} $(git remote -v | head -n 1 | awk '{print $2}')"
    echo ""
    echo -e "${YELLOW}Files Status:${NC}"
    git status --short
    echo ""
    echo -e "${YELLOW}Unpushed Commits:${NC}"
    git log --oneline @{u}.. 2>/dev/null || echo "  No unpushed commits"
}

# Sync with remote
sync_remote() {
    echo -e "${BLUE}=== Syncing with remote ===${NC}"
    
    # Get current branch
    BRANCH=$(git branch --show-current)
    echo -e "${GREEN}Current branch:${NC} $BRANCH"
    
    # Stash if there are changes
    if ! git diff-index --quiet HEAD --; then
        echo -e "${YELLOW}Stashing local changes...${NC}"
        git stash save "Auto-stash before sync $(date)"
    fi
    
    # Pull changes
    echo -e "${GREEN}Pulling changes...${NC}"
    git pull origin "$BRANCH"
    
    # Push changes
    echo -e "${GREEN}Pushing changes...${NC}"
    git push origin "$BRANCH"
    
    # Pop stash if exists
    if git stash list | grep -q "Auto-stash before sync"; then
        echo -e "${YELLOW}Restoring stashed changes...${NC}"
        git stash pop
    fi
    
    echo -e "${GREEN}Sync completed!${NC}"
}

# Cleanup merged branches
cleanup_branches() {
    echo -e "${BLUE}=== Cleaning up merged branches ===${NC}"
    
    # Get current branch
    CURRENT=$(git branch --show-current)
    
    # Find merged branches
    MERGED_BRANCHES=$(git branch --merged | grep -v "^\*" | grep -v "main" | grep -v "master" | grep -v "$CURRENT")
    
    if [ -z "$MERGED_BRANCHES" ]; then
        echo -e "${GREEN}No merged branches to clean up${NC}"
        return
    fi
    
    echo -e "${YELLOW}Merged branches:${NC}"
    echo "$MERGED_BRANCHES"
    echo ""
    read -p "Delete these branches? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "$MERGED_BRANCHES" | xargs -r git branch -d
        echo -e "${GREEN}Branches deleted${NC}"
    else
        echo -e "${YELLOW}Cleanup cancelled${NC}"
    fi
}

# Show repository statistics
show_stats() {
    echo -e "${BLUE}=== Repository Statistics ===${NC}"
    echo -e "${GREEN}Total Commits:${NC} $(git rev-list --count HEAD)"
    echo -e "${GREEN}Contributors:${NC} $(git shortlog -sn --all | wc -l)"
    echo -e "${GREEN}Branches:${NC} $(git branch -a | wc -l)"
    echo -e "${GREEN}Tags:${NC} $(git tag | wc -l)"
    echo ""
    echo -e "${YELLOW}Top Contributors:${NC}"
    git shortlog -sn --all | head -n 5
    echo ""
    echo -e "${YELLOW}Recent Activity:${NC}"
    git log --all --pretty=format:"%ar - %an: %s" --max-count=5
}

# Backup current branch
backup_branch() {
    BRANCH=$(git branch --show-current)
    BACKUP_NAME="${BRANCH}_backup_$(date +%Y%m%d_%H%M%S)"
    
    echo -e "${BLUE}=== Creating branch backup ===${NC}"
    git branch "$BACKUP_NAME"
    echo -e "${GREEN}Created backup branch:${NC} $BACKUP_NAME"
}

# Show recent commits
show_recent() {
    echo -e "${BLUE}=== Recent Commits ===${NC}"
    git log --oneline --graph --decorate --max-count=10
}

# Main script
check_git_repo

if [ $# -eq 0 ]; then
    usage
fi

case "$1" in
    status)
        show_status
        ;;
    sync)
        sync_remote
        ;;
    cleanup)
        cleanup_branches
        ;;
    stats)
        show_stats
        ;;
    backup)
        backup_branch
        ;;
    recent)
        show_recent
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        usage
        ;;
esac
