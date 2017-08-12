#!/bin/bash -e

sed -i --follow-symlinks \
	-e "s/%BASE_PORT%/${TOMCAT_BASE_PORT:-8005}/" \
	-e "s/%HTTP_PORT%/${TOMCAT_HTTP_PORT:-8080}/" \
'/usr/local/tomcat/conf/server.xml';

sed -i --follow-symlinks \
	-e "s/%PLATFORM_HOST%/${PLATFORM_HOST:-alfresco}/" \
	-e "s/%PLATFORM_PORT%/${PLATFORM_PORT:-8080}/" \
'/opt/solr/workspace-SpacesStore/conf/solrcore.properties';

sed -i --follow-symlinks \
	-e "s/%PLATFORM_HOST%/${PLATFORM_HOST:-alfresco}/" \
	-e "s/%PLATFORM_PORT%/${PLATFORM_PORT:-8080}/" \
'/opt/solr/archive-SpacesStore/conf/solrcore.properties';

/usr/local/tomcat/bin/catalina.sh $@;

