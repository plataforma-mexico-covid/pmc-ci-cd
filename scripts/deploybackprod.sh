echo "Deleting existing directories"
rm -fr pmc-service
rm -fr pmc-ci-cd
branch=master
newbranch=develop
echo "Cloning repo pmc-service"
git clone https://github.com/plataforma-mexico-covid/pmc-service.git
echo "Cloning repo pmc-ci-cd"
git clone https://github.com/plataforma-mexico-covid/pmc-ci-cd.git
cd pmc-service && \
   git checkout $branch && \
   echo "increasing version" && \
   string=$(head -n 1 gradle.properties) && \
   v=${string:8} && \
   vn="${v%.*}.$((${v##*.}+1))" && \
   echo "Previous version $v New version $vn" && \
   docker login -u _json_key -p "$(cat /home/jenkins/service-account-key.json)" https://gcr.io && \
   bash ./gradlew buildDocker && \
   echo "$GIT_USER" && \
   git remote set-url origin https://${GIT_USER}:${GIT_PASS}@github.com/plataforma-mexico-covid/pmc-service.git && \
   echo "Tagging realease $v and pushing to $branch" && \
   git tag v$v && \
   git push origin v$v && \
   echo "Increasing version" && \
   echo "version=$vn" > gradle.properties  && \
   echo "Checkout $newbranch and pulling latest" && \
   git checkout $newbranch && \
   git pull && \
   git add gradle.properties && \
   git commit -m "Increasing version $vn" && \
   echo "Pushing to $newbranch" && \
   git push origin $newbranch  && \
   cd /home/jenkins/pmc-ci-cd/charts && \
   echo "Installing version $v" && \
   docker tag mx.mexicocovid19.plataforma/pmc-service:$v gcr.io/plataforma-mexico-covid19/pmc-service:$v && \
   docker push gcr.io/plataforma-mexico-covid19/pmc-service:$v && \
   bash install.sh pmc-service pmc-prod /home/jenkins/kubeconfig.yaml upgrade $v && \
   docker rmi mx.mexicocovid19.plataforma/pmc-service:$v && \
   docker rmi gcr.io/plataforma-mexico-covid19/pmc-service:$v 
