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
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A \
	&& gpg --export --armor 430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A > ${GNUPGHOME}/RPM-GPG-KEY-Percona \
	&& rpmkeys --import ${GNUPGHOME}/RPM-GPG-KEY-Percona /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 \
	&& curl -L -o /tmp/percona-release.rpm http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm \
	&& rpmkeys --checksig /tmp/percona-release.rpm \
	&& yum install -y /tmp/percona-release.rpm \
	&& rm -rf "$GNUPGHOME" /tmp/percona-release.rpm

# install exact version of PS for repeatability
ENV PXC_VERSION 5.7.23-31.31.2.el7
ENV XTRABACKUP_VERSION 2.4.9-1.el7
ENV KUBECTL_VERSION=v1.13.1
ENV KUBECTL_MD5SUM=5cbe45fdb1e59466eea77a3ba34d1f23

RUN yum install -y \
		Percona-XtraDB-Cluster-client-57-${PXC_VERSION} \
		percona-xtrabackup-24-${XTRABACKUP_VERSION} \
		nmap \
	&& yum clean all \
	&& rm -rf /var/cache/yum

RUN curl -o /usr/bin/kubectl \
		https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
	&& chmod +x /usr/bin/kubectl \
	&& echo "${KUBECTL_MD5SUM} /usr/bin/kubectl" | md5sum -c -

RUN install -d -o 1001 -g 0 -m 0775 /backup
ADD backup.sh /usr/bin/

VOLUME ["/backup"]
USER 1001
CMD ["sleep","infinity"]
