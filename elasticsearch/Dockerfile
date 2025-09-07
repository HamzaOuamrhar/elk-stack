FROM docker.elastic.co/elasticsearch/elasticsearch:8.17.5
COPY elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
ENV ES_JAVA_OPTS="-Xms512m -Xmx512m"
EXPOSE 9200
COPY setup-keystore.sh /usr/share/elasticsearch/
USER root
RUN chmod +x /usr/share/elasticsearch/setup-keystore.sh
USER elasticsearch
ENTRYPOINT ["/usr/share/elasticsearch/setup-keystore.sh"]
