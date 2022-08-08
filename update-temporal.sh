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

TemporalAddress="${SvcName}.${3}.${AppName}.local:7233"

echo "Deploying $1-svc"
copilot svc deploy --name "$1-svc" -e "$3"

echo "Deploying $2-svc"
copilot svc deploy --name "$2-svc" -e "$3"
