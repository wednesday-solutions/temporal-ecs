#!/bin/bash

[ -z "$1" ] && echo "No Server Name argument supplied" && exit 1
[ -z "$2" ] && echo "No UI Name argument supplied" && exit 1
[ -z "$3" ] && echo "No ENV Name argument supplied" && exit 1
[ -z "$4" ] && echo "No APP Name argument supplied" && exit 1

echo "Server Name: $1-app"

echo "UI Name: $2"

echo "Env Name: $3"

echo "Service Name: $1-svc"

echo "App Name: $4"

SvcName="$1-svc"
AppName="$4"
UISvcName="$2-svc"

TemporalAddress="${SvcName}.${3}.${AppName}.local:7233"

mkdir -p copilot/$SvcName/addons
cp base/serverManifest.yml copilot/$SvcName/manifest.yml
sed -i -r "s/someAppName/$SvcName/" copilot/$SvcName/manifest.yml
rm copilot/$SvcName/manifest.yml-r
cp base/database-cluster.yml copilot/$SvcName/addons/$SvcName-cluster.yml #comment this if you dont want to create another rds for temporal
cp base/opensearch.yml copilot/$SvcName/addons/$SvcName-opensearch.yml

mkdir -p copilot/$UISvcName
cp base/uiManifest.yml copilot/$UISvcName/manifest.yml
sed -i -r "s/someUiName/$UISvcName/" copilot/$UISvcName/manifest.yml
sed -i -r "s/someTemporalAddress/$TemporalAddress/" copilot/$UISvcName/manifest.yml
rm copilot/$UISvcName/manifest.yml-r

copilot svc init -a "$4" -t "Load Balanced Web Service" -n "$1-svc"
copilot svc init -a "$4" -t "Load Balanced Web Service" -n "$2-svc"
echo "Deploying $1-svc"
copilot deploy --name "$1-svc" -e "$3"

echo "Deploying $2-svc"
copilot deploy --name "$2-svc" -e "$3"
