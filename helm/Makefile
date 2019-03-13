pmm:
	rm -rf percona-charts
	mkdir percona-charts
	gsutil rsync gs://percona-charts/ percona-charts/
	helm package -u -d percona-charts pmm-server
	helm repo index --url https://percona-charts.storage.googleapis.com --merge percona-charts/index.yaml percona-charts
	gsutil rsync percona-charts/ gs://percona-charts/
