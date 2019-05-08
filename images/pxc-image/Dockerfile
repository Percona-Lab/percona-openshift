FROM registry.access.redhat.com/ubi7/ubi
MAINTAINER Percona Development <info@percona.com>

LABEL name="Percona XtraDB Cluster" \
      release="5.7" \
      vendor="Percona" \
      summary="Percona XtraDB Cluster is an active/active high availability and high scalability open source solution for MySQL clustering" \
      description="Percona XtraDB Cluster is a high availability solution that helps enterprises avoid downtime and outages and meet expected customer experience."

RUN groupadd -g 1001 mysql
RUN useradd -u 1001 -r -g 1001 -s /sbin/nologin \
        -c "Default Application User" mysql

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
ENV PXC_VERSION 5.7.25-31.35.1.el7

# we need licenses from docs
RUN sed -i '/nodocs/d' /etc/yum.conf

RUN yum install -y --disableplugin=subscription-manager \
        http://mirror.centos.org/centos/7/os/x86_64/Packages/numactl-libs-2.0.9-7.el7.x86_64.rpm \
        http://mirror.centos.org/centos/7/extras/x86_64/Packages/libev-4.15-7.el7.x86_64.rpm
RUN yum update -y --disableplugin=subscription-manager \
    && yum install -y --disableplugin=subscription-manager \
        Percona-XtraDB-Cluster-57-${PXC_VERSION} \
        jemalloc \
        socat \
        openssl \
        shadow-utils \
        hostname \
    && yum clean all \
    && rm -rf /var/cache/yum /var/lib/mysql

COPY LICENSE /licenses/LICENSE.Dockerfile
RUN cp /usr/share/doc/Percona-XtraDB-Cluster-server-57-*/COPYING /licenses/LICENSE.Percona-XtraDB-Cluster \
    && cp /usr/share/doc/percona-xtradb-cluster-galera/COPYING /licenses/LICENSE.galera \
    && cp /usr/share/doc/percona-xtradb-cluster-galera/LICENSE.* /licenses/

COPY dockerdir /
RUN mkdir -p /etc/mysql/conf.d/ /var/log/mysql /var/lib/mysql \
    && chown -R 1001:1001 /etc/mysql/ /var/log/mysql /var/lib/mysql \
    && chmod -R g=u /etc/mysql/ /var/log/mysql /var/lib/mysql

RUN echo '!include /etc/mysql/node.cnf' > /etc/my.cnf
RUN echo '!includedir /etc/mysql/conf.d/' >> /etc/my.cnf

EXPOSE 3306 4567 4568

ENTRYPOINT ["/entrypoint.sh"]

USER 1001

CMD [""]
