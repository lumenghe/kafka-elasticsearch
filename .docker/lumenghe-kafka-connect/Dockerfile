FROM confluentinc/cp-kafka-connect-base:5.3.2

ENV COMPONENT=kafka-connect

RUN confluent-hub install debezium/debezium-connector-mysql:1.2.0 --no-prompt \
    && confluent-hub install confluentinc/kafka-connect-elasticsearch:5.4.1 --no-prompt \
    && curl -L -o /usr/share/confluent-hub-components/confluentinc-kafka-connect-elasticsearch/lib/mysql-connector-java-8.0.19.jar https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.19/mysql-connector-java-8.0.19.jar
