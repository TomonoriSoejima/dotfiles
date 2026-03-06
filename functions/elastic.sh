#!/bin/bash
# Elastic Cloud diagnostic functions
# ess, diag, diagme, diagme5

ess () 
{ 
    authX="Authorization: APIKey ${ELASTIC_ECE_KEY}";
    BASE="https://adminconsole.found.no";
    FLEET_OVERRIDE="asdf:asdf";
    MGMNT="X-Management-Request: true";
    PREREQ='👻 1st cache ID via "echo DEPLOYMENT_ID > .d" or "echo PROJECT_ID > .p"';
    ID=;
    REF_ID=;
    IS_ECH=;
    IS_GOV=False;
    if [[ -f './.d' ]]; then
        IS_ECH=true;
        ID=$(cat "./.d");
        if [[ -f './.gov' ]]; then
            IS_GOV=true;
            BASE="https://admin.us-gov-east-1.aws.elastic-cloud.com";
            authX="Authorization: APIKey ${ELASTIC_ECE_GOV_KEY}";
        fi;
    else
        if [[ -f './.p' ]]; then
            ID=$(cat "./.p") && IS_ECH=false;
        fi;
    fi;
    if [[ -f './.esRefId' ]]; then
        if [[ ( -f './.d' || -f './.p' ) ]]; then
            REF_ID=$(cat "./.esRefId");
        else
            rm './.esRefId';
            echo $PREREQ;
            return;
        fi;
    fi;
    if [[ ! -n $ID ]]; then
        echo $PREREQ && return;
    fi;
    if [[ ! -f './.esRefId' ]]; then
        REF_ID=;
        if [[ "$IS_ECH" == true ]]; then
            tmp_domain="$BASE/api/v1/all/_search?q=$ID";
            tmp_response=$(eval curl --compressed -s -XGET -H \"$authX\" -H \"$MGMNT\" -H \"$FLEET_OVERRIDE\" \"$tmp_domain\");
            REF_ID=$( echo $tmp_response | jq -rc ".results?|.[]|.info.resources.elasticsearch[].ref_id"  );
        else
            tmp_domain="$BASE/api/v1/admin/serverless/projects";
            tmp_response=$(for PROJECT_TYPE in elasticsearch observability security; do (eval curl --compressed -s -f -XGET "$tmp_domain/${PROJECT_TYPE}/$ID" -H \"$authX\" || true); done);
            REF_ID=$( echo $tmp_response |  jq -rc '.type' );
        fi;
        echo $REF_ID > "./.esRefId";
    fi;
    if [[ $IS_ECH == true ]]; then
        DOMAIN="$BASE/api/v1/deployments/$ID/elasticsearch/$REF_ID/proxy";
    else
        DOMAIN="$BASE/api/v1/admin/serverless/projects/$REF_ID/$ID/_proxy";
    fi;
    if [[ -z "$1" ]]; then
        URI="/";
    else
        URI=$1;
    fi;
    if [[ ${URI:0:1} != "/" ]]; then
        URI="/$URI";
    fi;
    if [[ "$2" == "curl" ]]; then
        echo "curl -s --compressed -XGET -H \"$authX\" -H \"$MGMNT\" -H \"$FLEET_OVERRIDE\" \"$DOMAIN$URI\"";
    else
        echo $(eval "curl -s --compressed -XGET -H \"$authX\" -H \"$MGMNT\" -H \"$FLEET_OVERRIDE\" \"$DOMAIN$URI\"");
    fi
}
diag () 
{ 
    r=$(ess '/');
    if [[ $r == *"👻"* ]]; then
        echo $r && return;
    fi;
    echo $r | jq . > version.json;
    v=$(version $(cat version.json | jq -cr '.version.number') );
    if [[ $v == 0 ]]; then
        echo "👻 could not determine version" && return;
    fi;
    echo "👀 v$(cat version.json | jq -r '.version.number') $(cat version.json | jq '.cluster_name')";
    if [[ $v < 070700 ]]; then
        echo "👻 YMMV v≤7.7";
    fi;
    run_all=false;
    just_use=true;
    read -p "🙋‍♀️ only USE? [y,n] " shortA;
    case $shortA in 
        n | N)
            run_all=true
        ;;
    esac;
    if [ "$run_all" = false ]; then
        read -p "🙋‍♀️ only USE core? [y,n] " shortB;
        case $shortB in 
            n | N)
                just_use=false
            ;;
        esac;
    fi;
    echo " ";
    echo "🦖";
    if [[ ! -d "cat" ]]; then
        mkdir "cat";
    fi;
    if [[ ! -d "commercial" ]]; then
        mkdir "commercial";
    fi;
    echo "= performance: USE method";
    echo "    - master_node.json" && ess '_nodes/_master/_none' | jq . > master_node.json;
    echo "    - cat_nodes.txt" && ess '_cat/nodes?v&s=master,name&h=name,id,master,node.role,cpu,heap.percent,disk.*,sstc,uptime,version' > ./cat/cat_nodes.txt;
    echo "    - cat_allocation.txt" && ess '_cat/allocation?v' > ./cat/cat_allocation.txt;
    echo "    - cluster_pending_tasks.json" && ess '_cluster/pending_tasks?human' | jq . > cluster_pending_tasks.json;
    echo "    - cat_thread_pool.txt" && ess '_cat/thread_pool?v' > ./cat/cat_thread_pool.txt;
    echo "    - cluster_health.json" && ess '_cluster/health' | jq . > cluster_health.json;
    echo "    - allocation_explain.json" && ess '_cluster/allocation/explain?include_disk_info=true' | jq . > allocation_explain.json;
    echo "    - tasks.json" && ess '_tasks?human&detailed=true' | jq . > tasks.json;
    echo "    - index_settings.json" && ess '_settings?human&expand_wildcards=all' | jq . > settings.json;
    echo "    - index_stats.json" && ess '_stats?level=shards&human&expand_wildcards=all&ignore_unavailable=true' | jq . > indices_stats.json;
    echo "    - alias.json" && ess '_alias?human' | jq . > alias.json;
    echo "    - cluster_settings_defaults.json" && ess '_cluster/settings?include_defaults&flat_settings' | jq . > cluster_settings_defaults.json;
    echo "    - slm_policies.json" && ess '_slm/policy?human' | jq . > ./commercial/slm_policies.json;
    echo "    - data_streams.json" && ess '_data_stream' | jq . > ./commercial/data_stream.json;
    echo "    - cat_repositories.txt" && ess '_cat/repositories?v' > ./cat/cat_repositories.txt;
    echo "    - snapshot.json" && ess '_snapshot/*/*?verbose=false' | jq . > snapshot.json;
    echo "    - cat_recovery_active.txt" && ess '_cat/recovery?v&expand_wildcards=all&active_only=true&h=time,tb,bp,top,ty,st,snode,tnode,idx,sh&s=time:desc' > ./cat/cat_recovery_active.txt;
    echo "    - ilm_explain.json" && ess '_all/_ilm/explain?human&expand_wildcards=all' | jq . > ./commercial/ilm_explain.json;
    echo "    - ilm_policies.json" && ess '_ilm/policy?human' | jq . > ./commercial/ilm_policies.json;
    echo "    - nodes_stats.json" && ess '_nodes/stats?human' | jq . > nodes_stats.json;
    echo "    - nodes_hot_threads.txt" && ess '_nodes/hot_threads?threads=10000' > nodes_hot_threads.txt;
    if [[ $v > 080200 ]]; then
        echo "    - internal_health.json" && ess '_internal/_health' | jq . > internal_health.json;
        if [[ $v > 080700 ]]; then
            echo "    - internal_health.json" && ess '_health_report' | jq . > internal_health.json;
        fi;
    fi;
    echo "    3 nodes.json" && ess '_nodes?human' | jq . > nodes.json;
    echo "    2 cat_indices.txt" && ess '_cat/indices?v&s=index&h=health,status,index,uuid,pri,rep,docs.count,docs.deleted,store.size,pri.store.size,sth&expand_wildcards=all' > ./cat/cat_indices.txt;
    echo "    1 cat_shards.txt" && ess '_cat/shards?v&s=index' > ./cat/cat_shards.txt;
    echo "    0 cluster_state.json" && ess '_cluster/state?human&wait_for_timeout=2m' | jq . > cluster_state.json;
    if [[ "$just_use" = false || "$run_all" = true ]]; then
        echo "= performance: other";
        echo "| - nodes";
        echo "    - plugins.json" && ess '_cat/plugins?format=json' | jq . > ./cat/plugins.json;
        echo "    - nodes_usage.json" && ess '_nodes/usage' | jq . > nodes_usage.json;
        echo "    - cat_nodeattrs.txt" && ess '_cat/nodeattrs?v&h=node,id,pid,host,ip,port,attr,value' > ./cat/cat_nodeattrs.txt;
        echo "    - internal_desired_balance.json" && ess '_internal/desired_balance' | jq . > internal_desired_balance.json;
        echo "| - cluster";
        echo "    - cat_pending_tasks.txt" && ess '_cat/pending_tasks?v' > ./cat/cat_pending_tasks.txt;
        echo "    - cluster_stats.json" && ess '_cluster/stats?human' | jq . > cluster_stats.json;
        echo "    - slm_status.json" && ess '_slm/status' | jq . > ./commercial/slm_status.json;
        echo "    - ilm_status.json" && ess '_ilm/status' | jq . > ./commercial/ilm_status.json;
        echo "    - licenses.json" && ess '_license' | jq . > licenses.json;
        echo "    - remote_cluster_info.json" && ess '_remote/info' | jq . > remote_cluster_info.json;
        echo "    - nodes_shutdown_status.json" && ess '_nodes/shutdown' | jq . > ./commercial/nodes_shutdown_status.json;
        echo "    - repositories.json" && ess '_snapshot' | jq . > repositories.json;
        echo "| - tasks,ilm,slm";
        echo "    - cat_recovery.txt" && ess '_cat/recovery?v&expand_wildcards=all' > ./cat/cat_recovery.txt;
        echo "    - recovery.json" && ess '_recovery?human&detailed=true&active_only=true' | jq . > recovery.json;
        echo "    - searchable_snapshots_cache_stats.json" && ess '_searchable_snapshots/cache/stats?human' | jq . > ./commercial/searchable_snapshots_cache_stats.json;
        echo "    - slm_stats.json" && ess '_slm/stats' | jq . > ./commercial/slm_stats.json;
        echo "    - cat_snapshots.txt" && ess '_cat/snapshots?v' > ./cat/cat_snapshots.txt;
        echo "    - snapshots_current.json" && ess '_snapshot/_all/_current' | jq . > snapshots_current.json;
        echo "    - snapshot_latest.json" && ess '_snapshot/_all/_all?size=300&sort=start_time&order=desc' | jq . > snapshot_latest.json;
        echo "| - indices,ingest";
        echo "    - index_mappings.json" && ess '_mapping?expand_wildcards=all' | jq . > mapping.json;
        echo "    - segments.json" && ess '_segments?human' | jq . > segments.json;
        echo "    - cat_aliases.txt" && ess '_cat/aliases?v' > ./cat/cat_aliases.txt;
        echo "    - cat_fielddata.txt" && ess '_cat/fielddata?v' > ./cat/cat_fielddata.txt;
        echo "    - fielddata_stats.json" && ess '_nodes/stats/indices/fielddata?level=shards&fields=*' | jq . > fielddata_stats.json;
        echo "    - cat_segments.txt" && ess '_cat/segments?v&s=index' > ./cat/cat_segments.txt;
        echo "    - pipelines.json" && ess '_ingest/pipeline/*?human' | jq . > pipelines.json;
        echo "| - templates,security";
        echo "    - legacy_templates.json" && ess '_template' | jq . > templates.json && cp templates.json legacy_templates.json;
        echo "    - component_templates.json" && ess '_component_template' | jq . > component_templates.json;
        echo "    - cat_templates.txt" && ess '_cat/templates?v' > ./cat/cat_templates.txt;
        echo "    - index_templates.json" && ess '_index_template' | jq . > index_templates.json;
        echo "    - logstash_pipeline.json" && ess '_logstash/pipeline' | jq . > ./commercial/logstash_pipeline.json;
    fi;
    if [ "$run_all" = true ]; then
        echo "= misc";
        echo "| - security";
        echo "    - security_roles.json" && ess '_security/role' | jq . > ./commercial/security_roles.json;
        echo "    - security_role_mappings.json" && ess '_security/role_mapping' | jq . > ./commercial/security_role_mappings.json;
        echo "    - security_users.json" && ess '_security/user' | jq . > ./commercial/security_users.json;
        echo "| - ml";
        echo "    - ml_anomalies.json" && ess '_ml/anomaly_detectors' | jq . > ./commercial/ml_anomaly_detectors.json && cp ./commercial/ml_anomaly_detectors.json ./commercial/ml_anomalies.json;
        echo "    - ml_anomalies_stats.json" && ess '_ml/anomaly_detectors/_stats' | jq . > ./commercial/ml_stats.json && cp ./commercial/ml_stats.json ./commercial/ml_anomalies_stats.json;
        echo "    - ml_dataframe.json" && ess '_ml/data_frame/analytics' | jq . > ./commercial/ml_dataframe.json;
        echo "    - ml_dataframe_stats.json" && ess '_ml/data_frame/analytics/_stats' | jq . > ./commercial/ml_dataframe_stats.json;
        echo "    - ml_datafeeds.json" && ess '_ml/datafeeds' | jq . > ./commercial/ml_datafeeds.json;
        echo "    - ml_datafeeds_stats.json" && ess '_ml/datafeeds/_stats' | jq . > ./commercial/ml_datafeeds_stats.json;
        echo "    - ml_info.json" && ess '_ml/info' | jq . > ./commercial/ml_info.json;
        echo "    - ml_trained_models.json" && ess '_ml/trained_models' | jq . > ./commercial/ml_trained_models.json;
        echo "    - ml_trained_models_stats.json" && ess '_ml/trained_models/_stats' | jq . > ./commercial/ml_trained_models_stats.json;
        echo "| - rollup,transform,watcher";
        echo "    - rollup_index_caps.json" && ess '_all/_rollup/data' | jq . > ./commercial/rollup_index_caps.json;
        echo "    - rollup_caps.json" && ess '_rollup/data/_all' | jq . > ./commercial/rollup_caps.json;
        echo "    - rollup_jobs.json" && ess '_rollup/job/_all' | jq . > ./commercial/rollup_jobs.json;
        echo "    - transform.json" && ess '_transform' | jq . > ./commercial/transform.json;
        echo "    - transform_stats.json" && ess '_transform/_stats' | jq . > ./commercial/transform_stats.json;
        echo "    - transform_basic_stats.json" && ess '_transform/_stats?basic=true' | jq . > ./commercial/transform_basic_stats.json;
        echo "    - transform_node_stats.json" && ess '_transform/_node_stats' | jq . > ./commercial/transform_node_stats.json;
        echo "    - watcher_stats.json" && ess '_watcher/stats/_all' | jq . > ./commercial/watcher_stats.json;
        echo "    - watcher_stack.json" && ess '_watcher/stats?emit_stacktraces=true' | jq . > ./commercial/watcher_stack.json;
        echo "| - ccr,autoscaling,enrich,geoip";
        echo "    - ccr_autofollow_patterns.json" && ess '_ccr/auto_follow' | jq . > ./commercial/ccr_autofollow_patterns.json;
        echo "    - ccr_stats.json" && ess '_ccr/stats' | jq . > ./commercial/ccr_stats.json;
        echo "    - ccr_follower_info.json" && ess '_all/_ccr/info' | jq . > ./commercial/ccr_follower_info.json;
        echo "    - autoscaling_capacity.json" && ess '_autoscaling/capacity' | jq . > ./commercial/autoscaling_capacity.json;
        echo "    - enrich_policies.json" && ess '_enrich/policy' | jq . > ./commercial/enrich_policies.json;
        echo "    - enrich_stats.json" && ess '_enrich/_stats' | jq . > ./commercial/enrich_stats.json;
        echo "    - geoip_stats.json" && ess '_ingest/geoip/stats' | jq . > ./commercial/geoip_stats.json;
        echo "    - xpack.json" && ess '_xpack/usage?human' | jq . > ./commercial/xpack.json;
        echo "    - profiling_status.json" && ess '_profiling/status' | jq . > ./commercial/profiling_status.json;
        echo "| - strays,misc";
    fi;
    echo "👌"
}
diagme () 
{ 
    if [[ -f ".d" || -f ".p" ]]; then
        directory=${PWD##*/};
        directory=${directory:-/};
        id=;
        if [[ -f ".p" ]]; then
            id=$(cat .p);
        fi;
        if [[ -f ".d" ]]; then
            id=$(cat .d);
        fi;
        time=$(date -u "+%Y%m%dT%H%M");
        mkcd "${time}-${directory}-${id:0:6}-es";
        if [[ -a "../.p" ]]; then
            cp ../.p .p;
        fi;
        if [[ -a "../.d" ]]; then
            cp ../.d .d;
        fi;
        if [[ -a "../.gov" ]]; then
            cp ../.gov .gov;
        fi;
        diag;
    else
        echo "👻 cache .d or .p first";
    fi
}
diagme5 () 
{ 
    diagme;
    echo "waiting 5mins";
    sleep 60;
    echo " ... 4";
    sleep 60;
    echo " ... 3";
    sleep 60;
    echo " ... 2";
    sleep 60;
    echo " ... 1";
    sleep 60;
    echo "    +1 index_stats_end.json" && ess '_stats?level=shards&human&expand_wildcards=all&ignore_unavailable=true' | jq . > indices_stats_end.json;
    echo "    +0 nodes_stats_end.json" && ess '_nodes/stats?human' | jq . > nodes_stats_end.json;
    echo "➕";
    python3 $HOME_LIB_ELASTIC/checkForHotSpotting.py
}

# ======================================================================
# Ticket Workflow Functions
# ======================================================================

# ny() - Download ticket feeds
# Usage: ny TICKET_NUMBER
# Example: ny 12345678
ny() {
    (cd $HOME/elastic/utilities/sfdc-case-downloader && python3 feed_downloader_simple.py "$@")
}
