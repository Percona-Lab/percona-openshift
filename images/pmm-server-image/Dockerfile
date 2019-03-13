FROM golang:1.11.1
RUN go get github.com/michaloo/go-cron
RUN mv bin/go-cron /usr/bin/go-cron

FROM percona/pmm-server:1.17.1
COPY --from=0 /usr/bin/go-cron /usr/bin/go-cron
COPY supervisord.conf-rootless /etc/supervisord.d/pmm.ini
COPY entrypoint.sh-rootless /opt/entrypoint.sh

RUN touch \
    /etc/percona-rds-exporter.yml \
    /var/log/mysql.log \
    /var/log/consul.log \
    /var/log/nginx.log \
    /var/log/cron1.log \
    /var/log/cron2.log \
    /var/log/qan-api.log \
    /var/log/logrotate.log \
    /var/log/prometheus.log \
    /var/log/prometheus1.log \
    /var/log/createdb.log \
    /var/log/createdb2.log \
    /var/log/createdb3.log \
    /var/log/orchestrator.log \
    /var/log/entrypoint.sh.log \
    /var/log/purge-qan-data.log \
    /var/log/dashboard-upgrade.log \
    /var/log/node_exporter.log \
    /var/log/pmm-manage.log \
    /var/log/pmm-managed.log
RUN chown -R pmm:pmm \
    /etc/grafana \
    /etc/supervisord.d \
    /etc/prometheus.yml \
    /etc/prometheus1.yml \
    /etc/orchestrator.conf.json \
    /etc/cron.daily/purge-qan-data \
    /var/log \
    /var/lib \
    /opt \
    /srv \
    /var/run/mysqld \
    /var/run/supervisor \
    /var/lib/mysql \
    /var/lib/grafana \
    /var/log/grafana \
    /usr/share/grafana/public/img \
    /var/log/supervisor \
    /usr/local/percona/qan-agent \
    /etc/percona-rds-exporter.yml \
    /var/log/mysql.log \
    /var/log/consul.log \
    /var/log/nginx.log \
    /var/log/cron1.log \
    /var/log/cron2.log \
    /var/log/qan-api.log \
    /var/log/logrotate.log \
    /var/log/prometheus.log \
    /var/log/prometheus1.log \
    /var/log/createdb.log \
    /var/log/createdb2.log \
    /var/log/createdb3.log \
    /var/log/orchestrator.log \
    /var/log/entrypoint.sh.log \
    /var/log/purge-qan-data.log \
    /var/log/dashboard-upgrade.log \
    /var/log/node_exporter.log \
    /var/log/pmm-manage.log \
    /var/log/pmm-managed.log
RUN chmod -R g+w \
    /etc/grafana \
    /etc/supervisord.d \
    /etc/prometheus.yml \
    /etc/prometheus1.yml \
    /etc/orchestrator.conf.json \
    /etc/cron.daily/purge-qan-data \
    /var/log \
    /var/lib \
    /opt \
    /srv \
    /var/run/mysqld \
    /var/run/supervisor \
    /var/lib/mysql \
    /var/lib/grafana \
    /var/log/grafana \
    /usr/share/grafana/public/img \
    /var/log/supervisor \
    /usr/local/percona/qan-agent \
    /etc/percona-rds-exporter.yml \
    /var/log/mysql.log \
    /var/log/consul.log \
    /var/log/nginx.log \
    /var/log/cron1.log \
    /var/log/cron2.log \
    /var/log/qan-api.log \
    /var/log/logrotate.log \
    /var/log/prometheus.log \
    /var/log/prometheus1.log \
    /var/log/createdb.log \
    /var/log/createdb2.log \
    /var/log/createdb3.log \
    /var/log/orchestrator.log \
    /var/log/entrypoint.sh.log \
    /var/log/purge-qan-data.log \
    /var/log/dashboard-upgrade.log \
    /var/log/node_exporter.log \
    /var/log/pmm-manage.log \
    /var/log/pmm-managed.log

# allow to disable http2
RUN chown pmm:pmm /etc/nginx/conf.d/pmm.conf \
    && chmod g+w /etc/nginx/conf.d/pmm.conf
# needed for replace effective uid cmd on openshift
RUN chmod g+w /etc/passwd
# needed for rsync & rm cmd on openshift
RUN chmod -R g+rwx \
    /var/lib/mysql \
    /var/lib/grafana
# needed for start services on openshift
RUN chmod -R g+rwx \
    /etc/grafana \
    /home/pmm
# needed for createdb jobs & logrotate
RUN printf "[client]\nuser=root\n" > /home/pmm/.my.cnf

# run rootless nginx
RUN sed -i -e 's^80^8080^; s^443^8443^' /etc/nginx/conf.d/pmm.conf
RUN sed -i -e 's^/run/nginx.pid^/var/run/nginx/nginx.pid^' /etc/nginx/nginx.conf
RUN install -o pmm -g pmm -m 0775 -d \
    /var/lib/nginx/tmp \
    /var/lib/nginx \
    /var/run/nginx \
    /var/log/nginx
RUN rm -rf /var/log/nginx/*.log

EXPOSE 8080 8443
USER pmm
