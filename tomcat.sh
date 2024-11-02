#!/bin/bash

# Install Java 
yum install java-17 -y

# Fetch the latest version number for Tomcat 9
TOMCAT_VERSION=$(curl -s https://dlcdn.apache.org/tomcat/tomcat-9/ | grep -oP '(?<=v)[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -1)

# Check if TOMCAT_VERSION is empty
if [ -z "$TOMCAT_VERSION" ]; then
    echo "Error: Unable to fetch the latest Tomcat version."
    exit 1
fi

# Construct the download URL using the latest version
TOMCAT_URL="https://dlcdn.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"

# Download the latest version
echo "Downloading Tomcat version ${TOMCAT_VERSION} from ${TOMCAT_URL}..."
if wget "$TOMCAT_URL"; then
    echo "Download completed successfully."
else
    echo "Error: Download failed."
    exit 1
fi

# Extract the downloaded tar.gz file
echo "Extracting Tomcat ${TOMCAT_VERSION}..."
tar -zxvf "apache-tomcat-${TOMCAT_VERSION}.tar.gz"

# Configure tomcat-users.xml
TOMCAT_DIR="apache-tomcat-${TOMCAT_VERSION}"

# Add roles and user to tomcat-users.xml
echo "Configuring Tomcat user roles..."
sed -i '56  a\<role rolename="manager-gui"/>' "${TOMCAT_DIR}/conf/tomcat-users.xml"
sed -i '57  a\<role rolename="manager-script"/>' "${TOMCAT_DIR}/conf/tomcat-users.xml"
sed -i '58  a\<user username="tomcat" password="tarun123" roles="manager-gui,manager-script"/>' "${TOMCAT_DIR}/conf/tomcat-users.xml"
sed -i '59  a\</tomcat-users>' "${TOMCAT_DIR}/conf/tomcat-users.xml"
sed -i '56d' "${TOMCAT_DIR}/conf/tomcat-users.xml"  # Remove the previous closing tag if exists

# Remove default context.xml entries for manager app
echo "Removing default context.xml entries for manager app..."
sed -i '21d' "${TOMCAT_DIR}/webapps/manager/META-INF/context.xml"
sed -i '22d' "${TOMCAT_DIR}/webapps/manager/META-INF/context.xml"

# Start Tomcat
echo "Starting Tomcat ${TOMCAT_VERSION}..."
sh "${TOMCAT_DIR}/bin/startup.sh"

echo "Tomcat ${TOMCAT_VERSION} has been started successfully."
