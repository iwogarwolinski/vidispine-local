#!/usr/bin/sh

# Initialize and migrate the database
vidispine db ping
vidispine db migrate
vidispine db check

# Start the services
# UGLY(!) Workaround for systemd not being available
# Commands here are copied from:
# /lib/systemd/system/solr.service
# /etc/systemd/system/transcoder.service
# /lib/systemd/system/vidispine.service

JAVA_OPTS="-Xmx2048m -Xss256k"

# Solr
cd /var/lib/vidispine/solr/8.x

/usr/bin/java \
    $JAVA_OPTS \
    -Dsolr.log.dir=/var/log/vidispine \
    -Djetty.base=/usr/share/vidispine/solr \
    -Djetty.home=/usr/share/vidispine/solr \
    -Dsolr.solr.home=/var/lib/vidispine/solr/8.x \
    -Dlog4j.configurationFile=/etc/vidispine/solr/log4j2.xml \
    -Dlog4j2.formatMsgNoLookups=true \
    -Dsolr.log.dir=/var/log/vidispine \
    -jar /usr/share/vidispine/solr/start.jar \
    --module=http &
	
# Transcoder
cd /opt/vidispine/transcoder
/opt/vidispine/transcoder/transcoder /var/run/transcoder.pid /var/run/transcoder-driver.pid /var/run/transcoder.stop &

# Vidispine
cd /var/lib/vidispine/server/
/usr/bin/java $JAVA_OPTS -jar /usr/share/vidispine/server/vidispine-server.jar db check /etc/vidispine/server.yaml
/usr/bin/java $JAVA_OPTS \
 -Dcom.vidispine.credentials.dir=/etc/vidispine/ \
 -Dcom.vidispine.license.dir=/etc/vidispine/ \
 -Dcom.vidispine.license.tmpdir=/var/lib/vidispine/server/ \
 -Dcom.vidispine.log.dir=/var/log/vidispine/ \
 -cp /usr/share/vidispine/server/lib/ext/*:/usr/share/vidispine/server/vidispine-server.jar \
 com.vidispine.server.VidispineApplication \
 server /etc/vidispine/server.yaml

