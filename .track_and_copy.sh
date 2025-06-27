#!/bin/bash

# Log file path
LOG_FILE="/Users/sagarrana/.track_and_copy.log"

# Locking Mechanism
LOCK_FILE="/tmp/.track_and_copy.lock"
exec 9>"$LOCK_FILE"
flock 9
echo "$(date): Acquired lock and starting sync" >> "$LOG_FILE"

# Source and destination paths
ZPROFILE_SOURCE="/Users/sagarrana/Documents/Kaseya_System/.zprofile"
ZPROFILE_DEST="/Users/sagarrana/.zprofile"

SSH_SOURCE="/Users/sagarrana/Documents/Kaseya_System/.ssh"
SSH_DEST="/Users/sagarrana/.ssh"

echo "$(date): Script started: If any changes found in icloud, it will push those changes to local Destination folders" >> "$LOG_FILE"

# Copy .zprofile if it has changed
if ! cmp -s "$ZPROFILE_SOURCE" "$ZPROFILE_DEST"; then
    if [ -f "$ZPROFILE_SOURCE" ]; then
        rsync -u "$ZPROFILE_SOURCE" "$ZPROFILE_DEST" >> "$LOG_FILE" 2>&1
        chown sagarrana:staff "$ZPROFILE_DEST"
        echo "$(date): Synced and changed ownership of .zprofile" >> "$LOG_FILE"
    else
        echo "$(date): .zprofile not found" >> "$LOG_FILE"
    fi
else
    echo -e "$(date): No changes detected for zprofile.\nSkipping....." >> "$LOG_FILE"
fi

# Sync .ssh folder
if ! diff -qr "$SSH_SOURCE" "$SSH_DEST" > /dev/null 2>&1; then
    if [ -d "$SSH_SOURCE" ]; then
        rsync -a --delete "$SSH_SOURCE/" "$SSH_DEST/" >> "$LOG_FILE" 2>&1
        chown -R sagarrana:staff "$SSH_DEST"
        echo "$(date): Synced and changed ownership of .ssh" >> "$LOG_FILE"
    else
        echo "$(date): .ssh directory not found" >> "$LOG_FILE"
    fi
else
    echo -e "$(date): No changes detected in .ssh directory.\nSkipping....." >> "$LOG_FILE"
fi

echo "$(date): Releasing lock" >> "$LOG_FILE"
echo "$(date): Script completed" >> "$LOG_FILE"
