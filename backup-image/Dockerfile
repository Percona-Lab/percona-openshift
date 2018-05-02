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
  && yum install -y percona-xtrabackup-24 nmap curl vim \
  && yum clean all -y && rm -rf /var/cache/yum

RUN mkdir -p /backup && chown -R 1001 /backup && chgrp -R 0 /backup && chmod -R g=u /backup

ADD backup.sh /usr/bin/

VOLUME ["/backup"]

USER 1001

CMD ["sleep","infinity"]
