echo "Deleting existing directories"
rm -fr pmc-service
rm -fr pmc-ci-cd
branch=master
timestamp=$(date +%s)
echo "Cloning repo pmc-service"
git clone https://github.com/plataforma-mexico-covid/pmc-service.git
echo "Cloning repo pmc-ci-cd"
git clone https://github.com/plataforma-mexico-covid/pmc-ci-cd.git
cd pmc-service && \
   echo "Getting version" && \
   string=$(head -n 1 gradle.properties) && \
   v=${string:8} && \
   vn=$v.$timestamp && \
   echo "version=$vn" > gradle.properties  && \
   docker login -u _json_key -p "$(cat /home/jenkins/service-account-key.json)" https://gcr.io && \
   bash ./gradlew buildDocker && \
   cd /home/jenkins/pmc-ci-cd/charts && \
   echo "Installing version $vn" && \
   docker tag mx.mexicocovid19.plataforma/pmc-service:$vn gcr.io/plataforma-mexico-covid19/pmc-service:$vn && \
   docker push gcr.io/plataforma-mexico-covid19/pmc-service:$vn && \
   bash install.sh pmc-service pmc-test /home/jenkins/kubeconfig.yaml upgrade $vn values.test.yaml && \
   docker rmi mx.mexicocovid19.plataforma/pmc-service:$vn && \
   docker rmi gcr.io/plataforma-mexico-covid19/pmc-service:$vn