#!/bin/sh

if [ $# != 1 ]
then
  echo
  echo "output dir required"
  echo "usage: make-docs.sh [out-dir]"
  exit
fi


#OUTDIR=$JSDOC/../../www/reference

OUTDIR=$1
SRCFILE=../src/rita.js
JSDOC=../tools/jsdoc-toolkit
CSS=../www/css


#echo copying css to $OUTDIR 
#ls $OUTDIR
#cp -r $CSS $OUTDIR

java -Xmx512m -jar $JSDOC/jsrun.jar $JSDOC/app/run.js -d=$OUTDIR/www/reference -a \
    -t=$JSDOC/templates/ritajs $SRCFILE > docs-err.txt
