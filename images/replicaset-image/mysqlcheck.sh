#!/bin/bash 
# Grant privileges required:
# GRANT PROCESS ON *.* TO 'monitor'@'localhost' IDENTIFIED BY 'monitor';

mysqladmin -umonitor -p$MONITOR_PASSWORD -h127.0.0.1 ping
exit $?
