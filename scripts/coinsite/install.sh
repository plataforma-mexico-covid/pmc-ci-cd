curl -LOk https://github.com/taniasosaux/covidcoin/archive/master.zip && \
rm -fr covidcoin-master && \
rm -fr covidcoin && \
unzip master.zip && \
mv covidcoin-master covidcoin && \
v=$(head -n 1 version) && \
vn="${v%.*}.$((${v##*.}+1))" && \
echo "$vn" > version && \
bash builddocker.sh $vn