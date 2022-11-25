#!/bin/bash
set -e
BASEDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

cd $BASEDIR

$BASEDIR/resources/generate_bicep.py -c build.yml -i $BASEDIR/resources/bicep-templates -o azhop.bicep

az bicep build --file azhop.bicep --outfile azhop.json

az bicep build --file azureDeploy.bicep --outfile azureDeploy.json
