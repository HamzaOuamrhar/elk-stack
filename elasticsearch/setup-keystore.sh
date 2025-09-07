#!/bin/bash
set -e

if [ ! -f /usr/share/elasticsearch/config/elasticsearch.keystore ]; then
    /usr/share/elasticsearch/bin/elasticsearch-keystore create
fi

if [ -n "$ACCESS_KEY_ID" ]; then
    echo "$ACCESS_KEY_ID" | /usr/share/elasticsearch/bin/elasticsearch-keystore add -x s3.client.default.access_key
fi

if [ -n "$SECRET_ACCESS_KEY" ]; then
    echo "$SECRET_ACCESS_KEY" | /usr/share/elasticsearch/bin/elasticsearch-keystore add -x s3.client.default.secret_key
fi

exec /usr/local/bin/docker-entrypoint.sh elasticsearch
