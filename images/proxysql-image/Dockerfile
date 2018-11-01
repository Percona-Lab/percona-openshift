FROM centos:7
MAINTAINER Percona Development <info@percona.com>

# the numeric UID is needed for OpenShift
RUN groupadd -g 1001 proxysql
RUN useradd -u 1001 -r -g 1001 -s /sbin/nologin \
            -c "Default Application User" proxysql


#RUN yum install -y https://github.com/sysown/proxysql/releases/download/v1.2.1/proxysql-1.2.1-1-centos7.x86_64.rpm

RUN rpmkeys --import https://www.percona.com/downloads/RPM-GPG-KEY-percona
RUN yum install -y https://www.percona.com/redir/downloads/percona-release/redhat/latest/percona-release-0.1-6.noarch.rpm
RUN yum install -y Percona-Server-client-56 proxysql vim curl sysvinit-tools && mkdir -p /etc/proxysql/ && \
    chown -R 1001:0 /etc/proxysql* && chown -R 1001:0 /var/lib/proxysql

ADD proxysql.cnf /etc/proxysql/proxysql.cnf
ADD proxysql-admin.cnf /tmp/proxysql-admin.cnf

# removed, main branch now // a temporary hack, to be removed when it is in the main branch
RUN curl https://raw.githubusercontent.com/percona/proxysql-admin-tool/v1.4.11/proxysql-admin --output /usr/bin/proxysql-admin
RUN sed -i '23 {s/^/#/}' /usr/bin/proxysql-admin

COPY proxysql-entry.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY add_cluster_nodes.sh /usr/bin/add_cluster_nodes.sh
RUN chmod a+x /usr/bin/add_cluster_nodes.sh

COPY peer-list /usr/bin/peer-list
RUN chmod a+x /usr/bin/peer-list

RUN chown -R 1001 /etc/proxysql* \
  && chgrp -R 0  /etc/proxysql* \
  && chmod -R g=u /etc/proxysql*

VOLUME /var/lib/proxysql

EXPOSE 3306 6032
ONBUILD RUN yum update -y

ENTRYPOINT ["/entrypoint.sh"]
USER 1001

CMD [""]
