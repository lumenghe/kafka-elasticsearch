
# kafka-elasticsearch
1. Clone the `kafka-elasticsearch` repository and go into the project directory:
```bash
git clone git@github.com:lumenghe/kafka-elasticsearch.git --recurse-submodules
cd kafka-elasticsearch
```

2. On your laptop, you only have to run this command:
```bash
make run
```

3. make debezium payload
```bash
curl -i -X POST -H "Accept:application/json" -H "Content-Type: application/json" http://127.0.0.1:8083/connectors/ -d '{
  "name": "legacy_1581410638",
  "config": {
    "connector.class": "io.debezium.connector.mysql.MySqlConnector",
    "database.useLegacyDatetimeCode": "false",
    "database.history.kafka.recovery.attempts":"100",
    "database.history.kafka.recovery.poll.interval.ms":"100",
    "snapshot.locking.mode": "none",
    "tasks.max": "1",
    "database.history.kafka.topic": "dbhistory.legacy",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "database.whitelist": "lumenghe",
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "database.user": "debezium",
    "database.server.id": "1581410638",
    "database.history.kafka.bootstrap.servers": "kafka:29092",
    "database.server.name": "legacy",
    "database.port": "3306",
    "key.converter.schemas.enable": "false",
    "database.serverTimezone": "Europe/Paris",
    "database.hostname": "legacy-database",
    "database.password": "dbz",
    "value.converter.schemas.enable": "false",
    "name": "legacy_1581410638",
    "snapshot.mode": "initial",
    "database.history.producer.request.timeout.ms": "2147483647",
    "database.history.producer.retries": "2147483647"
  }
}'

```


4. make elastic search payload ([payload configuration](https://docs.confluent.io/current/connect/kafka-connect-elasticsearch/configuration_options.html))

### OPTION with ksqldb-server and ksqldb-cli elasticsearch-sink payload
```bash
curl -i -X POST -H "Accept:application/json" -H "Content-Type: application/json"  http://127.0.0.1:8083/connectors/ -d '{
  "name": "elasticsearch-sink-legacy",
  "config": {
    "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
    "topics": "SUMMARY_INDEX",
    "key.ignore":"true",
    "schema.ignore":"true",
    "key.converter":"org.apache.kafka.connect.json.JsonConverter",
    "value.converter":"org.apache.kafka.connect.json.JsonConverter",
    "key.converter.schemas.enable":"false",
    "value.converter.schemas.enable": "false",
    "tasks.max": "1",
    "connection.url": "http://elasticsearch:9200",
    "type.name": "test-type",
    "name": "elasticsearch-sink-legacy",
    "batch.size": 200,
    "max.buffered.records": 1500,
    "flush.timeout.ms": 10000
  }
}'
```

### OPTION with legacy topic
```bash
curl -i -X POST -H "Accept:application/json" -H "Content-Type: application/json"  http://127.0.0.1:8083/connectors/ -d '{
  "name": "elasticsearch-sink",
  "config": {
    "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
    "topics": "legacy.lumenghe.user,legacy.lumenghe.video,legacy.lumenghe.photo",
    "key.ignore":"true",
    "schema.ignore":"true",
    "key.converter":"org.apache.kafka.connect.json.JsonConverter",
    "value.converter":"org.apache.kafka.connect.json.JsonConverter",
    "key.converter.schemas.enable":"false",
    "value.converter.schemas.enable": "false",
    "tasks.max": "1",
    "connection.url": "http://elasticsearch:9200",
    "type.name": "test-type",
    "name": "elasticsearch-sink",
    "batch.size": 200,
    "max.buffered.records": 1500,
    "flush.timeout.ms": 10000
  }
}'
```


5. check kafka-connectors status
```bash
curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET  http://127.0.0.1:8083/connectors/?expand=status
```

6. check kafkahq and kibana in local
* `consul` with a web UI at [http://localhost:8500](http://localhost:8500/ui/dc1/kv)
* `legacy-database` on port `3306` with following credentials:
    * **User:** `root`
    * **Password:** `lumenghe`
    * **Database:** `lumenghe`
* `kibana` with a web UI at [http://localhost:5601/](http://localhost:5601/)
* `zookeeper` on port `2181`
* `kafka` on port `9092`
* `kafka-connect` on port `8083` with a REST API at [http://localhost:8083/connectors](http://localhost:8083/connectors)
* `kafka-hq` with a web UI at [http://localhost:8080/](http://localhost:8080/)


### OPTION with ksqldb-server and ksqldb-cli elasticsearch-sink payload
7. start kafka-stream-processor service
```bash
docker-compose build kafka-stream-processor && docker-compose run kafka-stream-processor
```
or
```bash
sudo docker-compose up --build kafka-stream-processor
```
#### OPTION write mysql in ksqldb-server by cli
* docker-compose exec  ksqldb-cli  ksql http://ksqldb-server:8088
* create streams from topics
```bash
CREATE stream user (after STRUCT<user_id int, name string>) WITH (KAFKA_TOPIC='legacy.lumenghe.user', VALUE_FORMAT='JSON');

CREATE stream video (after STRUCT<video_id int, user_id int, video_name string>) WITH (KAFKA_TOPIC='legacy.lumenghe.video', VALUE_FORMAT='JSON');

CREATE stream photo (after STRUCT<photo_id int, user_id int, photo_name string>) WITH (KAFKA_TOPIC='legacy.lumenghe.photo', VALUE_FORMAT='JSON');
```

* join by user_id
```bash
create stream summary_index as \
            select user.after->user_id as user_id, \
            user.after->name as user_name, \
            video.after->video_name as video_name ,\
            photo.after->photo_name as photo_name \
            from user \
                left join video within 7 days on user.after->user_id = video.after->user_id \
                left join photo within 7 days on user.after->user_id = photo.after->user_id;
```
