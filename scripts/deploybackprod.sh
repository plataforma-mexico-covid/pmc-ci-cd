echo "Deleting existing directories"
rm -fr pmc-service
rm -fr pmc-ci-cd
branch=master
echo "Cloning repo pmc-service"
git clone https://github.com/plataforma-mexico-covid/pmc-service.git
echo "Cloning repo pmc-ci-cd"
git clone https://github.com/plataforma-mexico-covid/pmc-ci-cd.git
cd pmc-service && \
   echo "increasing version" && \
   string=$(head -n 1 gradle.properties) && \
   v=${string:8} && \
   vr=$v-release && \
   vn="${v%.*}.$((${v##*.}+1))" && \
   echo "Previous version $v New version $vn" && \
   docker login -u _json_key -p "$(cat /home/jenkins/service-account-key.json)" https://gcr.io && \
   echo "Building release version" && \
   echo "version=$vr" > gradle.properties  && \
   bash ./gradlew buildDocker && \
   echo "$GIT_USER" && \
   git remote set-url origin https://${GIT_USER}:${GIT_PASS}@github.com/plataforma-mexico-covid/pmc-service.git && \
   echo "Tagging realease $vr and pushing to $branch" && \
   git tag -a v$vr -m "version v$vr" && \
   git push origin v$vr && \
   echo "Increasing version" && \
   echo "version=$vn" > gradle.properties  && \
   git add gradle.properties && \
   git commit -m "Increasing version $vn" && \
   echo "Pushing to $branch" && \
   git push origin $branch  && \
   cd /home/jenkins/pmc-ci-cd/charts && \
   echo "Installing version $vr" && \
   docker tag mx.mexicocovid19.plataforma/pmc-service:$vr gcr.io/plataforma-mexico-covid19/pmc-service:$vr && \
   docker push gcr.io/plataforma-mexico-covid19/pmc-service:$vr && \
   bash install.sh pmc-service pmc-prod /home/jenkins/kubeconfig.yaml upgrade $vr && \
   docker rmi mx.mexicocovid19.plataforma/pmc-service:$vr && \
   docker rmi gcr.io/plataforma-mexico-covid19/pmc-service:$vr