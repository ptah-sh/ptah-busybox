#!/bin/sh

set -e

# Source the shared library
. "$(dirname "$0")/../lib/validate.sh"
. "$(dirname "$0")/../lib/sync.sh"

check_var GIT_REPO
check_var GIT_REF
check_var TARGET_DIR

# Define the git sync operation as a function
git_sync() {
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
}

with_lock "${TARGET_DIR}" git_sync
