#!/bin/sh

set -e

# Source the shared library
. "$(dirname "$0")/../lib/validate.sh"

check_var GIT_REPO
check_var GIT_REF
check_var TARGET_DIR

# Create a lock file in /tmp (using TARGET_DIR in name to make it unique)
LOCK_FILE="/tmp/$(echo "${TARGET_DIR}" | sed 's/\//_/g').lock"
touch "$LOCK_FILE"

# Attempt to acquire lock, fail if cannot obtain it
echo "Acquiring lock..."
(
    if ! flock -n 9; then
        echo "Error: Another process is currently updating the repository"
        exit 1
    fi

    echo "Syncing with remote repository"

    if [ -d "$TARGET_DIR/.git" ]; then
        echo "Repository already exists, updating origin and pulling latest changes"
        cd "$TARGET_DIR"
        # Update the remote origin URL if it has changed
        git remote set-url origin "$GIT_REPO"
        git fetch origin
        
        # Store current branch state
        current_commit=$(git rev-parse HEAD)
        remote_commit=$(git rev-parse "origin/$GIT_REF")
        
        git checkout "$GIT_REF"
        
        # Check if local and remote have diverged
        if [ "$current_commit" != "$remote_commit" ] && ! git merge-base --is-ancestor "$current_commit" "$remote_commit"; then
            echo "Remote history has diverged - resetting to match remote (handling force push)"
            git reset --hard "origin/$GIT_REF"
        else
            git pull origin "$GIT_REF"
        fi
    else
        echo "Cloning repository"
        git clone --depth 1 "$GIT_REPO" -b "$GIT_REF" "$TARGET_DIR"
    fi
) 9>"$LOCK_FILE"
