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
CHECK_LOG="${SAVE_DIR}/${MONTH_KEY}_${HOST_NAME}.log"

# create output directory and capture command errors
mkdir -p "$SAVE_DIR" || exit 1
exec 3>> "$CHECK_LOG" || exit 1
exec 2>&3

# Use the process ID to distinguish separate runs without calling date per file.
log() {
    printf 'pid=%s %s\n' "$$" "$*" >&3 || exit 1
}

log "START time=$(date '+%F %T %z') host=$HOST_NAME user=$(id -un) day=$DAY date_key=$DATE_KEY"
log "PATH pattern=$LOG_DIR/access.$DAY-* csv=$CSV_FILE"

# check log directory and access permissions
if [ ! -d "$LOG_DIR" ]; then
    log "ERROR log_directory_missing path=$LOG_DIR"
elif [ ! -r "$LOG_DIR" ] || [ ! -x "$LOG_DIR" ]; then
    log "ERROR log_directory_not_accessible path=$LOG_DIR"
fi

# add access log sizes in bytes
TOTAL_BYTES=0
FILE_COUNT=0
STAT_ERRORS=0

# sum access log sizes and record errors
for LOG_FILE in "$LOG_DIR"/access."$DAY"-*; do
    if [ -f "$LOG_FILE" ]; then
        FILE_COUNT=$((FILE_COUNT + 1))
        log "READ file=$LOG_FILE"
        FILE_BYTES=$(stat -c %s -- "$LOG_FILE")
        STAT_STATUS=$?
        if [ "$STAT_STATUS" -ne 0 ]; then
            STAT_ERRORS=$((STAT_ERRORS + 1))
            log "ERROR stat_failed status=$STAT_STATUS file=$LOG_FILE"
        else
            log "FILE bytes=$FILE_BYTES file=$LOG_FILE"
        fi
        TOTAL_BYTES=$((TOTAL_BYTES + FILE_BYTES))
    else
        log "SKIP not_regular_or_unavailable path=$LOG_FILE"
    fi
done

# warn if no files were collected
if [ "$FILE_COUNT" -eq 0 ]; then
    log "WARN no_regular_files_collected pattern=$LOG_DIR/access.$DAY-*"
fi

# convert bytes to MiB (keep the original integer calculation)
TOTAL_MB=$((TOTAL_BYTES / 1024 / 1024))
log "TOTAL files=$FILE_COUNT stat_errors=$STAT_ERRORS bytes=$TOTAL_BYTES size_mb=$TOTAL_MB"

if [ "$TOTAL_MB" -eq 0 ]; then
    log "WARN zero_csv_value bytes=$TOTAL_BYTES files=$FILE_COUNT stat_errors=$STAT_ERRORS"
fi

# add header to a new CSV file
if [ ! -s "$CSV_FILE" ]; then
    if ! printf "DATE,HOSTNAME,SIZE_MB,LOG_COUNT\n" > "$CSV_FILE"; then
        log "ERROR csv_header_write_failed file=$CSV_FILE"
        exit 1
    fi
fi

# add daily result (keep the original CSV behavior, including zero values)
if printf "%s,%s,%s,%s\n" "$DATE_KEY" "$HOST_NAME" "$TOTAL_MB" "$FILE_COUNT" >> "$CSV_FILE"; then
    log "CSV_OK row=$DATE_KEY,$HOST_NAME,$TOTAL_MB,$FILE_COUNT file=$CSV_FILE"
else
    log "ERROR csv_append_failed file=$CSV_FILE"
    exit 1
fi

# delete previous year CSV and script logs on January 2
if [ "$(date +%m%d)" = "0102" ]; then
    PREVIOUS_YEAR=$(date -d "1 year ago" +%y)
    if find "$SAVE_DIR" -maxdepth 1 -type f \( -name "${PREVIOUS_YEAR}[0-1][0-9]_${HOST_NAME}.csv" -o -name "${PREVIOUS_YEAR}[0-1][0-9]_${HOST_NAME}.log" \) -delete; then
        log "CLEANUP_OK previous_year=$PREVIOUS_YEAR"
    else
        log "ERROR cleanup_failed previous_year=$PREVIOUS_YEAR"
        exit 1
    fi
fi

log "END time=$(date '+%F %T %z') files=$FILE_COUNT stat_errors=$STAT_ERRORS"
