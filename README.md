# Shell Scripts Collection

A collection of useful shell scripts for automation tasks, system monitoring, and utilities.

## 📁 Directory Structure

```
scripts/
├── backup/          # Backup and archiving scripts
├── monitoring/      # System monitoring scripts
├── git/            # Git workflow helpers
└── utilities/      # General utility scripts
```

## 🚀 Available Scripts

### Backup Scripts

#### backup.sh
Creates compressed backups of specified directories with automatic cleanup of old backups.

**Usage:**
```bash
./scripts/backup/backup.sh [source_directory] [backup_destination]
```

**Features:**
- Automatic timestamp-based naming
- Compression using tar.gz
- Keeps last 5 backups automatically
- Color-coded output
- Error handling

**Example:**
```bash
./scripts/backup/backup.sh ~/documents ~/backups
```

### Monitoring Scripts

#### system_monitor.sh
Comprehensive system monitoring dashboard displaying resource usage and health information.

**Usage:**
```bash
./scripts/monitoring/system_monitor.sh
```

**Displays:**
- System information (hostname, kernel, uptime)
- CPU usage and load average
- Memory usage with top consumers
- Disk usage with warnings
- Network interfaces
- Process information

### Git Scripts

#### git_helper.sh
Helper script for common git operations and workflows.

**Usage:**
```bash
./scripts/git/git_helper.sh [command]
```

**Commands:**
- `status` - Show detailed git status
- `sync` - Sync with remote (pull + push with auto-stash)
- `cleanup` - Clean up merged branches
- `stats` - Show repository statistics
- `backup` - Create a backup of current branch
- `recent` - Show recent commits

**Example:**
```bash
./scripts/git/git_helper.sh sync
./scripts/git/git_helper.sh stats
```

### Utility Scripts

#### cleanup.sh
Cleans up temporary files and old logs from specified directories.

**Usage:**
```bash
./scripts/utilities/cleanup.sh [options] [directory]
```

**Options:**
- `-d DAYS` - Number of days old for files to delete (default: 7)
- `-n` - Dry run mode (show what would be deleted)
- `-h` - Show help message

**Features:**
- Removes temporary files (*.tmp, *.temp, *~)
- Cleans old log files
- Removes empty directories
- Dry run mode for safety
- Size statistics

**Example:**
```bash
./scripts/utilities/cleanup.sh -d 30 /tmp
./scripts/utilities/cleanup.sh -n /var/log  # Dry run
```

#### log_rotate.sh
Rotates and compresses large log files.

**Usage:**
```bash
./scripts/utilities/log_rotate.sh [log_directory]
```

**Features:**
- Rotates logs larger than 10MB
- Keeps last 5 rotations
- Automatic compression
- Summary of rotated logs

**Example:**
```bash
./scripts/utilities/log_rotate.sh /var/log/myapp
```

## 📋 Requirements

- Bash 4.0 or higher
- Standard Unix utilities (tar, gzip, find, awk, etc.)
- Git (for git_helper.sh)

## 🔧 Installation

1. Clone the repository:
```bash
git clone https://github.com/Sreenivas-Sadhu-Prabhakara/shellScripts.git
cd shellScripts
```

2. Make scripts executable:
```bash
chmod +x scripts/**/*.sh
```

3. (Optional) Add to PATH:
```bash
export PATH="$PATH:$(pwd)/scripts/backup:$(pwd)/scripts/monitoring:$(pwd)/scripts/git:$(pwd)/scripts/utilities"
```

## 🛡️ Safety Features

- All scripts use `set -e` to exit on errors
- Dry run modes where appropriate
- Confirmation prompts for destructive operations
- Color-coded output for better visibility
- Comprehensive error messages

## 📝 Contributing

Feel free to contribute by:
- Adding new scripts
- Improving existing scripts
- Reporting bugs
- Suggesting features

## 📄 License

This project is open source and available for use and modification.

## ⚠️ Disclaimer

These scripts are provided as-is. Always test in a safe environment before using in production. Make sure to understand what each script does before running it.

## 🔗 Useful Links

- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [ShellCheck](https://www.shellcheck.net/) - Shell script analysis tool
