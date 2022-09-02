GID=$1
CLASS_FILE_DIR=$2
CLASS_NAME=$3
META_OUTPUT=/var/local/lib/isolate/$GID/box/meta.txt
ERR_FILE=err.out
isolate -s --cg --cleanup
ISOLATE_PATH=$(isolate -s --cg --init)
cp $CLASS_FILE_DIR/*.class $ISOLATE_PATH/box
mkdir -p $ISOLATE_PATH/box/jre
cp -r $JAVA_HOME/* $ISOLATE_PATH/box/jre
isolate\
        -s\
        -b$GID\
        -p\
        --time=10\
        --cg-timing\
        --cg\
        -M $META_OUTPUT \
        -o res.out\
        -r $ERR_FILE\
        --run -- jre/bin/java -Xmx32m $3
  SIGNAL=$?
  if [ $SIGNAL -eq 0 ]
  then
    cat $ISOLATE_PATH/box/res.out|tail -n 1000
    #isolate --cg --cleanup
  else
    echo ##### Runtime Info #######
    cat $META_OUTPUT
    echo ##### STDERR ##########
    cat $ISOLATE_PATH/box/$ERR_FILE|grep message|cut -b 1-9  --complement
    echo ##### STDOUT ##########
    cat $ISOLATE_PATH/box/res.out|tail -n 1000
    #isolate --cg --cleanup
    exit 26
  fi



