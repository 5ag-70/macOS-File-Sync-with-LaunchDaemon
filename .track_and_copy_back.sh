#!/bin/bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"
# Source and destination paths
ZPROFILE_SOURCE="/Users/sagarrana/Documents/Kaseya_System/.zprofile"
ZPROFILE_DEST="/Users/sagarrana/.zprofile"

SSH_SOURCE="/Users/sagarrana/Documents/Kaseya_System/.ssh"
SSH_DEST="/Users/sagarrana/.ssh"

LOG_FILE="/Users/sagarrana/.track_and_copy.log"

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
