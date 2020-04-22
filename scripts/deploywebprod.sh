echo "Deleting existing directories"
rm -fr pmc-web
rm -fr pmc-ci-cd
branch=master
echo "Cloning repo pmc-web"
git clone https://github.com/plataforma-mexico-covid/pmc-web.git
echo "Cloning repo pmc-ci-cd"
git clone https://github.com/plataforma-mexico-covid/pmc-ci-cd.git
cd pmc-web && \
   echo "increasing version" && \
   v=$(head -n 1 version) && \
   vr=$v-release && \
   vn="${v%.*}.$((${v##*.}+1))" && \
   echo "Previous version $v New version $vn" && \
   bash build.sh install none && \
   docker login -u _json_key -p "$(cat /home/jenkins/service-account-key.json)" https://gcr.io && \
   bash builddocker.sh $vr && \
   echo "$GIT_USER" && \
   git remote set-url origin https://${GIT_USER}:${GIT_PASS}@github.com/plataforma-mexico-covid/pmc-web.git && \
   echo "Tagging realease $vr and pushing to $branch" && \
   git tag -a v$vr -m "version v$vr" && \
   git push origin v$vr && \
   echo "Push $branch increasing version" && \
   echo "$vn" > version && \
   git add version && \
   git commit -m "Increasing version $vn" && \
   git push origin $branch  && \
   cd /home/jenkins/pmc-ci-cd/charts && \
   echo "Installing version $vr" && \
   bash install.sh pmc-web pmc-prod /home/jenkins/kubeconfig.yaml install $vr && \
   bash /home/jenkins/pmc-web/deleteimage.sh $vr