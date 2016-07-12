#!/usr/bin/env bash

# See all available locations at https://azure.microsoft.com/en-us/regions/
docker-machine create \
    --driver azure \
    --azure-subscription-id $AZURE_SUBSCRIPTION_ID \
    --azure-location eastasia \
    --azure-open-port 80 \
    --azure-open-port 500 \
    --azure-open-port 4500 \
    ckvpn-example
