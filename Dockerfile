#TODO: https://docs.docker.com/docker-hub/builds/#understand-the-build-process
#NOTE: Based on https://hub.docker.com/r/agileek/ionic-framework/
#https://www.youtube.com/watch?v=PivpCKEiQOQ

FROM     ubuntu:14.04.4

ENV DEBIAN_FRONTEND=noninteractive \
    ANDROID_HOME=/opt/android-sdk-linux \
    NODE_VERSION=7.9.0 \
    NPM_VERSION=4.2.0 \
    IONIC_VERSION=2.2.2 \
    CORDOVA_VERSION=6.5.0 \
    PHANTOMJS_VERSION=1.9.8

# Install basics
RUN apt-get update && \
    apt-get install -y apt-transport-https build-essential git wget curl unzip ruby && \
    curl --retry 3 -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" && \
    tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 && \
    rm "node-v$NODE_VERSION-linux-x64.tar.gz" && \
    npm install -g npm@"$NPM_VERSION" && \
    npm install -g cordova@"$CORDOVA_VERSION" ionic@"$IONIC_VERSION" && \
    npm install -g jscs && \
    npm install -g eslint && \
    npm install -g bower && \
    npm install -g gulp && \
    npm cache clear && \
    gem install sass && \
    npm rebuild node-sass && \
    npm install -g requirements


# Install PhantomJS
# Found solution on https://gist.github.com/julionc/7476620
# Install these packages needed by PhantomJS to work correctly.
RUN apt-get install -y --force-yes build-essential chrpath libssl-dev libxft-dev && \
    apt-get install -y --force-yes libfreetype6 libfreetype6-dev && \
    apt-get install -y --force-yes libfontconfig1 libfontconfig1-dev

# Get it from the PhantomJS website.
# Once downloaded, move Phantomjs folder to /usr/local/share/ and create a symlink:
RUN cd ~ && \
    export PHANTOM_JS="phantomjs-$PHANTOMJS_VERSION-linux-x86_64" && \
    wget https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2 && \
    sudo tar xvjf $PHANTOM_JS.tar.bz2 && \
    mv $PHANTOM_JS /usr/local/share && \
    ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin && \
    phantomjs --version

#ANDROID
#JAVA

# Install python-software-properties (so you can do add-apt-repository)
RUN apt-get update && apt-get install -y -q python-software-properties software-properties-common  && \
    add-apt-repository ppa:webupd8team/java -y && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get update && apt-get -y install oracle-java8-installer

#gyp ERR! stack Error: not found: make
RUN apt-get install build-essential    

#ANDROID STUFF
RUN echo ANDROID_HOME="${ANDROID_HOME}" >> /etc/environment && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --force-yes expect ant wget libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 qemu-kvm kmod && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Android SDK
RUN cd /opt && \
    wget https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz && \
    tar xzf android-sdk_r24.4.1-linux.tgz && \
    rm android-sdk_r24.4.1-linux.tgz && \
    (echo y | android-sdk-linux/tools/android -s update sdk --no-ui --filter platform-tools,tools -a ) && \
    (echo y | android-sdk-linux/tools/android -s update sdk --no-ui --filter extra-android-m2repository,extra-android-support,extra-google-google_play_services,extra-google-m2repository -a) && \
    (echo y | android-sdk-linux/tools/android -s update sdk --no-ui --filter build-tools-24.0.3,android-25 -a) && \
    chown -R root. /opt

# Setup environment
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:/opt/tools
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# http://stackoverflow.com/a/22656646
RUN ln -s /usr/lib/jvm/java-8-oracle /usr/lib/jvm/default-java

# Disable SSL verification for all repositories
RUN git config --global http.sslVerify false