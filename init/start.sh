#!/bin/bash

ACCEPT_EULA=${ACCEPT_EULA:-}
SA_PASSWORD=${SA_PASSWORD:-}

# Check the EULA
#
if [ "$ACCEPT_EULA" != "Y" ] && [ "$ACCEPT_EULA" != "y" ]; then
	echo "ERROR: You must accept the End User License Agreement before this container" > /dev/stderr
	echo "can start. The End User License Agreement can be found at " > /dev/stderr
	echo "http://go.microsoft.com/fwlink/?LinkId=746388." > /dev/stderr
	echo ""
	echo "Set the environment variable ACCEPT_EULA to 'Y' if you accept the agreement." > /dev/stderr
	exit 1
fi

/opt/mssql/bin/sqlservr-setup --accept-eula --set-sa-password
retcode=$?
if [ ${retcode} != 0 ]; then
  exit ${retcode}
fi


/opt/mssql/bin/sqlservr  > /var/opt/mssql/log/serverstart.log &

echo =============== MSSQL SERVER STARTING            ===============
#waiting for mssql to start
export STATUS=0
i=0
while [[ $STATUS -eq 0 ]] && [[ $i -lt 30 ]]; do
	sleep 1
	i=$i+1
	STATUS=$(grep 'Server setup is completed' /var/opt/mssql/log/setup*.log | wc -l)
done


if [ ! -z $MSSQL_USER ]; then
	echo "MSSQL_USER: $MSSQL_USER"
else
	MSSQL_USER=tester
	echo "MSSQL_USER: $MSSQL_USER"
fi

if [ ! -z $MSSQL_PASSWORD ]; then
	echo "MSSQL_PASSWORD: $MSSQL_PASSWORD"
else
	MSSQL_PASSWORD=My@Super@Secret
	echo "MSSQL_PASSWORD: $MSSQL_PASSWORD"
fi

if [ ! -z $MSSQL_DB ]; then
	echo "MSSQL_DB: $MSSQL_DB"
else
	MSSQL_DB=testdb
	echo "MSSQL_DB: $MSSQL_DB"
fi


if [ ! -f /opt/mssql/initout.log ]; then
  echo =============== CREATING INIT DATA               ===============
  sed -i s/"{MSSQL_USER}"/"${MSSQL_USER}"/g /init/init.sql
  sed -i s/"{MSSQL_PASSWORD}"/"${MSSQL_PASSWORD}"/g /init/init.sql
  sed -i s/"{MSSQL_DB}"/"${MSSQL_DB}"/g /init/init.sql
  /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -t 30 -i"/init/init.sql" -o"/opt/mssql/initout.log"
  echo =============== INIT DATA CREATED 				        ===============
fi


echo =============== MSSQL SERVER SUCCESSFULLY STARTED ===============

#trap 
while [ "$END" == '' ]; do
			sleep 1
			trap "/opt/mssql/bin/sqlservr stop && END=1" INT TERM
done