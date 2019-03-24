FROM centos:7
MAINTAINER Percona Development <info@percona.com>

LABEL vendor=Percona
LABEL com.percona.package="Percona XtraDB Cluster"
LABEL com.percona.version="5.7"
LABEL io.k8s.description="Percona XtraDB Cluster is an active/active high availability and high scalability open source solution for MySQL clustering"
LABEL io.k8s.display-name="Percona XtraDB Cluster 5.7"

RUN groupadd -g 1001 mysql
RUN useradd -u 1001 -r -g 1001 -s /sbin/nologin \
        -c "Default Application User" mysql

# check repository package signature in secure way
RUN export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A \
    && gpg --export --armor 430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A > ${GNUPGHOME}/RPM-GPG-KEY-Percona \
    && rpmkeys --import ${GNUPGHOME}/RPM-GPG-KEY-Percona /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 \
    && curl -L -o /tmp/percona-release.rpm https://repo.percona.com/percona/yum/percona-release-0.1-10.noarch.rpm \
    && rpmkeys --checksig /tmp/percona-release.rpm \
    && yum install -y /tmp/percona-release.rpm \
    && rm -rf "$GNUPGHOME" /tmp/percona-release.rpm \
    && rpm --import /etc/pki/rpm-gpg/PERCONA-PACKAGING-KEY \
    && percona-release enable-only original release

# install exact version of PS for repeatability
ENV PERCONA_VERSION 5.7.25-31.35.1.el7

# we need licenses from docs
RUN sed -i '/nodocs/d' /etc/yum.conf

RUN yum install -y \
        Percona-XtraDB-Cluster-57-${PERCONA_VERSION} \
        jemalloc \
        nmap \
    && yum clean all \
    && rm -rf /var/cache/yum /var/lib/mysql

COPY LICENSE /licenses/LICENSE.Dockerfile
RUN cp /usr/share/doc/Percona-XtraDB-Cluster-server-57-*/COPYING /licenses/LICENSE.Percona-XtraDB-Cluster \
    && cp /usr/share/doc/percona-xtradb-cluster-galera/COPYING /licenses/LICENSE.galera \
    && cp /usr/share/doc/percona-xtradb-cluster-galera/LICENSE.* /licenses/

RUN mkdir -p /etc/mysql/conf.d/ /var/log/mysql /var/lib/mysql \
    && chown -R 1001:0 /etc/mysql/ /var/log/mysql /var/lib/mysql \
    && chmod -R g=u /etc/mysql/ /var/log/mysql /var/lib/mysql

ADD node.cnf /etc/mysql/node.cnf
RUN echo '!include /etc/mysql/node.cnf' > /etc/my.cnf
RUN echo '!includedir /etc/mysql/conf.d/' >> /etc/my.cnf

COPY entrypoint.sh /entrypoint.sh
COPY dockerdir /

EXPOSE 3306 4567 4568

ENTRYPOINT ["/entrypoint.sh"]

USER 1001

CMD [""]
