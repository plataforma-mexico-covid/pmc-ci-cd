echo "Deleting existing directories"
rm -fr pmc-web
rm -fr pmc-ci-cd
branch=develop
timestamp=$(date +%s)
echo "Cloning repo pmc-web"
git clone https://github.com/plataforma-mexico-covid/pmc-web.git
echo "Cloning repo pmc-ci-cd"
git clone https://github.com/plataforma-mexico-covid/pmc-ci-cd.git
cd pmc-web && \
   git checkout $branch && \
   echo "Getting version" && \
   v=$(head -n 1 version) && \
   vn=$v.$timestamp && \
   bash build.sh install none && \
   docker login -u _json_key -p "$(cat /home/jenkins/service-account-key.json)" https://gcr.io && \
   bash builddocker.sh $vn && \
   cd /home/jenkins/pmc-ci-cd/charts && \
   echo "Installing version $vn" && \
   bash install.sh pmc-web pmc-test /home/jenkins/kubeconfig.yaml upgrade $vn values.test.yaml && \
   bash /home/jenkins/pmc-web/deleteimage.sh $vn
