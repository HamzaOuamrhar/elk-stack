#!/bin/bash
set -e


if [[ -z "$ELASTIC_PASSWORD" || -z "$KIBANA_PASSWORD" || -z "$LOGSTASH_PASSWORD" ]]; then
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
until curl -sk --cacert config/certs/ca/ca.crt https://elasticsearch:9200 \
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
        "names": [ "logs-*" ],
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


curl -X POST "https://kibana:5601/api/saved_objects/_import" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: multipart/form-data" \
  -F file=@/usr/share/kibana/dashboard.ndjson \
  -u elastic:${ELASTIC_PASSWORD} \
  --cacert config/certs/ca/ca.crt


echo "setup done!"
