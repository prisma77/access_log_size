# LDAP Access Log Size Collector

A Bash script that calculates the total daily size of LDAP access logs and stores the result in a monthly CSV file.

## Features

- Calculates log sizes in bytes before converting to MB
- Includes rotated logs and the current `access` file
- Creates a separate CSV file for each month and hostname
- Appends one daily record to the monthly CSV file
- Automatically creates a new CSV file when the month changes
- Deletes the previous year's CSV files on January 1
- Runs automatically with Crontab

## Log File Format

The script processes the following files:

```text
access
access.YYYYMMDD-HHMMSS
```

Example:

```text
access
access.20260901-000000
access.20260901-000500
access.20260901-001000
```

## Configuration

Edit the following variables in `access_size_check.sh`:

```bash
LOG_DIR="/LDAP/log"
SAVE_DIR="/LDAP/size"
```

- `LOG_DIR`: Directory containing LDAP access logs
- `SAVE_DIR`: Directory where monthly CSV files are stored

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
DATE,SIZE_MB
260901,66
260902,97
260903,473
```

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

Set execute permission:

```bash
chmod +x access_size_check.sh
```

Check the Bash syntax:

```bash
bash -n access_size_check.sh
```

No output means the syntax is valid.

## Crontab Configuration

Open the Crontab editor:

```bash
crontab -e
```

Add the following line to run the script every day at 23:59:

```cron
59 23 * * * /LDAP/access_size_check.sh
```

Change `/LDAP/access_size_check.sh` if the script is installed in a different directory.

Verify the registered Crontab:

```bash
crontab -l
```

## Daily Processing

The script performs the following steps:

1. Gets the current date and hostname
2. Finds the current day's rotated access logs
3. Includes the active `access` file
4. Adds all file sizes in bytes
5. Converts the total size to integer MB
6. Creates the monthly CSV file if it does not exist
7. Appends the daily result to the CSV file

## Monthly File Creation

When the month changes, the script automatically creates a new CSV file.

Example:

```text
2609_ldap01.csv
2610_ldap01.csv
```

## Yearly Cleanup

On January 1, the script deletes CSV files created during the previous year for the current hostname.

Example:

```text
2609_ldap01.csv
2610_ldap01.csv
```

The files above are deleted when the script runs on January 1, 2027.

The new file is then stored as:

```text
2701_ldap01.csv
```

## Requirements

- Linux
- Bash
- GNU Coreutils
- Cron or Crond
- Read permission for the LDAP access log directory
- Write permission for the CSV output directory

## License

This project is provided for system monitoring and administrative use.
