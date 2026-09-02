LDAP Access Log Size Check
==========================

1. Path

Script:
  /LDAP/access_size_check.sh

Access log:
  /LDAP/log

CSV:
  /LDAP/size/YYMM_hostname.csv


2. CSV Format

DATE,HOSTNAME,SIZE_MB
260901,ldap01,10000
260902,ldap01,500
...


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

Delete the previous year CSV files on January 2.

==========================

vi /LDAP/access_size_check.sh

chmod +x /LDAP/access_size_check.sh

crontab -e

0 4 * * * /LDAP/access_size_check.sh

crontab -l