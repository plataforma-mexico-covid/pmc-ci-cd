echo "Deleting existing directories"
rm -fr pmc-web
rm -fr pmc-ci-cd
branch=master
newbranch=develop
echo "Cloning repo pmc-web"
git clone https://github.com/plataforma-mexico-covid/pmc-web.git
echo "Cloning repo pmc-ci-cd"
git clone https://github.com/plataforma-mexico-covid/pmc-ci-cd.git
cd pmc-web && \
   git checkout $branch && \
   echo "increasing version" && \
   v=$(head -n 1 version) && \
   vn="${v%.*}.$((${v##*.}+1))" && \
   echo "Previous version $v New version $vn" && \
   bash build.sh install none && \
   docker login -u _json_key -p "$(cat /home/jenkins/service-account-key.json)" https://gcr.io && \
   bash builddocker.sh $v && \
   echo "$GIT_USER" && \
   git remote set-url origin https://${GIT_USER}:${GIT_PASS}@github.com/plataforma-mexico-covid/pmc-web.git && \
   echo "Tagging realease $v and pushing to $branch" && \
   git tag v$v && \
   git push origin v$v && \
   echo "Checkout $newbranch and pulling latest" && \
   git checkout $newbranch && \
   git pull && \
   echo "Increasing version" && \
   echo "$vn" > version && \
   git add version && \
   git commit -m "Increasing version $vn" && \
   echo "Checkout pushing to $newbranch" && \
   git push origin $newbranch  && \
   cd /home/jenkins/pmc-ci-cd/charts && \
   echo "Installing version $v" && \
   bash install.sh pmc-web pmc-prod /home/jenkins/kubeconfig.yaml upgrade $v && \
   bash /home/jenkins/pmc-web/deleteimage.sh $v
