#!/bin/bash

# Source and destination paths
ZPROFILE_SOURCE="/Users/sagarrana/.zprofile"
ZPROFILE_DEST="/Users/sagarrana/Documents/Kaseya_System/.zprofile"

SSH_SOURCE="/Users/sagarrana/.ssh"
SSH_DEST="/Users/sagarrana/Documents/Kaseya_System/.ssh"

LOG_FILE="/Users/sagarrana/.track_and_copy_back.log"

echo "$(date): Script started" >> "$LOG_FILE"

# Copy .zprofile if it has changed
if [ -f "$ZPROFILE_SOURCE" ]; then
    rsync -u "$ZPROFILE_SOURCE" "$ZPROFILE_DEST" >> "$LOG_FILE" 2>&1
    chown sagarrana:staff "$ZPROFILE_DEST"
    echo "$(date): Synced and changed ownership of .zprofile" >> "$LOG_FILE"
else
    echo "$(date): .zprofile not found" >> "$LOG_FILE"
fi

# Sync .ssh folder
if [ -d "$SSH_SOURCE" ]; then
    rsync -a --delete "$SSH_SOURCE/" "$SSH_DEST/" >> "$LOG_FILE" 2>&1
    chown -R sagarrana:staff "$SSH_DEST"
    echo "$(date): Synced and changed ownership of .ssh" >> "$LOG_FILE"
else
    echo "$(date): .ssh directory not found" >> "$LOG_FILE"
fi
