curl -LOk https://github.com/taniasosaux/cc/archive/master.zip && \
rm -fr cc-master && \
unzip master.zip && \
v=$(head -n 1 version) && \
vn="${v%.*}.$((${v##*.}+1))" && \
echo "$vn" > version && \
bash builddocker.sh $vn