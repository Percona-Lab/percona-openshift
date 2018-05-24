FROM centos:7
MAINTAINER Percona Development <info@percona.com>
LABEL vendor=Percona
LABEL com.percona.package="Percona Server"
LABEL com.percona.version="5.7"
LABEL io.k8s.description="Percona Server is an advanced version of MySQL"
LABEL io.k8s.display-name="Percona Server 5.7"

# the numeric UID is needed for OpenShift
RUN groupadd -g 1001 mysql 
RUN useradd -u 1001 -r -g 1001 -s /sbin/nologin \
            -c "Default Application User" mysql

ARG REPO_URL=http://www.percona.com/downloads/percona-release/redhat/0.1-4/percona-release-0.1-4.noarch.rpm

# Install server
RUN yum install -y $REPO_URL \
  && yum install -y Percona-Server-server-57 Percona-Server-rocksdb-57 Percona-Server-tokudb-57 curl vim \
  percona-xtrabackup-24 nmap \
  && yum clean all -y && rm -rf /var/cache/yum \
  && mkdir -p /etc/mysql/conf.d/ && mkdir -p /var/log/mysql && mkdir -p /var/lib/mysql \
  && chown -R 1001 /etc/mysql/ /var/log/mysql /var/lib/mysql \
  && chgrp -R 0  /etc/mysql/ /var/log/mysql \
  && chmod -R g=u /etc/mysql/ /var/log/mysql

ADD node.cnf /etc/mysql/node.cnf
RUN echo '!include /etc/mysql/node.cnf' > /etc/my.cnf
RUN echo '!includedir /etc/mysql/conf.d/' >> /etc/my.cnf

ADD init-datadir.sh /usr/bin/init-datadir.sh
ADD mysqlcheck.sh /usr/bin/mysqlcheck.sh
ADD xtrabackup_nc.sh /usr/bin/xtrabackup_nc.sh

COPY entrypoint.sh /entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]

USER 1001

CMD [""]
