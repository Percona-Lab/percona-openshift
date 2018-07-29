#/bin/bash

helmDir="../../helm/helm-server/"

function usage {
  cat << EOF
 usage: $0 [-h] -n "new restored cluster name" -d "backup directory (under /backup, do not include "/backup")" [-b "helm dir"] [-z]
 
 OPTIONS:
    -h        Show this message
    -s string new restored cluster name
    -d string backup path (run list_backups.sh to see the current directory)
EOF

}

while getopts :h:n:d: flag; do
  case $flag in
    d)
      backupDir="${OPTARG}";
      ;;
    n)
      clusterName="${OPTARG}";
      ;;
    b)
      helmDir="${OPTARG}";
      ;;
    h)
      usage;
      exit 0;
      ;;
    *)
      usage;
      exit 1;
      ;;
  esac
done
shift $((OPTIND -1))

if [ "$clusterName" == "" ]; then clusterName="restore1"; echo "cluster name is not defined, using restore1 as a cluster name"; fi
if [ "$backupDir"  == "" ]; then echo "backupDir is not defined, use -d <backup dir>"; usage; exit 1; fi

helm=$(command -v helm)

echo $helm

if [ "$helm" == "" ]
then
	echo "Helm is not installed. Exiting..."
	exit 0;
fi

$helm install --name $clusterName  --set backupDir="$backupDir"  $helmDir -f $helmDir/values.yaml

