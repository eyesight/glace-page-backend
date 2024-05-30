#!/bin/bash

# Source environment variables from .env file
source .env

# Function to create dump from remote database
create_dump() {
    pg_dump $REMOTE_CONNECTION_URL > $DUMP_FILE
}

# Function to import dump into local database
import_dump() {
    psql -d $LOCAL_DATABASE_NAME -f $DUMP_FILE
}

# Function to check if database exists
check_database_exists() {
    psql -lqt | cut -d \| -f 1 | grep -qw $1
}

# Main function
main() {
    # Name of the local database
    LOCAL_DATABASE_NAME="glace-db"

    # File to store the dump
    DUMP_FILE="database_dump.sql"

    # Create dump from remote database
    create_dump
    echo "Remote database dumped successfully."

    # Check if local database exists
    if ! check_database_exists $LOCAL_DATABASE_NAME; then
        # Create local database if it doesn't exist
        createdb $LOCAL_DATABASE_NAME
        echo "Local database created successfully."
    fi

    # Import dump into local database
    import_dump
    echo "Dump imported into local database successfully."

    # Clean up: delete dump file
    rm $DUMP_FILE
    echo "Dump file deleted."
}

# Execute main function
main