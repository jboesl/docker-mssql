
Based on the mssql-server-linux container from microsoft (https://hub.docker.com/r/microsoft/mssql-server-linux)
but with mssql-tools installed and ready to used database.
This is image is intended for testing only.

##### To run:

`docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=yourStrong123Password' -p 1433:1433 -d jboesl/docker-mssql-linux`

System adminitrator login `sa`

System administrator password: `$SA_PASSWORD`

##### Environment variables:

`$MSSQL_DB=testdb`

`$MSSQL_USER=tester`

`$MSSQL_PASSWORD=My@Super@Secret`