FROM tomcat:9-alpine
MAINTAINER John Torres <enfermo337@yahoo.com>

ARG MYSQL_DRIVER_DOWNLOAD_VERSION
ENV MYSQL_DRIVER_DOWNLOAD_VERSION ${MYSQL_DRIVER_DOWNLOAD_VERSION:-5.1.40}

ARG TOMCAT_DOWNLOAD_VERSION
ENV TOMCAT_DOWNLOAD_VERSION ${TOMCAT_DOWNLOAD_VERSION:-9.0}

RUN rm -rf /usr/local/tomcat/webapps/docs /usr/local/tomcat/webapps/examples /usr/local/tomcat/webapps/ROOT

ADD https://tomcat.apache.org/tomcat-${TOMCAT_DOWNLOAD_VERSION}-doc/appdev/sample/sample.war /usr/local/tomcat/webapps/ROOT.war
ADD http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_DRIVER_DOWNLOAD_VERSION}.tar.gz /tmp/mysql-connector-java-${MYSQL_DRIVER_DOWNLOAD_VERSION}.tar.gz

RUN apk --no-cache add ca-certificates openssl tar curl && \
  /usr/bin/tar -xvzf /tmp/mysql-connector-java-${MYSQL_DRIVER_DOWNLOAD_VERSION}.tar.gz --strip-components=1 -C /usr/local/tomcat/lib/ mysql-connector-java-${MYSQL_DRIVER_DOWNLOAD_VERSION}/mysql-connector-java-${MYSQL_DRIVER_DOWNLOAD_VERSION}-bin.jar && \
  rm -f /tmp/mysql-connector-java-${MYSQL_DRIVER_DOWNLOAD_VERSION}.tar.gz

HEALTHCHECK CMD curl -f http://localhost:8080/hello.jsp | grep -q -E 'Hello!' 1> /dev/null || exit 1
