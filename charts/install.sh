#!/bin/bash
echo "1er parametro = directorio a installar"
echo "2do parametro = namespace"
echo "3er parametro = ruta al archivo kubeconfig"
echo "4to parametro = install|upgrade"
echo "5to paremetro = version a instalar "
echo "6to paremetro = archivo de values "
echo "$4 this helm chart $1..."

if [[ $# -eq 6 ]]; then
	echo "Doing push $#"
	helm $4 $1-helm -f ./$1/$6 --namespace=$2 --kubeconfig=$3 ./$1 --set image.version=$5 --set-string timestamp=$(date +%s)  	
else 
	echo "Docker push $# "
	helm $4 $1-helm -f ./$1/values.yaml --namespace=$2 --kubeconfig=$3 ./$1 --set image.version=$5 --set-string timestamp=$(date +%s)
fi
