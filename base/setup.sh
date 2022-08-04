#!/bin/bash

# These will come from aws secrets

set -eux -o pipefail

export ES_SERVER="${ES_SCHEME}://${ES_SEEDS%%,*}:${ES_PORT}"

echo "Runninggggg...."

DEFAULT_NAMESPACE="default"
DEFAULT_NAMESPACE_RETENTION="1"

register_default_namespace() {
     echo "Registering default namespace: ${DEFAULT_NAMESPACE}."
     if ! tctl --ad "$(ip route get 1.2.3.4 | awk '{print $7}'):7233" --ns "${DEFAULT_NAMESPACE}" namespace describe; then
         echo "Default namespace ${DEFAULT_NAMESPACE} not found. Creating..."
         tctl --ad "$(ip route get 1.2.3.4 | awk '{print $7}'):7233"  --ns "${DEFAULT_NAMESPACE}" namespace register --rd "${DEFAULT_NAMESPACE_RETENTION}" --desc "Default namespace for Temporal Server."
         echo "Default namespace ${DEFAULT_NAMESPACE} registration complete."
     else
         echo "Default namespace ${DEFAULT_NAMESPACE} already registered."
     fi
}

setup_server(){
    TEMPORAL_CLI_ADDRESS="$(ip route get 1.2.3.4 | awk '{print $7}'):7233"
    echo "Temporal CLI address: ${TEMPORAL_CLI_ADDRESS}."

    until tctl --ad $TEMPORAL_CLI_ADDRESS cluster health | grep -q SERVING; do
        echo "Waiting for Temporal server to start..."
        sleep 1
    done
    echo "Temporal server started."

    register_default_namespace
}


wait_for_es(){
  SECONDS=0
  ES_SCHEMA_SETUP_TIMEOUT_IN_SECONDS=0

#  ES_SERVER="${ES_SCHEME}://${ES_SEEDS%%,*}:${ES_PORT}"

  until curl --silent --fail "${ES_SERVER}" >& /dev/null; do
      DURATION=${SECONDS}
      echo 'Setting up Elasticsearch.'
      if [[ ${ES_SCHEMA_SETUP_TIMEOUT_IN_SECONDS} -gt 0 && ${DURATION} -ge "${ES_SCHEMA_SETUP_TIMEOUT_IN_SECONDS}" ]]; then
          echo 'WARNING: timed out waiting for Elasticsearch to start up. Skipping index creation.'
          return;
      fi

      echo 'Waiting for Elasticsearch to start up.'
      sleep 1
      ((ES_SCHEMA_SETUP_TIMEOUT_IN_SECONDS +=1))
  done

   echo 'Elasticsearch started.'
}

setup_es_index(){
 SETTINGS_URL="${ES_SERVER}/_cluster/settings"
 SETTINGS_FILE=${TEMPORAL_HOME}/schema/elasticsearch/visibility/cluster_settings_${ES_VERSION}.json
 TEMPLATE_URL="${ES_SERVER}/_template/temporal_visibility_v1_template"
 SCHEMA_FILE=${TEMPORAL_HOME}/schema/elasticsearch/visibility/index_template_${ES_VERSION}.json
 INDEX_URL="${ES_SERVER}/${ES_VIS_INDEX}"
 curl --fail -X PUT "${SETTINGS_URL}" -H "Content-Type: application/json" --data-binary "@${SETTINGS_FILE}" --write-out "\n"
 curl --fail -X PUT "${TEMPLATE_URL}" -H 'Content-Type: application/json' --data-binary "@${SCHEMA_FILE}" --write-out "\n"
 curl -X PUT "${INDEX_URL}" --write-out "\n"
}

setup_schema(){
  ./temporal-sql-tool -u $POSTGRES_USER -pw $POSTGRES_PWD --ep $POSTGRES_SEEDS -p $DB_PORT --db temporal --plugin postgres create
  ./temporal-sql-tool -u $POSTGRES_USER -pw $POSTGRES_PWD --ep $POSTGRES_SEEDS -p $DB_PORT --db temporal_visibility --plugin postgres create

  ./temporal-sql-tool -u $POSTGRES_USER -pw $POSTGRES_PWD --ep $POSTGRES_SEEDS -p $DB_PORT --plugin postgres --db temporal setup-schema -v 0.0
  ./temporal-sql-tool -u $POSTGRES_USER -pw $POSTGRES_PWD --ep $POSTGRES_SEEDS -p $DB_PORT --plugin postgres --db temporal update-schema -d ./schema/postgresql/v96/temporal/versioned

  ./temporal-sql-tool -u $POSTGRES_USER -pw $POSTGRES_PWD --ep $POSTGRES_SEEDS -p $DB_PORT --plugin postgres --db temporal_visibility setup-schema -v 0.0
  ./temporal-sql-tool -u $POSTGRES_USER -pw $POSTGRES_PWD --ep $POSTGRES_SEEDS -p $DB_PORT --plugin postgres --db temporal_visibility update-schema -d ./schema/postgresql/v96/visibility/versioned

  if [[ ${ENABLE_ES} == true ]]; then
      wait_for_es
      setup_es_index
  fi
}
setup_schema
setup_server & exec /etc/temporal/entrypoint.sh
