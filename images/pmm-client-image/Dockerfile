FROM centos:7
MAINTAINER Percona Development <info@percona.com>

RUN rpmkeys --import https://www.percona.com/downloads/RPM-GPG-KEY-percona
RUN yum install -y https://www.percona.com/redir/downloads/percona-release/redhat/0.1-4/percona-release-0.1-4.noarch.rpm
RUN yum install -y pmm-client procps initscripts && yum clean all

ONBUILD RUN yum update -y
