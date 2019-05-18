FROM registry.access.redhat.com/ubi7/ubi
MAINTAINER Percona Development <info@percona.com>

LABEL name="Percona XtraBackup" \
      release="2.4" \
      vendor="Percona" \
      summary="Percona XtraBackup is an open-source hot backup utility for MySQL - based servers that doesn’t lock your database during the backup" \
      description="Percona XtraBackup works with MySQL, MariaDB, and Percona Server. It supports completely non-blocking backups of InnoDB, XtraDB, and HailDB storage engines. In addition, it can back up the following storage engines by briefly pausing writes at the end of the backup: MyISAM, Merge, and Archive, including partitioned tables, triggers, and database options."

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
ENV XTRABACKUP_VERSION 2.4.14-1.el7
ENV KUBECTL_VERSION=v1.14.1
ENV KUBECTL_MD5SUM=223668b6d47121a9011645b04f5ef349

# we need licenses from docs
RUN sed -i '/nodocs/d' /etc/yum.conf

RUN yum install -y --disableplugin=subscription-manager \
        http://mirror.centos.org/centos/7/os/x86_64/Packages/numactl-libs-2.0.9-7.el7.x86_64.rpm \
        http://mirror.centos.org/centos/7/extras/x86_64/Packages/libev-4.15-7.el7.x86_64.rpm
RUN yum update -y --disableplugin=subscription-manager \
    && yum install -y --disableplugin=subscription-manager \
        Percona-XtraDB-Cluster-57-${PXC_VERSION} \
        Percona-XtraDB-Cluster-garbd-57-${PXC_VERSION} \
        percona-xtrabackup-24-${XTRABACKUP_VERSION} \
        socat \
        hostname \
    && yum clean all \
    && rm -rf /var/cache/yum /var/lib/mysql

COPY LICENSE /licenses/LICENSE.Dockerfile
RUN cp /usr/share/doc/Percona-XtraDB-Cluster-server-57-*/COPYING /licenses/LICENSE.Percona-XtraDB-Cluster \
    && cp /usr/share/doc/percona-xtradb-cluster-galera/COPYING /licenses/LICENSE.galera \
    && cp /usr/share/doc/percona-xtradb-cluster-galera/LICENSE.* /licenses/

RUN curl -o /usr/bin/kubectl \
        https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x /usr/bin/kubectl \
    && echo "${KUBECTL_MD5SUM} /usr/bin/kubectl" | md5sum -c - \
    && curl -o /licenses/LICENSE.kubectl \
        https://raw.githubusercontent.com/kubernetes/kubectl/master/LICENSE

RUN install -d -o 1001 -g 0 -m 0775 /backup
COPY mc /usr/bin/
COPY recovery-*.sh backup.sh get-pxc-state peer-list /usr/bin/

VOLUME ["/backup"]
USER 1001

CMD ["sleep","infinity"]
