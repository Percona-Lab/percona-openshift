FROM registry.access.redhat.com/ubi7/ubi
MAINTAINER Percona Development <info@percona.com>

LABEL name="ProxySQL" \
      release="2.0" \
      vendor="Percona" \
      summary="High-performance MySQL proxy with a GPL license" \
      description="ProxySQL is a high performance, high availability, protocol aware proxy for MySQL and forks (like Percona Server and MariaDB). All the while getting the unlimited freedom that comes with a GPL license."

RUN groupadd -g 1001 proxysql
RUN useradd -u 1001 -r -g 1001 -s /sbin/nologin \
            -c "Default Application User" proxysql

# check repository package signature in secure way
RUN export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A \
    && gpg --export --armor 430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A > ${GNUPGHOME}/RPM-GPG-KEY-Percona \
    && rpmkeys --import ${GNUPGHOME}/RPM-GPG-KEY-Percona \
    && curl -L -o /tmp/percona-release.rpm https://repo.percona.com/percona/yum/percona-release-0.1-10.noarch.rpm \
    && rpmkeys --checksig /tmp/percona-release.rpm \
    && yum install -y --disableplugin=subscription-manager /tmp/percona-release.rpm \
    && rm -rf "$GNUPGHOME" /tmp/percona-release.rpm \
    && rpm --import /etc/pki/rpm-gpg/PERCONA-PACKAGING-KEY

# install exact version of PS for repeatability
ENV PROXYSQL_VERSION 2.0.3-1.1.el7
ENV PS_VERSION 5.7.25-28.1.el7

# we need licenses from docs
RUN sed -i '/nodocs/d' /etc/yum.conf

RUN yum update -y --disableplugin=subscription-manager \
    && yum install -y --disableplugin=subscription-manager \
        Percona-Server-client-57-${PS_VERSION} \
        Percona-Server-shared-57-${PS_VERSION} \
        which \
        proxysql2-${PROXYSQL_VERSION} \
    && yum clean all \
    && rm -rf /var/cache/yum /var/lib/mysql

COPY LICENSE /licenses/LICENSE.Dockerfile
RUN cp /usr/share/doc/proxysql2-2.0.3/LICENSE /licenses/LICENSE.proxysql

COPY proxysql.cnf /etc/proxysql/proxysql.cnf
COPY proxysql-admin.cnf /etc/proxysql-admin.cnf
RUN chmod 664 /etc/proxysql/proxysql.cnf /etc/proxysql-admin.cnf \
    && chown 1001:1001 /etc/proxysql/proxysql.cnf /etc/proxysql-admin.cnf

COPY proxysql-entry.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY add_pxc_nodes.sh /usr/bin/add_pxc_nodes.sh
RUN chmod a+x /usr/bin/add_pxc_nodes.sh

COPY add_proxysql_nodes.sh /usr/bin/add_proxysql_nodes.sh
RUN chmod a+x /usr/bin/add_proxysql_nodes.sh

COPY proxysql-admin /usr/bin/proxysql-admin
RUN chmod a+x /usr/bin/proxysql-admin

COPY peer-list /usr/bin/peer-list

RUN install -o 1001 -g 0 -m 775 -d /etc/proxysql /var/lib/proxysql
VOLUME /var/lib/proxysql

EXPOSE 3306 6032

ENTRYPOINT ["/entrypoint.sh"]
USER 1001

CMD [ "/usr/bin/proxysql", "-f", "-c", "/etc/proxysql/proxysql.cnf" ]
