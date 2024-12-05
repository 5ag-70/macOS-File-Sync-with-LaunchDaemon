# macOS File Sync with LaunchDaemon

This project provides an automated solution to monitor and synchronize specific files or directories (`.zprofile` and `.ssh`) on macOS using `LaunchDaemon`. It ensures changes are automatically copied to a target location whenever they occur.

## Features

- **File Monitoring:** Watches specified files and directories for changes.
- **Automatic Synchronization:** Automatically copies updated files to the destination path.
- **Customizable Script:** Allows configuration for source and destination paths.
- **Robust Debugging Tools:** Provides debugging commands to identify and resolve issues.

---

## Prerequisites

1. macOS (tested on Sequoia 15.1.1 ).
2. Basic knowledge of terminal commands.
3. Admin privileges.

---

## Installation

### 1. Clone the Repository
```bash
git clone <repository_url>
cd <repository_name>
```

### 1a. Move files to appropriate locations and change there permission accordingly
```bash
cp com.user.zprofile_ssh_sync.plist /Library/LaunchDaemons/com.user.zprofile_ssh_sync.plist
cd /Library/LaunchDaemons/
sudo chmod 644 com.user.zprofile_ssh_sync.plist
cp .track_and_copy.sh /path/where/you/want/to/keep/.track_and_copy.sh 
cd /path/where/you/have/kept/.track_and_copy.sh
touch .track_and_copy.log 
sudo chmod 0644 .track_and_copy.log
sudo chmod 0755 .track_and_copy.sh;sudo chown <username> .track_and_copy.sh
```

### 2. Setup the LaunchDaemon Plist
```bash
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.zprofile_ssh_sync</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/path/to/.track_and_copy.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>WatchPaths</key>
    <array>
        <string>/Users/<username>/.zprofile</string>
        <string>/Users/<username>/.ssh</string>
    </array>
    <key>StandardOutPath</key>
    <string>/tmp/com.user.zprofile_ssh_sync.out</string>
    <key>StandardErrorPath</key>
    <string>/tmp/com.user.zprofile_ssh_sync.err</string>
</dict>
</plist>
```
Replace <username> and /path/to/.track_and_copy.sh with actual values.

### 3. Grant Full Disk Access to Bash
Go to System Preferences → Privacy & Security → Full Disk Access and add:
- /bin/bash

### 4. Load the LaunchDaemon
```bash
sudo launchctl load /Library/LaunchDaemons/com.user.zprofile_ssh_sync.plist
```

### 5. File Synchronization Script
The synchronization script (.track_and_copy.sh) handles copying .zprofile and .ssh directories:
```bash
#!/bin/bash

# Source and destination paths
ZPROFILE_SOURCE="/Users/<username>/.zprofile"
ZPROFILE_DEST="/path/to/destination/.zprofile"

SSH_SOURCE="/Users/<username>/.ssh"
SSH_DEST="/path/to/destination/.ssh"

LOG_FILE="/path/to/log/file.log"

echo "$(date): Script started" >> "$LOG_FILE"

# Copy .zprofile if it has changed
if [ -f "$ZPROFILE_SOURCE" ]; then
    rsync -u "$ZPROFILE_SOURCE" "$ZPROFILE_DEST" >> "$LOG_FILE" 2>&1
    echo "$(date): Synced .zprofile" >> "$LOG_FILE"
else
    echo "$(date): .zprofile not found" >> "$LOG_FILE"
fi

# Sync .ssh folder
if [ -d "$SSH_SOURCE" ]; then
    rsync -a --delete "$SSH_SOURCE/" "$SSH_DEST/" >> "$LOG_FILE" 2>&1
    echo "$(date): Synced .ssh" >> "$LOG_FILE"
else
    echo "$(date): .ssh directory not found" >> "$LOG_FILE"
fi
```

## Debugging

### 1.	Check System Logs:
```bash
log show --predicate 'eventMessage contains "com.user.zprofile_ssh_sync"' --info --debug --last 5m
```

### 2.	View Script Logs:
```bash
tail -f /path/to/log/file.log
```

## Notes
1.	Plist File Location: Must be created in /Library/LaunchDaemons for system-wide use.
2.	Full Disk Access: Essential for bash to access and modify files.
3.	Script Placement: The script can be placed anywhere on the system.
4.  To show/access hidden/dot files press ⌘+⇧+. (command+shift+.)

<div style="border-left: 4px solid #FFA500; padding: 10px; background-color: #FF0000; color: #FFFFFF;">
<strong>⚠️ Warning:</strong> Don't not change absolute path to <strong>$HOME, ~, $(WHOAMI) or anything else</strong>.
</div>

## Contributing
Contributions are welcome! Please open an issue or submit a pull request
