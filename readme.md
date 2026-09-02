# LDAP Access Log Size Collector

A Bash script that calculates the total size of the previous day's LDAP access logs and stores the result in a monthly CSV file.

## Features

- Processes the previous day's rotated access logs
- Calculates log sizes in bytes before converting to MB
- Adds the hostname to each CSV record
- Creates a separate CSV file for each month and hostname
- Appends one daily record to the monthly CSV file
- Automatically creates a new CSV file when the month changes
- Deletes the previous year's CSV files on January 2
- Runs automatically with Cron or Crond
- Supports a user-defined daily execution time

## Log File Format

The script processes rotated access logs with the following filename format:

```text
access.YYYYMMDD-HHMMSS
```

Example:

```text
access.20260901-000000
access.20260901-000500
access.20260901-001000
```

The active `access` file is not included because it can contain records from the current day.

## Configuration

Edit the following variables in `access_size_check.sh`:

```bash
LOG_DIR="/LDAP/log"
SAVE_DIR="/LDAP/size"
```

- `LOG_DIR`: Directory containing the LDAP access logs
- `SAVE_DIR`: Directory where monthly CSV files are stored

The script automatically gets the short hostname using:

```bash
hostname -s
```

## Output File

CSV filename format:

```text
YYMM_hostname.csv
```

Example:

```text
2609_ldap01.csv
```

CSV content:

```csv
DATE,HOSTNAME,SIZE_MB
260901,ldap01,10000
260902,ldap01,500
260903,ldap01,11527
```

- `DATE`: Date of the processed access logs
- `HOSTNAME`: Short hostname of the server
- `SIZE_MB`: Total log size converted to integer MB

`SIZE_MB` is calculated using `1024 × 1024` bytes and stored as an integer.

## Installation

Clone the repository:

```bash
git clone https://github.com/prisma77/access_log_size.git
```

Move to the repository:

```bash
cd access_log_size
```

Copy the script to `/LDAP`:

```bash
sudo cp scripts/access_size_check.sh /LDAP/access_size_check.sh
```

Set execute permission:

```bash
sudo chmod +x /LDAP/access_size_check.sh
```

Check the Bash syntax:

```bash
bash -n /LDAP/access_size_check.sh
```

No output means the syntax is valid.

## Crontab Configuration

Open the Crontab editor:

```bash
crontab -e
```

Run the script once a day at the preferred time.

The following example runs the script every day at 04:00:

```cron
0 4 * * * /LDAP/access_size_check.sh
```

The script processes the previous day's rotated access logs, so it can run at any preferred time on the following day.

Change `/LDAP/access_size_check.sh` if the script is installed in a different directory.

Verify the registered Crontab:

```bash
crontab -l
```

## Daily Processing

The script performs the following steps:

1. Gets the server hostname
2. Calculates the previous day's date
3. Finds the previous day's rotated access logs
4. Adds all matching file sizes in bytes
5. Converts the total size to integer MB
6. Creates the monthly CSV file if it does not exist
7. Appends the date, hostname, and size to the CSV file

Example:

```text
Script execution date: 2026-09-02
Processed log date:    2026-09-01
Log filename pattern:  access.20260901-*
CSV filename:          2609_ldap01.csv
CSV record:            260901,ldap01,10000
```

## Monthly File Creation

When the processed log month changes, the script automatically creates a new CSV file.

Example:

```text
2609_ldap01.csv
2610_ldap01.csv
```

The September results are stored in `2609_ldap01.csv`, and the October results are stored in `2610_ldap01.csv`.

## Yearly Cleanup

On January 2, the script deletes CSV files created during the previous year for the current hostname.

January 2 is used because the January 1 execution processes the previous year's December 31 access logs.

Example files before cleanup:

```text
2609_ldap01.csv
2610_ldap01.csv
2701_ldap01.csv
```

After the script runs on January 2, 2027:

```text
2701_ldap01.csv
```

The following files are deleted:

```text
2609_ldap01.csv
2610_ldap01.csv
```

## Requirements

- Linux
- Bash
- GNU Coreutils
- Cron or Crond
- Read permission for the LDAP access log directory
- Write permission for the CSV output directory

The script uses GNU commands including:

```text
date -d
stat -c
```

## Quick Setup

```bash
git clone https://github.com/prisma77/access_log_size.git
```

```bash
cd access_log_size
```

```bash
sudo cp scripts/access_size_check.sh /LDAP/access_size_check.sh
```

```bash
sudo chmod +x /LDAP/access_size_check.sh
```

```bash
crontab -e
```

Example schedule:

```cron
0 4 * * * /LDAP/access_size_check.sh
```

Verify the schedule:

```bash
crontab -l
```

## License

This project is provided for system monitoring and administrative use.
