JAVA_DOWNLOADS_URL=http://download.oracle.com/otn-pub/java/jdk
JAVA_VERSION="${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}"
JAVA_ARTEFACT=jdk-${JAVA_VERSION}-linux-x64.rpm
JAVA_ARTEFACT_URL=${JAVA_DOWNLOADS_URL}/${JAVA_VERSION}-b${JAVA_VERSION_BUILD}/${JAVA_DOWNLOAD_PATH}/$JAVA_ARTEFACT

# This accepts the Oracle Licence and downloads the JDK
wget -nv --no-cookies --header "Cookie: gpw_e24=xxx; oraclelicense=accept-securebackup-cookie;" $JAVA_ARTEFACT_URL

# Install JDK
sudo rpm -i ${JAVA_ARTEFACT}

# Disable Oracle usage tracker (this interferes with Kafka)
 echo "com.oracle.usagetracker.track.last.usage=false" | sudo tee --append /usr/java/latest/jre/lib/management/usagetracker.properties
