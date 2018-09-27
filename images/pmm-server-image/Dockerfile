FROM golang:latest
RUN go get github.com/michaloo/go-cron
RUN mv bin/go-cron /usr/bin/go-cron

FROM percona/pmm-server:1.14.1

COPY --from=0 /usr/bin/go-cron /usr/bin/go-cron
COPY supervisord.conf-rootless /etc/supervisord.d/pmm.ini
COPY entrypoint.sh-rootless /opt/entrypoint.sh
RUN sed -i -e 's^unix:///var/run/supervisor/supervisor.sock^unix:///tmp/supervisord.sock^' /etc/supervisord.conf
RUN sed -i -e 's^80^8080^; s^443^8443^' /etc/nginx/conf.d/pmm.conf
RUN sed -i -e 's^/run/nginx.pid^/var/run/nginx/nginx.pid^' /etc/nginx/nginx.conf
RUN install -d -o pmm -g pmm \
    /var/run/nginx
RUN printf "[client]\nuser=root\n" > /opt/.my.cnf

RUN touch \
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
    /var/log/purge-qan-data.log \
    /var/log/dashboard-upgrade.log \
    /var/log/node_exporter.log \
    /var/log/pmm-manage.log \
    /var/log/pmm-managed.log

RUN chown -R pmm:pmm \
    /etc/grafana \
    /etc/supervisord.d/pmm.ini \
    /etc/prometheus.yml \
    /etc/orchestrator.conf.json \
    /etc/cron.daily/purge-qan-data \
    /var/lib \
    /opt \
    /srv \
    /var/run/mysqld \
    /var/lib/nginx \
    /var/lib/mysql \
    /var/lib/grafana \
    /var/log/nginx \
    /var/log/grafana \
    /var/log/supervisor \
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
    /var/log/purge-qan-data.log \
    /var/log/dashboard-upgrade.log \
    /var/log/node_exporter.log \
    /var/log/pmm-manage.log \
    /var/log/pmm-managed.log

USER pmm
