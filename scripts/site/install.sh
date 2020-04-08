curl -LOk https://github.com/taniasosaux/mexicoVsCovid/archive/master.zip && \
unzip master.zip && \
rm -fr mexicoVsCovid && \
mv mexicoVsCovid-master mexicoVsCovid && \
v=$(head -n 1 version) && \
vn="${v%.*}.$((${v##*.}+1))" && \
echo "$vn" > version && \
bash builddocker.sh $vn
