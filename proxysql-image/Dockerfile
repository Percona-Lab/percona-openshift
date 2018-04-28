FROM centos:7
MAINTAINER Percona Development <info@percona.com>

# the numeric UID is needed for OpenShift
RUN useradd -u 1001 -r -g 0 -s /sbin/nologin \
            -c "Default Application User" proxysql

#RUN yum install -y https://github.com/sysown/proxysql/releases/download/v1.2.1/proxysql-1.2.1-1-centos7.x86_64.rpm

RUN rpmkeys --import https://www.percona.com/downloads/RPM-GPG-KEY-percona
RUN yum install -y https://www.percona.com/redir/downloads/percona-release/redhat/0.1-4/percona-release-0.1-4.noarch.rpm
RUN yum install -y Percona-Server-client-56 proxysql vim curl && chown -R 1001:0 /etc/proxysql* && chown -R 1001:0 /var/lib/proxysql

ADD proxysql.cnf /etc/proxysql.cnf

COPY proxysql-entry.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


COPY add_cluster_nodes.sh /usr/bin/add_cluster_nodes.sh
RUN chmod a+x /usr/bin/add_cluster_nodes.sh

COPY peer-list /usr/bin/peer-list
RUN chmod a+x /usr/bin/peer-list

VOLUME /var/lib/proxysql

EXPOSE 3306 6032
ONBUILD RUN yum update -y

ENTRYPOINT ["/entrypoint.sh"]
USER 1001

CMD [""]
