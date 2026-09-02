#!/bin/bash

# access_size_check.sh

# change path for another environment
LOG_DIR="/LDAP/log"
SAVE_DIR="/LDAP/size"

# set file and date values
HOST_NAME=$(hostname -s)
DAY=$(date -d "yesterday" +%Y%m%d)
DATE_KEY=$(date -d "yesterday" +%y%m%d)
MONTH_KEY=$(date -d "yesterday" +%y%m)
CSV_FILE="${SAVE_DIR}/${MONTH_KEY}_${HOST_NAME}.csv"

# create output directory
mkdir -p "$SAVE_DIR"

# add access log sizes in bytes
TOTAL_BYTES=0

for LOG_FILE in "$LOG_DIR"/access."$DAY"-*; do
    if [ -f "$LOG_FILE" ]; then
        FILE_BYTES=$(stat -c %s -- "$LOG_FILE")
        TOTAL_BYTES=$((TOTAL_BYTES + FILE_BYTES))
    fi
done

# convert bytes to MiB
TOTAL_MB=$((TOTAL_BYTES / 1024 / 1024))

# add header to a new CSV file
if [ ! -s "$CSV_FILE" ]; then
    printf "DATE,HOSTNAME,SIZE_MB\n" > "$CSV_FILE"
fi

# add daily result
printf "%s,%s,%s\n" "$DATE_KEY" "$HOST_NAME" "$TOTAL_MB" >> "$CSV_FILE"

# delete previous year CSV files on January 2
if [ "$(date +%m%d)" = "0102" ]; then
    PREVIOUS_YEAR=$(date -d "1 year ago" +%y)
    find "$SAVE_DIR" -maxdepth 1 -type f -name "${PREVIOUS_YEAR}[0-1][0-9]_${HOST_NAME}.csv" -delete
fi
