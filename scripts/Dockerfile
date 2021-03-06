FROM ubuntu:18.04

# install prerequisite debian packages
RUN apt-get update && \
     DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common \
     vim \
     wget \
     openjdk-8-jdk \
     unzip \
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
RUN groupadd --gid 10000 jenkins && useradd --gid 10000 --uid 10000 jenkins --shell /bin/bash \
  && chown -R jenkins:jenkins /opt \
  && mkdir /home/jenkins && chown -R jenkins:jenkins /home/jenkins \
  && mkdir /logs && chown -R jenkins:jenkins /logs

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
  && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" \
  && apt-get update \
  && apt-cache policy docker-ce \
  && apt install -y docker-ce \
  && usermod -aG docker jenkins

# Install Gcloud
# Downloading gcloud package
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

# Installing the package
RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh

# Install Gradle
RUN wget -q https://services.gradle.org/distributions/gradle-6.3-bin.zip \
    && unzip gradle-6.3-bin.zip -d /opt \
    && rm gradle-6.3-bin.zip \
    && ls -lrth /opt/gra*
ENV GRADLE_HOME /opt/gradle-6.3

# entrypoint is used to update docker gid and revert back to jenkins user
RUN mkdir -p /home/jenkins/entry

RUN apt-get update -y && apt-get install -y python-pip python-dev build-essential

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git &&  \
    apt-get install -y bash && \
    apt-get install -y npm && \
    npm install npm@latest -g && \
    npm cache clean -f && \
    npm install -g n && \
    n stable


USER jenkins
# Define working directory
WORKDIR /home/jenkins

ENV GOOGLE_APPLICATION_CREDENTIALS=/home/jenkins/service-account-key.json
ENV KUBECONFIG=/home/jenkins/kubeconfig.yaml

RUN pip install flask

RUN npm install npm@latest
ENV PATH $PATH:/home/jenking/node_modules/.bin
RUN npm install @angular/cli

# Adding the package path to local
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin
ENV PATH $PATH:/opt/gradle-6.3/bin:/bin/bash
ENV PATH $PATH:/home/jenkins/node_modules/@angular/cli/bin

ENV NG_CLI_ANALYTICS=ci

RUN npm version && ng version

CMD ["cat"]