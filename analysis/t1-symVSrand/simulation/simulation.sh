#!/bin/bash

MAUDE_DIR=/home/ksron/maude-z3
MAUDE_BIN=maude
MAUDE_COM="$MAUDE_DIR/$MAUDE_BIN -no-advise -no-prelude -no-banner $MAUDE_DIR/prelude.maude $MAUDE_DIR/smt.maude"

RANGE=1000000

file=$1
searchFile=$2
SEARCH_DEPTH=$3
repete=$4

RESULT_FILE=${file%.*}_${SEARCH_DEPTH}

RUNTIME=0

echo "Simulating " $file " module "  $repete "times"

while [ "$RUNTIME" -lt $repete ]
do
#  echo $RUNTIME
  RUNTIME=$((RUNTIME + 1))  
  number=$RANDOM
  let "number %= $RANGE"

  TEMP_FILE=${RESULT_FILE}.anal
  sed "s/000/${number}/g" ${searchFile} | sed "s/&&&/${SEARCH_DEPTH}/g"  > ${TEMP_FILE}

  echo "quit" | $MAUDE_COM $file $TEMP_FILE > ${RESULT_FILE}_${RUNTIME}
  
  sed -n "/E:Set{Exp} -->/,/^ *$/p" ${RESULT_FILE}_${RUNTIME} | sed '/./{:a;N;s/\n\(.\)/ \1/;ta}' > ${RESULT_FILE}_${RUNTIME}.log
#grep "E:Set{Exp} -->" ${RESULT_FILE}_${RUNTIME} > ${RESULT_FILE}_${RUNTIME}.log
  sed -i "s/\[//g" ${RESULT_FILE}_${RUNTIME}.log
  sed -i "s/\]//g" ${RESULT_FILE}_${RUNTIME}.log
  sed -i "s/^.*> //" ${RESULT_FILE}_${RUNTIME}.log
  sed -i "s/;/,/g" ${RESULT_FILE}_${RUNTIME}.log
  sed -i "/^$/d" ${RESULT_FILE}_${RUNTIME}.log
 
  rm ${RESULT_FILE}_${RUNTIME}
  rm ${TEMP_FILE}
done
