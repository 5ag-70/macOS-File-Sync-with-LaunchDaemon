#!/bin/bash

# === Config ===
GROUP="staff"
LOG_FILE="/Users/sagarrana/.track_and_copy.log"
LOCK_FILE="/tmp/.track_and_copy.lock"

# === Locking ===
exec 9>"$LOCK_FILE"
/opt/homebrew/bin/flock 9

# === Start Logging ===
echo "" >> "$LOG_FILE"
echo " ****** Track and Copy Script Started ****** " >> "$LOG_FILE"
echo "$(date): [INFO] Acquired lock and starting sync" >> "$LOG_FILE"
echo "$(date): [INFO] If any changes found Local Dir," >> "$LOG_FILE"
echo -e "\t\t\t\t\t\t\t\t\t it will push those changes to Home Folder" >> "$LOG_FILE"

# === File sync list (SRC, DEST) pairs ===
FILES_TO_SYNC=(
    "/Users/sagarrana/Documents/Kaseya_System/.zprofile"    "/Users/sagarrana/.zprofile"
    "/Users/sagarrana/Documents/Kaseya_System/.zsh_history" "/Users/sagarrana/.zsh_history"
    "/Users/sagarrana/Documents/Kaseya_System/.vimrc"       "/Users/sagarrana/.vimrc"
)

# === Sync each file ===
i=0
while [ $i -lt ${#FILES_TO_SYNC[@]} ]; do
    SRC="${FILES_TO_SYNC[$i]}"
    DEST="${FILES_TO_SYNC[$((i + 1))]}"
    FILE_NAME=$(basename "$SRC")

    if [ ! -f "$SRC" ]; then
        echo "$(date): [ERROR] $FILE_NAME not found at $SRC" >> "$LOG_FILE"
        i=$((i + 2))
        continue
    fi

    if ! cmp -s "$SRC" "$DEST"; then
        echo "$(date): [INFO] Syncing $FILE_NAME" >> "$LOG_FILE"
        rsync -u "$SRC" "$DEST" >> "$LOG_FILE" 2>&1
        chown "sagarrana:$GROUP" "$DEST"
        echo -e "$(date): [INFO] Synced and updated ownership of $FILE_NAME" >> "$LOG_FILE"
        echo -e "\t\t\t\t\t\t\t\t\t Done......." >> "$LOG_FILE"
    else
        echo "$(date): [SKIP] No changes detected for $FILE_NAME. Skipping..." >> "$LOG_FILE"
    fi

    i=$((i + 2))
done

# === Sync .ssh Directory ===
SSH_SOURCE="/Users/sagarrana/Documents/Kaseya_System/.ssh"
SSH_DEST="/Users/sagarrana/.ssh"

if [ -d "$SSH_SOURCE" ]; then
    if ! diff -qr "$SSH_SOURCE" "$SSH_DEST" > /dev/null 2>&1; then
        echo "$(date): [INFO] Syncing .ssh directory" >> "$LOG_FILE"
        rsync -a --delete "$SSH_SOURCE/" "$SSH_DEST/" >> "$LOG_FILE" 2>&1
        chown -R "sagarrana:$GROUP" "$SSH_DEST"
        echo -e "$(date): [INFO] Synced and updated ownership of .ssh directory" >> "$LOG_FILE"
        echo -e "\t\t\t\t\t\t\t\t\t Done......." >> "$LOG_FILE"
    else
        echo "$(date): [SKIP] No changes detected in .ssh directory. Skipping..." >> "$LOG_FILE"
    fi
else
    echo "$(date): [ERROR] .ssh directory not found at $SSH_SOURCE" >> "$LOG_FILE"
fi

# === Wrap Up ===
echo "$(date): [INFO] Releasing lock" >> "$LOG_FILE"
echo "$(date): [INFO] Script completed" >> "$LOG_FILE"
echo " ****** Track and Copy Back Script Completed ****** " >> "$LOG_FILE"
echo "" >> "$LOG_FILE"