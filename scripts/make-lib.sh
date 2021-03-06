#/bin/sh

# TODO: make ##version## replacements in rita.js && /RiTaLibraryJS/www/download/index.html

if [ $# -lt "1"  ]
then
    echo
    echo "  error:   tag or version required"
    echo
    echo "  usage:   make-lib.sh [tag] [-p -D -M] "
    echo "           make-lib.sh 1.0.63a -p -D -M"
    echo
    echo "  options:"
    echo "       -p = publish-after-build "
    echo "       -D = dont-make-docs"
    echo "       -M = dont-minimize-lib"
    echo "       -Z = dont-make-zip"
    echo "       -c = -DMZ (just combine js)" 
    exit
fi

VERSION=$1
MAKE_ZIP=1
DO_PUBLISH=0
INCLUDE_DOCS=1
MINIMIZE_SRC=1

while [ $# -ge 1 ]; do
    case $1 in
        -D) INCLUDE_DOCS=0  ;;
    esac
    case $1 in
        -Z) MAKE_ZIP=0  ;;
    esac
    case $1 in
        -p) DO_PUBLISH=1  ;;
    esac
    case $1 in
        -M) MINIMIZE_SRC=0  ;;
    esac
    case $1 in
        -c) MINIMIZE_SRC=0  
            INCLUDE_DOCS=0
            MAKE_ZIP=0  
            ;;
    esac
    shift
done
#echo "DOCS=$INCLUDE_DOCS"
#echo "PUB=$DO_PUBLISH"
#echo "MIN=$MINIMIZE_SRC"

##############################################################

BUILD=../build
COMPILE="java -jar ../tools/compiler-latest/compiler.jar"

CSS=../www/css
JSDOC=../tools/jsdoc-toolkit
SRC=../src/rita.js
ALL_SRC="../src/rita_dict.js ../src/rita_lts.js ../src/rita.js"

DOWNLOAD_DIR=../www/download
DIST_DIR=../dist
REF_DIR=../www/reference
RITA_CODE=$DOWNLOAD_DIR/rita-$VERSION.js
RITA_CODE_MIN=$DOWNLOAD_DIR/rita-$VERSION.min.js

ZIP_TMP=/tmp/rita-$VERSION
ZIP_FILE=rita-full-$VERSION.zip

P5_JAVA=~/Documents/Processing/libraries/RiTa/library/rita.js

echo
echo Building RiTaJS v$VERSION ------------------------------
echo

###COMPILE############################################################

# clean the target dir first
mv $DOWNLOAD_DIR/*.js $DIST_DIR
mv $DOWNLOAD_DIR/*.zip $DIST_DIR

echo "Combining rita-*.js as ${RITA_CODE}"; 
rm -f $RITA_CODE
cat $ALL_SRC >> $RITA_CODE

if [ $MINIMIZE_SRC = 1 ]
then
    echo "Compiling rita-*.js as ${RITA_CODE_MIN}"; 
    $COMPILE --js  ${ALL_SRC} --js_output_file $RITA_CODE_MIN --summary_detail_level 3 \
                  --compilation_level SIMPLE_OPTIMIZATIONS 
else
    echo
    echo Skipping minimization
fi

#echo "Compiling rita-*.js as ${RITA_CODE_MIN}_adv.js"; 
#$COMPILE --js  ${ALL_SRC} --js_output_file "${RITA_CODE_MIN}_adv.js" --summary_detail_level 3 \
#  --compilation_level ADVANCED_OPTIMIZATIONS 

###DOCS###############################################################

if [ $INCLUDE_DOCS = 1 ]
then
    echo
    echo Building js-docs...
    #rm -rf $REF_DIR/*
    #java -Xmx512m -jar $JSDOC/jsrun.jar $JSDOC/app/run.js -d=$REF_DIR -a \
    #    -t=$JSDOC/templates/ritajs -D="status:alpha" -D="version:$VERSION" $SRC > docs-err.txt 
   ./make-docs.sh 
else
    echo
    echo Skipping docs...
fi


###EXAMPLES ##########################################################

echo
echo Copying examples
cd .
cp -r ../test/renderer/multitest.html ../www/example/
#cp -r ../test/renderer/*.wav ../www/example/  # ???? 
cp -r ../test/renderer/canvas ../test/renderer/processing ../www/example/
## also need to copy libraries for local www??
echo

###ZIP###############################################################


if [ $INCLUDE_DOCS = 1 ]
then
    echo Making complete zip 
    rm -rf $ZIP_TMP
    mkdir $ZIP_TMP
    cd ../www
    cp -r example download/*.js reference tutorial css $ZIP_TMP
    cd - 
    cd $ZIP_TMP
    jar cf $ZIP_FILE *
    cd -
    mv $ZIP_TMP/$ZIP_FILE $DOWNLOAD_DIR
    rm -rf $ZIP_TMP
    echo
fi

###COPY##############################################################

echo Copying into $BUILD 

/bin/rm -rf $BUILD
mkdir $BUILD
cp -r ../www $BUILD
ls -l $BUILD/www/download

echo
echo Copying into $P5_JAVA  # libraries dir

cp $RITA_CODE ~/Documents/Processing/libraries/RiTa/library/rita.js

####################################################################

cd ../build/www/download/
pwd
ls -l
cd -

echo
echo Done [use pub-lib.sh or pub-js.sh to publish]

if [ $DO_PUBLISH = 1 ]
then
./pub-lib.sh $VERSION
fi
