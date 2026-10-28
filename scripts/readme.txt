LDAP Access Log Size Check
==========================

1. Path

Script:
  /LDAP/access_size_check.sh

Access log:
  /LDAP/log

CSV:
  /LDAP/size/YYMM_hostname.csv

Log:
  /LDAP/size/YYMM_hostname.log


2. CSV Format

DATE,HOSTNAME,SIZE_MB,LOG_COUNT
260901,ldap01,0,0
260902,ldap01,40,1
260903,ldap01,200,5
...

LOG_COUNT is the number of previous-day files matching access.YYYYMMDD-*.
Only regular files are counted, including files whose size check fails.
Existing CSV headers and old rows are not updated automatically.


3. Crontab

Run the script once a day at the preferred time.
The script processes the previous day's access logs.


4. Environment Change

Change LOG_DIR and SAVE_DIR for another environment.

  LOG_DIR="/LDAP/log"
  SAVE_DIR="/LDAP/size"


5. Permission

  chmod +x /LDAP/access_size_check.sh


6. Cleanup

Delete the previous year CSV files and log files on January 2.


7. Script Log

Save results to a monthly log file
YYMM uses yesterday's year and month.
Each run shows its process ID (PID).

  START / END : Start and end time, server, user and log date.
  PATH        : Access log search path and CSV file path.
  READ / FILE : File name and size in bytes.
  TOTAL       : File count, size check errors and total size.
  CSV_OK      : Data saved to the CSV file.
  WARN / ERROR / SKIP : Warnings, errors and skipped files.
  CLEANUP_OK  : Old CSV file cleanup finished.

CSV_OK means the CSV was saved. Check TOTAL and errors.
If files are missing or size checks fail, the CSV may show 0 or a smaller total.

Example:
pid=7477 READ file=/LDAP/log/access.20261020-235500
pid=7477 FILE bytes=43407906 file=/LDAP/log/access.20261020-235500
pid=7477 TOTAL files=288 stat_errors=0 bytes=12087648912 size_mb=11527
pid=7477 CSV_OK row=261020,2021dsldap01,11527,288 file=/LDAP/size/2610_2021dsldap01.csv
pid=7477 END time=2026-10-21 16:28:02 +0900 files=288 stat_errors=0

==========================

vi /LDAP/access_size_check.sh

chmod +x /LDAP/access_size_check.sh

crontab -e

0 23 * * * /LDAP/access_size_check.sh

crontab -l