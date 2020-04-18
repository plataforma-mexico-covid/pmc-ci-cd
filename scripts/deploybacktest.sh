echo "Deleting existing directories"
rm -fr pmc-service
rm -fr pmc-ci-cd
branch=develop
timestamp=$(date +%s)
echo "Cloning repo pmc-service"
git clone https://github.com/plataforma-mexico-covid/pmc-service.git
echo "Cloning repo pmc-ci-cd"
git clone https://github.com/plataforma-mexico-covid/pmc-ci-cd.git
cd pmc-service && \
   git checkout $branch && \
   echo "Getting version" && \
   string=$(head -n 1 gradle.properties) && \
   v=${string:8} && \
   vn=$v.$timestamp && \
   echo "version=$vn" > gradle.properties  && \
   docker login -u _json_key -p "$(cat /home/jenkins/service-account-key.json)" https://gcr.io && \
   bash ./gradlew buildDocker && \
   cd /home/jenkins/pmc-ci-cd/charts && \
   echo "Installing version $vn" && \
   docker tag mx.mexicocovid19.plataforma/pmc-service:$v gcr.io/plataforma-mexico-covid19/pmc-service:$v && \
   docker push gcr.io/plataforma-mexico-covid19/pmc-service:$v && \
   bash install.sh pmc-service pmc-prod /home/jenkins/kubeconfig.yaml upgrade $v values.test.yaml && \
   docker rmi mx.mexicocovid19.plataforma/pmc-service:$v && \
   docker rmi gcr.io/plataforma-mexico-covid19/pmc-service:$v 
