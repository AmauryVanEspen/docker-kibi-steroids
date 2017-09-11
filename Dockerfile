FROM openjdk:jdk-alpine
MAINTAINER lmangani <lorenzo.mangani@gmail.com>

ENV ES_VERSION=5.4.3 \
    KIBANA_VERSION=5.4.3

RUN apk add --no-progress --no-cache nodejs nodejs-npm git python wget build-base \
 && adduser -D elasticsearch

USER elasticsearch

WORKDIR /home/elasticsearch

RUN wget -q -O - https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ES_VERSION}.tar.gz \
 |  tar -zx \
 && mv elasticsearch-${ES_VERSION} elasticsearch \

 && wget -q -O - https://github.com/sirensolutions/kibi/archive/tag-${KIBANA_VERSION}.tar.gz \
 |  tar -zx \
 && mv kibi-tag-${KIBANA_VERSION} kibana \
 && mkdir -p kibana/node/bin \
 && ln -s $(which node) kibana/node/bin/node \
 && ln -s $(which npm) kibana/node/bin/npm \
 && cd kibana && ./node/bin/npm install && cd .. 

RUN cd kibana && ./bin/kibi-plugin install https://github.com/sirensolutions/sentinl/releases/download/tag-5.4/sentinl-v${KIBANA_VERSION}.zip && cd ..

CMD sh elasticsearch/bin/elasticsearch -E http.host=0.0.0.0 --quiet & kibana/bin/kibi --host 0.0.0.0 -Q

EXPOSE 9200 5606
