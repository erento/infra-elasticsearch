FROM quay.io/pires/docker-elasticsearch:2.4.0

MAINTAINER developers@erento.com
# modification from original file by pjpires@gmail.com

# Override elasticsearch.yml config, otherwise plug-in install will fail
ADD do_not_use.yml /elasticsearch/config/elasticsearch.yml

# Install Elasticsearch plug-ins
RUN /elasticsearch/bin/plugin install io.fabric8/elasticsearch-cloud-kubernetes/2.4.0_01 --verbose

# erento custom:start
COPY tmp/hunspell/ /elasticsearch/config/hunspell/
RUN /elasticsearch/bin/plugin install analysis-icu
# erento custom:end

# Override elasticsearch.yml config, otherwise plug-in install will fail
ADD elasticsearch.yml /elasticsearch/config/elasticsearch.yml

# Copy run script
COPY run.sh /
