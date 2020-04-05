#!/bin/bash
echo "1er parametro = directorio a installar"
echo "2do parametro = namespace"
echo "3er parametro = ruta al archivo kubeconfig"
echo "4to parametro = install|upgrade"
echo "5to paremetro = version a instalar "
echo "$4 this helm chart $1..."
helm $4 $1-helm --namespace=$2 --kubeconfig=$3 ./$1 --set image.version=$5