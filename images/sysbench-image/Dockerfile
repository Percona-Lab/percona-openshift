FROM ubuntu:16.04
MAINTAINER Percona Development <info@percona.com>

RUN apt-get update && apt-get install -y --force-yes --no-install-recommends \
                apt-transport-https ca-certificates \
                pwgen curl gnupg git iputils-ping mysql-client \
        && rm -rf /var/lib/apt/lists/*

RUN curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | bash
RUN apt -y install sysbench
RUN git clone https://github.com/Percona-Lab/sysbench-tpcc.git /sysbench/sysbench-tpcc

RUN chgrp -R 0 /sysbench && chmod -R g=u /sysbench 

WORKDIR /sysbench

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
