#!/bin/sh

set -e


# Creates a lock file based on provided name and executes the provided command with lock
# Usage: with_lock "lock_name" "command to execute"
with_lock() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Error: with_lock requires two parameters: lock_name and command"
        exit 1
    fi
    
    # Create a lock file in /tmp with sanitized name
    LOCK_NAME=$(echo "$1" | sed 's/\//_/g')
    LOCK_FILE="/tmp/${LOCK_NAME}.lock"
    touch "$LOCK_FILE"
    
    # Attempt to acquire lock and execute command
    echo "Acquiring lock ($1)..."
    (
        if ! flock -n 9; then
            echo "Error: Another process is currently holding the lock: $1"
            exit 1
        fi
        
        # Execute the provided command
        eval "$2"
    ) 9>"$LOCK_FILE"
}
