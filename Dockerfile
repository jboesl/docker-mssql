FROM microsoft/mssql-server-linux:latest

ENV \
  ACCEPT_EULA=Y \
  container=docker \
  LANG='C.UTF-8' \
  LC_ALL='C.UTF-8' \
  LANGUAGE='C.UTF-8'

RUN \
  locale-gen en_US.UTF-8 && \
  update-locale && \
  apt-get update && \
  apt-get install -y sudo python curl apt-transport-https && \
  curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
  curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | tee /etc/apt/sources.list.d/msprod.list && \
  apt-get update && \
  apt-get install -y mssql-tools && \
  rm -rf /var/lib/apt/lists/*

COPY ./init /init

EXPOSE 1433

CMD ["/init/start.sh"]