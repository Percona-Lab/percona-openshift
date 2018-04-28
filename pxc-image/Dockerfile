FROM centos:7
MAINTAINER Percona Development <info@percona.com>
LABEL vendor=Percona
LABEL com.percona.package="Percona XtraDB Cluster"
LABEL com.percona.version="5.7"
LABEL io.k8s.description="Percona XtraDB Cluster is an active/active high availability and high scalability open source solution for MySQL clustering"
LABEL io.k8s.display-name="Percona XtraDB Cluster 5.7"

# the numeric UID is needed for OpenShift
RUN groupadd -g 1001 mysql 
RUN useradd -u 1001 -r -g 1001 -s /sbin/nologin \
            -c "Default Application User" mysql

ARG REPO_URL=http://www.percona.com/downloads/percona-release/redhat/0.1-4/percona-release-0.1-4.noarch.rpm

# Install server
RUN yum install -y $REPO_URL \
  && yum install -y Percona-XtraDB-Cluster-57 curl vim \
  && yum clean all && mkdir -p /etc/mysql/conf.d/ && chown -R 1001 /etc/mysql/ && mkdir -p /var/log/mysql \
  && chown -R 1001 /var/lib/mysql /var/run/mysqld /etc/mysql/conf.d/ /var/log/mysql \
  && chgrp -R 0 /var/lib/mysql /var/run/mysqld /etc/mysql/ /var/log/mysql \
  && chmod -R g=u /var/lib/mysql /var/run/mysqld /etc/mysql/ /var/log/mysql 

ADD node.cnf /etc/mysql/node.cnf
RUN echo '!include /etc/mysql/node.cnf' > /etc/my.cnf
RUN echo '!includedir /etc/mysql/conf.d/' >> /etc/my.cnf

COPY entrypoint.sh /entrypoint.sh
COPY dockerdir /

EXPOSE 3306 4567 4568

ENTRYPOINT ["/entrypoint.sh"]

USER 1001

CMD [""]
