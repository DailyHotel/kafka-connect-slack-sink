FROM openjdk:8-jdk AS build
MAINTAINER Keaton Choi "keaton@dailyhotel.com"

ENV LEIN_ROOT true

RUN wget -q -O /usr/bin/lein \
    https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein \
    && chmod +x /usr/bin/lein

COPY src /app/src 
COPY project.clj /app/src/
WORKDIR /app/src

RUN lein uberjar
RUN lein test

# final stage
FROM confluentinc/cp-kafka-connect:3.0.1
MAINTAINER Keaton Choi "keaton@dailyhotel.com"

## copy vault from build
COPY --from=build /app/src/target/kafka-connect-slack-sink-standalone.jar /usr/share/java/kafka-connect-slack-sink/

ENV CONNECT_BOOTSTRAP_SERVERS kafka:9092
# ENV CONNECT_GROUP_ID slack-sink-test
ENV CONNECT_CONFIG_STORAGE_TOPIC __slack.sink.config.storage
ENV CONNECT_STATUS_STORAGE_TOPIC __slack.sink.status.storage
ENV CONNECT_OFFSET_STORAGE_TOPIC __slack.sink.offset.storage
ENV CONNECT_VALUE_CONVERTER org.apache.kafka.connect.json.JsonConverter
ENV CONNECT_KEY_CONVERTER org.apache.kafka.connect.json.JsonConverter
ENV CONNECT_INTERNAL_KEY_CONVERTER org.apache.kafka.connect.json.JsonConverter
ENV CONNECT_INTERNAL_VALUE_CONVERTER org.apache.kafka.connect.json.JsonConverter
ENV CONNECT_REST_PORT 8083
# ENV CONNECT_REST_ADVERTISED_HOST_NAME kafka-connect-slack-sink
ENV CONNECT_SCHEMAS_ENABLE "false"
ENV CONNECT_VALUE_CONVERTER_SCHEMAS_ENABLE "false"
ENV CONNECT_KEY_CONVERTER_SCHEMAS_ENABLE "false"
ENV CONNECT_ZOOKEEPER_CONNECT zookeeper:2181