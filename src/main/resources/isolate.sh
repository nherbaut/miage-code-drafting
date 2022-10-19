GID=$1
CLASS_FILE_DIR=$2
CLASS_NAME=$3

ERR_FILE=err.out
isolate -s --cg -b$GID --cleanup
ISOLATE_PATH=$(isolate -s -b$GID --cg --init)
echo ### $ISOLATE_PATH
META_OUTPUT=$ISOLATE_PATH/box/meta.txt
cp $CLASS_FILE_DIR/*.class $ISOLATE_PATH/box
mkdir -p $ISOLATE_PATH/box/jre
cp -r $JAVA_HOME/* $ISOLATE_PATH/box/jre
isolate\
	-E LANG="en_US.UTF-8"\
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
    cat $ISOLATE_PATH/box/res.out
    #isolate -b$GID --cg -s --cleanup
  else
    echo ##### Runtime Info #######
    #cat $META_OUTPUT
    echo ##### STDERR ##########
    cat $ISOLATE_PATH/box/$ERR_FILE >&2
    echo ##### STDOUT ##########
    cat $ISOLATE_PATH/box/res.out|tail -n 1000
    #isolate -b$GID --cg --cleanup
    exit 26
  fi



