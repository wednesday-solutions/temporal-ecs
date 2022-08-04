#!/bin/bash

[ -z "$1" ] && echo "No Server Name argument supplied" && exit 1
[ -z "$2" ] && echo "No UI Name argument supplied" && exit 1
[ -z "$3" ] && echo "No ENV Name argument supplied" && exit 1

echo "Server Name: $1-app"

echo "UI Name: $2"

echo "Env Name: $3"

echo "Service Name: $1-svc"

SvcName="$1-svc"
AppName="$1-app"
UISvcName="$2-svc"

TemporalAddress="${SvcName}.${3}.${Ap`pName}.local:7233"



mkdir -p copilot/$SvcName/addons
cp base/serverManifest.yml copilot/$SvcName/manifest.yml
sed -i -r "s/someAppName/$SvcName/" copilot/$SvcName/manifest.yml
rm copilot/$SvcName/manifest.yml-r
cp base/database-cluster.yml copilot/$SvcName/addons/$SvcName-cluster.yml
cp base/opensearch.yml copilot/$SvcName/addons/$SvcName-opensearch.yml

mkdir -p copilot/$UISvcName
cp base/uiManifest.yml copilot/$UISvcName/manifest.yml
sed -i -r "s/someUiName/$UISvcName/" copilot/$UISvcName/manifest.yml
sed -i -r "s/someTemporalAddress/$TemporalAddress/" copilot/$UISvcName/manifest.yml
rm copilot/$UISvcName/manifest.yml-r

copilot init -a "$1-app" -t "Load Balanced Web Service" -n "$1-svc"
#
copilot env init --name $3 --profile default --default-config
#
copilot env deploy --name $3
## copilot storage init -n "$1-$3-cluster" -t Aurora -w "$1-svc" --engine PostgreSQL --initial-db "temporal"
#
copilot svc init -a "$1-app" -t "Load Balanced Web Service" -n "$2-svc"
#
echo "Deploying $1-svc"
copilot deploy --name "$1-svc" -e "$3"
#
echo "Deploying $2-svc"
copilot deploy --name "$2-svc" -e "$3"
