# LDAP Access Log Size Collector

A Bash script that collects the size and count of previous-day LDAP access log files and saves the results to a monthly CSV file.

Diagnostic logs record the files checked, collected sizes, and errors.

## Requirements

- Linux with Bash
- GNU Coreutils
- Cron for scheduled execution
- Permission to list and access the log directory
- Permission to create, write, and delete files in the output directory

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
| `CLEANUP_OK` | Cleanup command completed without error, including when target files were absent |

Example:

```text
pid=1234 READ file=/LDAP/log/access.20261026-120000
pid=1234 FILE bytes=41943040 file=/LDAP/log/access.20261026-120000
pid=1234 TOTAL files=1 stat_errors=0 bytes=41943040 size_mb=40
pid=1234 CSV_OK row=261026,ldap01,40,1 file=/LDAP/size/2610_ldap01.csv
pid=1234 CLEANUP_OK month=2510
```

`CSV_OK` confirms the row was written. It does not confirm that every expected file was collected.

Missing files or failed size checks may produce zero or partial totals. Check `TOTAL`, `WARN`, `ERROR`, and `SKIP` when investigating a result.

`CLEANUP_OK` does not mean that files were actually deleted. The `month` value identifies the cleanup target in `YYMM` format.

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

## Cleanup

Each run that reaches the cleanup step deletes the same month's CSV and diagnostic log from the previous year for the current hostname in `SAVE_DIR`.

The target month is calculated from the execution date, not the previous day's collection date.

| Execution month | Target files |
|---|---|
| November 2026 | `2511_hostname.csv` and `2511_hostname.log` |
| December 2026 | `2512_hostname.csv` and `2512_hostname.log` |
| January 2027 | `2601_hostname.csv` and `2601_hostname.log` |

Cleanup runs every day, not only on the first day of the month. If the target files were already deleted, `rm -f` completes without error and `CLEANUP_OK` is still recorded.

This is month-based cleanup. Entire monthly files are deleted; individual records are not retained for exactly one year.

Only the target month is checked. Other older files, including files missed during a full month without execution, are not removed by this cleanup.

If the cleanup date calculation or deletion command fails, the script logs an error and exits with status `1`.

Raw access logs are not deleted by this script.