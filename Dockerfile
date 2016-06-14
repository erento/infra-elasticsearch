FROM quay.io/pires/docker-elasticsearch:2.3.3
# tutum.co/erento/search-els

MAINTAINER developers@erento.com
# modification from original file by pjpires@gmail.com

# Override elasticsearch.yml config, otherwise plug-in install will fail
ADD do_not_use.yml /elasticsearch/config/elasticsearch.yml

# Install Elasticsearch plug-ins
RUN /elasticsearch/bin/plugin install io.fabric8/elasticsearch-cloud-kubernetes/2.3.3 --verbose

# erento custom:start
COPY tmp/hunspell/ /elasticsearch/config/
RUN /elasticsearch/bin/plugin install analysis-icu
# erento custom:end

# Override elasticsearch.yml config, otherwise plug-in install will fail
ADD elasticsearch.yml /elasticsearch/config/elasticsearch.yml

# Copy run script
COPY run.sh /
