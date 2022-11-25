#!/bin/bash

../../deploy/build.sh

cat <<EOF >trackingResource.json
{
  "apiVersion": "2020-06-01",
  "name": "pid-9dde42e6-8b35-48e9-90b2-e7acb2691dce-partnercenter",
  "location": "[parameters('location')]",
  "type": "Microsoft.Resources/deployments",
  "properties": {
    "mode": "Incremental",
    "template": {
      "\$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
      "contentVersion": "1.0.0.0",
      "resources": []
    }
  }
}
EOF

# append tracking.json to the end of the main template with jq
jq --argjson trackingResource "$(<trackingResource.json)" '.resources += [$trackingResource]' ../../deploy/azureDeploy.json > mainTemplate.json

timestamp=$(date +%Y%m%d%H%M%S)
zip azhopapp-$timestamp.zip mainTemplate.json createUiDefinition.json
