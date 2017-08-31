FROM fedora as version_discoverer
ENV NEXUS=https://artifacts.alfresco.com/nexus/content/groups/public

RUN dnf install -y python2-pip
RUN pip install --no-cache-dir mechanize cssselect lxml packaging

RUN mkdir /app
ADD assets/find_latest_version /app/
RUN \
	( \
		set -ex; \
		echo "NEXUS=\"${NEXUS}\""; \
		echo "ALF_VERSION=\"$(/app/find_latest_version "${NEXUS}/org/alfresco/alfresco-solr4")\""; \
	) > /app/latest_versions.env

FROM tomcat:7.0-jre8
MAINTAINER Jeremie Lesage <jeremie.lesage@gmail.com>

WORKDIR /usr/local/tomcat/
COPY --from=version_discoverer /app/latest_versions.env /root/

## SOLR.WAR
RUN \
	set -ex && \
	. /root/latest_versions.env && \
	curl -L "${NEXUS}/org/alfresco/alfresco-solr4/${ALF_VERSION}/alfresco-solr4-${ALF_VERSION}.war" -o "alfresco-solr4-${ALF_VERSION}.war" && \
	unzip "alfresco-solr4-${ALF_VERSION}.war" -d webapps/solr4/ && \
	rm -vf "alfresco-solr4-${ALF_VERSION}.war" && \
	rm -rvf /usr/share/doc webapps/docs webapps/examples webapps/manager webapps/host-manager

COPY assets/web.xml webapps/solr4/WEB-INF/web.xml

## SOLR CONF
RUN \
	set -ex && \
	. /root/latest_versions.env && \
	curl -L "${NEXUS}/org/alfresco/alfresco-solr4/${ALF_VERSION}/alfresco-solr4-${ALF_VERSION}-config.zip" -o "alfresco-solr4-${ALF_VERSION}-config.zip" && \
	unzip "alfresco-solr4-${ALF_VERSION}-config.zip" -d /opt/solr/ && \
	rm -vf "alfresco-solr4-${ALF_VERSION}-config.zip" && \
	mkdir -pv /opt/solr_data

COPY assets/workspace/* /opt/solr/workspace-SpacesStore/conf/
COPY assets/archive/* /opt/solr/archive-SpacesStore/conf/
COPY assets/server.xml conf/server.xml

ENV JAVA_OPTS " -XX:-DisableExplicitGC -Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -Dfile.encoding=UTF-8 "

VOLUME "/opt/solr_data/"
WORKDIR /root

ADD assets/entrypoint.sh /opt/
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["run"]

