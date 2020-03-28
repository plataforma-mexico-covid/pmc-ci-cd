FROM openjdk:8u212-b04-jdk-stretch

user root 

# install prerequisite debian packages
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common \
     vim \
     wget \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# install gosu for a better su+exec command
ARG GOSU_VERSION=1.10
RUN dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
 && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
 && chmod +x /usr/local/bin/gosu \
 && gosu nobody true 


# Using 3.1.1
ARG HELM_VERSION
ENV HELM_BASE_URL="https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3"
ENV DESIRED_VERSION=${HELM_VERSION}

# Install helm
RUN curl -L ${HELM_BASE_URL} | bash

# Install kubectl
RUN \
  curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.8/2019-08-14/bin/linux/amd64/kubectl && \
  mv kubectl /usr/bin/kubectl && \
  chmod +x /usr/bin/kubectl

# Add and use user jenkins
RUN groupadd --gid 10000 jenkins && useradd --gid 10000 --uid 10000 jenkins --shell /bin/bash
RUN chown -R jenkins:jenkins /opt
RUN mkdir /home/jenkins && chown -R jenkins:jenkins /home/jenkins
RUN mkdir /logs && chown -R jenkins:jenkins /logs

# install docker
ARG DOCKER_CLI_VERSION==5:19.03.0~3-0~debian-stretch
# ARG DOCKER_CLI_VERSION=
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
 && add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/debian \
     $(lsb_release -cs) \
     stable" \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    docker-ce-cli${DOCKER_CLI_VERSION} \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && groupadd --gid 994 docker \
 && usermod -aG docker jenkins

# Install Gcloud
# Downloading gcloud package
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

# Installing the package
RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh

# Install Gradle
RUN wget -q https://services.gradle.org/distributions/gradle-3.3-bin.zip \
    && unzip gradle-3.3-bin.zip -d /opt \
    && rm gradle-3.3-bin.zip
ENV GRADLE_HOME /opt/gradle-3.3

# entrypoint is used to update docker gid and revert back to jenkins user
COPY entrypoint.sh /home/jenkins/entrypoint.sh
RUN chmod +x /home/jenkins/entrypoint.sh

USER jenkins
# Define working directory
WORKDIR /home/jenkins

# Adding the package path to local
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

ENV PATH $PATH:/opt/gradle-3.3/bin

ENTRYPOINT ["/home/jenkins/entrypoint.sh"]

# Checking that aws, kubectl and helm are correctly installed, 
RUN kubectl help && gcloud version && gradle --version  
