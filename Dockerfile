# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# NOTE: DO *NOT* EDIT THIS FILE.  IT IS GENERATED.
# PLEASE UPDATE Dockerfile.txt INSTEAD OF THIS FILE
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
FROM centos:7.2.1511
MAINTAINER Ken.l.ma

USER root

#========================
# Miscellaneous packages
# Includes minimal runtime used for executing non GUI Java programs
#========================

RUN yum update -y
RUN rpm --rebuilddb; yum install -y yum-plugin-ovl
RUN yum -y install bzip2 \
	apt-get \
    ca-certificates \
    java-1.8.0-openjdk \
    tzdata \
    unzip \
	xvfb \
	locales \
	firefox \
	libXfont \
	redhat-lsb \
	libXScrnSaver \
	Xorg \
    wget
RUN  mkdir -p /opt/selenium \
  && wget --no-verbose https://selenium-release.storage.googleapis.com/3.4/selenium-server-standalone-3.4.0.jar \
    -O /opt/selenium/selenium-server-standalone.jar

#==============================
# Scripts to run Selenium Node
#==============================
COPY entry_point.sh \
  functions.sh \
    /opt/bin/
RUN chmod 755 /opt/bin/*
	
#============================
# Some configuration options
#============================
ENV SCREEN_WIDTH 1360
ENV SCREEN_HEIGHT 1020
ENV SCREEN_DEPTH 24
ENV DISPLAY :99.0

#========================
# Selenium Configuration
#========================
# As integer, maps to "maxInstances"
ENV NODE_MAX_INSTANCES 1
# As integer, maps to "maxSession"
ENV NODE_MAX_SESSION 1
# As integer, maps to "port"
ENV NODE_PORT 5555
# In milliseconds, maps to "registerCycle"
ENV NODE_REGISTER_CYCLE 5000
# In milliseconds, maps to "nodePolling"
ENV NODE_POLLING 5000
# In milliseconds, maps to "unregisterIfStillDownAfter"
ENV NODE_UNREGISTER_IF_STILL_DOWN_AFTER 60000
# As integer, maps to "downPollingLimit"
ENV NODE_DOWN_POLLING_LIMIT 2
# As string, maps to "applicationName"
ENV NODE_APPLICATION_NAME ""

#============================================
# Google Chrome
#============================================
# can specify versions by CHROME_VERSION;
#  e.g. google-chrome-stable=53.0.2785.101-1
#       google-chrome-beta=53.0.2785.92-1
#       google-chrome-unstable=54.0.2840.14-1
#       latest (equivalent to google-chrome-stable)
#       google-chrome-beta  (pull latest beta)
#============================================
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm \
  && yum -y localinstall google-chrome-stable_current_x86_64.rpm \
  && rm -rf google-chrome-stable_current_x86_64.rpm \
  && yum clean all 
#==================
# Chrome webdriver
#==================
ARG CHROME_DRIVER_VERSION=2.30
RUN wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \
  && rm -rf /opt/selenium/chromedriver \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
  && rm /tmp/chromedriver_linux64.zip \
  && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && chmod 755 /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && ln -fs /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver

COPY generate_config /opt/bin/generate_config
RUN chmod 777 /opt/bin/generate_config

#=================================
# Chrome Launch Script Modification
#=================================
COPY chrome_launcher.sh /opt/google/chrome/google-chrome
RUN chmod 777 /opt/*
RUN /opt/bin/generate_config > /opt/selenium/config.json

ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

CMD ["/opt/bin/entry_point.sh"]
