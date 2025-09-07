#!/bin/bash

if [[ -z "$ELASTIC_PASSWORD" || -z "$KIBANA_PASSWORD" || -z "$LOGSTASH_PASSWORD" || -z "$KIBANA_ENCRYPTION_KEY" ]]; then
  echo "Missing required environment variables!"
  exit 1
fi

#######################      setup certificates

if [ ! -f config/ca.zip ]; then
    bin/elasticsearch-certutil ca  --pem --silent -out config/ca.zip
    unzip config/ca.zip -d config/certs
    echo "CA certificate generated!"
fi



if [ ! -f config/certs/certs.zip ]; then
    bin/elasticsearch-certutil cert --silent --pem -out config/certs.zip --in \
      config/instances.yml --ca-cert config/certs/ca/ca.crt --ca-key config/certs/ca/ca.key
    unzip config/certs.zip -d config/certs
    touch /tmp/certs_ready
    rm config/certs/ca/ca.key
    echo "Creating certifications for elk components done!"
fi


echo "Waiting for Elasticsearch..."
until curl -s --cacert config/certs/ca/ca.crt https://elasticsearch:9200 \
  | grep -q "missing authentication credentials"; do 
  sleep 5
done
echo "Elasticsearch is up..."

#######################        setup authentication


response1=$(curl -s -w "%{http_code}" -X POST "https://elasticsearch:9200/_security/user/kibana_system/_password" \
    -u "elastic:${ELASTIC_PASSWORD}" \
    --cacert config/certs/ca/ca.crt \
    -H "Content-Type: application/json" \
    -d "{\"password\":\"${KIBANA_PASSWORD}\"}")


response2=$(curl -s -w "%{http_code}" -X POST "https://elasticsearch:9200/_security/role/logstash_writer" \
  -u "elastic:${ELASTIC_PASSWORD}" \
  --cacert config/certs/ca/ca.crt \
  -H "Content-Type: application/json" \
  -d '{
    "cluster": ["manage_index_templates", "monitor"],
    "indices": [
      {
        "names": [ "transcendence-logs" ],
        "privileges": ["write", "create", "create_index", "view_index_metadata"]
      }
    ]
  }')


response3=$(curl -s -w "%{http_code}" -X POST "https://elasticsearch:9200/_security/user/logstash_author" \
  -u "elastic:${ELASTIC_PASSWORD}" \
  --cacert config/certs/ca/ca.crt \
  -H "Content-Type: application/json" \
  -d "{
    \"password\": \"${LOGSTASH_PASSWORD}\",
    \"roles\": [\"logstash_writer\"],
    \"full_name\": \"houamrha\"
  }")


# Setup data retention and archiving policies

response4=$(curl -s -w "%{http_code}" -X PUT "https://elasticsearch:9200/_snapshot/s3_repo" \
  -u "elastic:${ELASTIC_PASSWORD}" \
  --cacert config/certs/ca/ca.crt \
  -H "Content-Type: application/json" \
  -d "{
    \"type\": \"s3\",
    \"settings\": {
      \"bucket\": \"trans-elasticsearch\",
      \"region\": \"eu-north-1\",
      \"endpoint\": \"https://s3.eu-north-1.amazonaws.com\"
    }
  }")

response5=$(curl -s -w "%{http_code}" -X PUT "https://elasticsearch:9200/_slm/policy/daily-logs-snapshot" \
  -u "elastic:${ELASTIC_PASSWORD}" \
  --cacert config/certs/ca/ca.crt \
  -H "Content-Type: application/json" \
  -d "{
    \"schedule\": \"0 50 23 * * ?\",
    \"name\": \"snapshot-logs\",
    \"repository\": \"s3_repo\",
    \"config\": {
      \"indices\": [\"transcendence-logs\"],
      \"ignore_unavailable\": true,
      \"include_global_state\": false
    }
}")



response6=$(curl -s -w "%{http_code}" -X PUT "https://elasticsearch:9200/_ilm/policy/logs-delete-daily" \
  -u "elastic:${ELASTIC_PASSWORD}" \
  --cacert config/certs/ca/ca.crt \
  -H "Content-Type: application/json" \
  -d "{
    \"policy\": {
      \"phases\": {
        \"hot\": {
          \"actions\": {
            \"set_priority\": { \"priority\": 100 }
          }
        },
        \"delete\": {
          \"min_age\": \"1d\",
          \"actions\": {
            \"delete\": {}
          }
        }
      }
  }
}")




response7=$(curl -s -w "%{http_code}" -X PUT "https://elasticsearch:9200/_index_template/transcendence-logs-template" \
  -u "elastic:${ELASTIC_PASSWORD}" \
  --cacert config/certs/ca/ca.crt \
  -H "Content-Type: application/json" \
  -d "{
    \"index_patterns\": [\"transcendence-logs\"],
    \"template\": {
      \"settings\": {
        \"index.lifecycle.name\": \"logs-delete-daily\"
      }
    }
}")

http_code=${response4: -3}
echo "one: $http_code"
http_code=${response5: -3}
echo "two: $http_code"
http_code=${response6: -3}
echo "three: $http_code"
http_code=${response7: -3}
echo "four: $http_code"

http_code=${response1: -3}
if [ "$http_code" = "200" ]; then
    echo "kibana password changed with success"
else
    echo "Change kibana password failed, HTTP code: $http_code"
fi

http_code=${response2: -3}
if [ "$http_code" = "200" ]; then
    echo "Logstash role created!"
else
    echo "Logstash role creation failed!: $http_code"
fi

http_code=${response3: -3}
if [ "$http_code" = "200" ]; then
    echo "Logstash author user created!"
else
    echo "Logstash author user creation failed!: $http_code"
fi

# Import kibana dashboard

echo "Waiting for kibana..."
until curl -s -u elastic:${ELASTIC_PASSWORD} --cacert config/certs/ca/ca.crt https://kibana:5601/api/status | grep -q '"level":"available"'; do
  sleep 5
done


curl -s -X POST "https://kibana:5601/api/saved_objects/_import" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: multipart/form-data" \
  -F file=@/usr/share/kibana/dashboard.ndjson \
  -u elastic:${ELASTIC_PASSWORD} \
  --cacert config/certs/ca/ca.crt \
  -o /dev/null

echo "setup done!"
