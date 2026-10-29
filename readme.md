# LDAP Access Log Size Collector

A Bash script that collects the size and count of previous-day LDAP access log files and saves the results to a monthly CSV file.

Diagnostic logs record the files checked, collected sizes, and errors.

## Requirements

- Linux with Bash
- GNU Coreutils and GNU Findutils
- Cron for scheduled execution
- Permission to list and access the log directory
- Write permission for the output directory

## Configuration

Edit the following variables in `access_size_check.sh`:

```bash
LOG_DIR="/LDAP/log"
SAVE_DIR="/LDAP/size"
```

The script selects files matching:

```text
access.YYYYMMDD-*
```

`YYYYMMDD` is the previous day's date. The active `access` file is excluded.

Selection is based on filenames, not timestamps inside the logs. A rotated file may contain records from more than one day.

## Installation

```bash
git clone https://github.com/prisma77/access_log_size.git
cd access_log_size
sudo mkdir -p /LDAP
sudo cp scripts/access_size_check.sh /LDAP/access_size_check.sh
sudo chmod +x /LDAP/access_size_check.sh
bash -n /LDAP/access_size_check.sh
```

Set `LOG_DIR` and `SAVE_DIR` for the target server before running the script.

## CSV Output

Results are appended to:

```text
/LDAP/size/YYMM_hostname.csv
```

Example:

```csv
DATE,HOSTNAME,SIZE_MB,LOG_COUNT
261024,ldap01,0,0
261025,ldap01,40,1
261026,ldap01,200,5
```

| Column | Description |
|---|---|
| `DATE` | Previous day's date in `YYMMDD` format |
| `HOSTNAME` | Short hostname from `hostname -s` |
| `SIZE_MB` | Total size in integer MiB |
| `LOG_COUNT` | Number of matching files that pass the regular-file check |

`SIZE_MB` uses 1,048,576 bytes per MiB. File sizes are added before the fractional part is discarded. A total below 1 MiB is recorded as `0`.

`LOG_COUNT` includes files whose size check fails.

Running the script again appends another row for the same date.

### Updating from the Three-Column Version

The new CSV adds `LOG_COUNT` as the fourth column.

Existing CSV headers and old rows are not updated automatically. Preserve the old CSV separately before starting a new four-column CSV. Old records have no recorded file count; missing counts should not be treated as zero.

## Diagnostic Log

Diagnostic records are appended to:

```text
/LDAP/size/YYMM_hostname.log
```

Both output filenames use the previous day's year and month. Each run is identified by its process ID (`pid`).

| Record | Description |
|---|---|
| `START / END` | Run start and end |
| `PATH` | Search pattern and CSV path |
| `READ / FILE` | File checked and size in bytes |
| `TOTAL` | File count, size check errors, and total size |
| `CSV_OK` | CSV row successfully written |
| `WARN / ERROR / SKIP` | Warnings, failures, and skipped paths |
| `CLEANUP_OK` | Previous-year CSV and diagnostic log cleanup completed |

Example:

```text
pid=1234 READ file=/LDAP/log/access.20261026-120000
pid=1234 FILE bytes=41943040 file=/LDAP/log/access.20261026-120000
pid=1234 TOTAL files=1 stat_errors=0 bytes=41943040 size_mb=40
pid=1234 CSV_OK row=261026,ldap01,40,1 file=/LDAP/size/2610_ldap01.csv
```

`CSV_OK` confirms the row was written. It does not confirm that every expected file was collected.

Missing files or failed size checks may produce zero or partial totals. Check `TOTAL`, `WARN`, `ERROR`, and `SKIP` when investigating a result.

## Scheduled Execution

Open the crontab for the account that will run the script:

```bash
crontab -e
```

Example: run daily at 23:00.

```cron
0 23 * * * /LDAP/access_size_check.sh
```

Verify the entry:

```bash
crontab -l
```

Choose the execution time based on the server's log rotation policy. The example time does not guarantee that all previous-day files have finished rotating.

If changing an existing schedule, replace its entry to avoid running the script twice.

## Yearly Cleanup

When the script reaches the cleanup step on February 1, it deletes the previous year's monthly CSV and diagnostic log files for the current hostname from `SAVE_DIR`.

February 1 processes January 31, so cleanup takes place on February 1.

Raw access logs are not deleted by this script.
