export HOST="https://javarunner.miage.dev"
export INF_LOOP="cHVibGljIGNsYXNzIEludGVnZXJTdW0gewoKICBwdWJsaWMgc3RhdGljIHZvaWQgbWFpbihTdHJpbmcuLi5hcmdzKSB7CiAgICB3aGlsZSAodHJ1ZSkgewoKICAgIH0KICB9CgoKCn0="
export NBPROCESS=100

task(){

    /usr/bin/time --format '%E' -p curl -s "$HOST/?code=$1&run=dHJ1ZQ==" > /dev/null
    
}

for i in {0..100}
do
  task "$INF_LOOP" &
done


