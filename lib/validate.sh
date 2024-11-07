#!/bin/sh

# Function to check if a variable is set and not empty
check_var() {
    eval value=\$$1
    if [ -z "$value" ]; then
        echo "Error: $1 is not set or is empty"
        exit 1
    fi
}