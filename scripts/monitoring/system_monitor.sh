#!/bin/bash

# System Monitor Script
# Displays system resource usage and health information

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print section header
print_header() {
    echo -e "\n${CYAN}==================== $1 ====================${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# System Information
show_system_info() {
    print_header "SYSTEM INFORMATION"
    echo -e "${GREEN}Hostname:${NC} $(hostname)"
    echo -e "${GREEN}Kernel:${NC} $(uname -r)"
    echo -e "${GREEN}Uptime:${NC} $(uptime -p 2>/dev/null || uptime)"
    echo -e "${GREEN}Current Date:${NC} $(date)"
}

# CPU Usage
show_cpu_usage() {
    print_header "CPU USAGE"
    if command_exists mpstat; then
        mpstat 1 1 | tail -n 1
    else
        top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print "CPU Usage: " 100 - $1"%"}'
    fi
    
    echo -e "${GREEN}Load Average:${NC} $(cat /proc/loadavg | awk '{print $1" "$2" "$3}')"
    echo -e "${GREEN}CPU Cores:${NC} $(nproc)"
}

# Memory Usage
show_memory_usage() {
    print_header "MEMORY USAGE"
    free -h | awk 'NR==1{print $0} NR==2{printf "%s: %s/%s (%.2f%%)\n", $1, $3, $2, ($3/$2)*100}'
    
    # Show top 5 memory consuming processes
    echo -e "\n${YELLOW}Top 5 Memory Consuming Processes:${NC}"
    ps aux --sort=-%mem | head -n 6 | awk 'NR==1 || NR>1 {printf "%-10s %-8s %-8s %s\n", $1, $2, $4"%", $11}'
}

# Disk Usage
show_disk_usage() {
    print_header "DISK USAGE"
    df -h | awk 'NR==1 || /^\/dev\// {print $0}'
    
    # Warn if any partition is over 80% full
    echo ""
    df -h | awk '/^\/dev\// {gsub(/%/,"",$5); if($5>80) print "WARNING: " $1 " is " $5"% full!"}'
}

# Network Information
show_network_info() {
    print_header "NETWORK INFORMATION"
    
    if command_exists ip; then
        echo -e "${GREEN}Active Network Interfaces:${NC}"
        ip -br addr show | grep -v "lo" | grep "UP"
    else
        echo -e "${GREEN}Active Network Interfaces:${NC}"
        ifconfig | grep "inet " | grep -v "127.0.0.1"
    fi
}

# Process Information
show_process_info() {
    print_header "PROCESS INFORMATION"
    echo -e "${GREEN}Total Processes:${NC} $(ps aux | wc -l)"
    echo -e "${GREEN}Running Processes:${NC} $(ps aux | grep -v grep | grep "R" | wc -l)"
    
    echo -e "\n${YELLOW}Top 5 CPU Consuming Processes:${NC}"
    ps aux --sort=-%cpu | head -n 6 | awk 'NR==1 || NR>1 {printf "%-10s %-8s %-8s %s\n", $1, $2, $3"%", $11}'
}

# Main function
main() {
    clear
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           SYSTEM MONITORING DASHBOARD                ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════╝${NC}"
    
    show_system_info
    show_cpu_usage
    show_memory_usage
    show_disk_usage
    show_network_info
    show_process_info
    
    echo -e "\n${GREEN}Monitoring completed at $(date)${NC}\n"
}

# Run main function
main
