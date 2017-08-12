#!/bin/bash -e

sed -i --follow-symlinks \
	-e "s/%PLATFORM_HOST%/${PLATFORM_HOST:-alfresco}/" \
	-e "s/%PLATFORM_PORT%/${PLATFORM_PORT:-8080}/" \
'/opt/solr/workspace-SpacesStore/conf/solrcore.properties';

sed -i --follow-symlinks \
	-e "s/%PLATFORM_HOST%/${PLATFORM_HOST:-alfresco}/" \
	-e "s/%PLATFORM_PORT%/${PLATFORM_PORT:-8080}/" \
'/opt/solr/archive-SpacesStore/conf/solrcore.properties';

/usr/local/tomcat/bin/catalina.sh $@;

