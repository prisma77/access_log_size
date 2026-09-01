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

DATE,SIZE_MB
260901,10000
260902,500


3. Crontab

Run every day at 23:59.


4. Environment Change

Change LOG_DIR and SAVE_DIR for another environment.

  LOG_DIR="/LDAP/log"
  SAVE_DIR="/LDAP/size"


5. Permission

  chmod +x /LDAP/access_size_check.sh


6. Cleanup

Delete the previous year CSV files on January 1.

==========================

vi /LDAP/access_size_check.sh

chmod +x /LDAP/access_size_check.sh

crontab -e

59 23 * * * /LDAP/access_size_check.sh

crontab -l