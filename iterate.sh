#!/bin/bash
set -x

if [ $# -ne 12 ]; then
  echo "usage: $0 NAME MODEL_FILE RAY_FILE SETS WAYS CLSIZE T_TRV_INT_START T_TRV_INT_INCR T_TRV_INT_END T_SWITCH_START T_SWITCH_INCR T_SWITCH_END"
  exit 1
fi

NAME=$1
MODEL_FILE=$(realpath "$2")
RAY_FILE=$(realpath "$3")
SETS=$4
WAYS=$5
CLSIZE=$6
T_TRV_INT_START=$7
T_TRV_INT_INCR=$8
T_TRV_INT_END=$9
T_SWITCH_START=${10}
T_SWITCH_INCR=${11}
T_SWITCH_END=${12}

rm -rf "${NAME}.txt"

for i in $(seq "${T_TRV_INT_START}" "${T_TRV_INT_INCR}" "${T_TRV_INT_END}"); do
  for j in $(seq "${T_SWITCH_START}" "${T_SWITCH_INCR}" "${T_SWITCH_END}"); do
    rm -rf "work-${NAME}"
    mkdir "work-${NAME}"
    cd "work-${NAME}" || exit

    mkdir data
    cd data || exit
    ../../bin/generate "${MODEL_FILE}" "${RAY_FILE}" "${i}" "${j}" 1.0
    cd ..

    mkdir work
    cd work || exit
    ../../bin/tb_rtcore
    CACHE=$(../../bin/cache_stats_unified trace.txt "${SETS}" "${WAYS}" "${CLSIZE}")
    HIT=$(grep "hit" <<< "${CACHE}" | awk '{print $3}')
    MISS=$(grep "miss" <<< "${CACHE}" | awk '{print $3}')
    CLSTR=$(grep -c 'CLSTR' trace.txt)
    UPDT=$(grep -c 'UPDT' trace.txt)
    BBOX=$(grep -c 'BBOX' trace.txt)
    IST=$(grep 'IST' trace.txt | awk 'BEGIN {sum = 0} {sum += $2} END {print sum}')
    cd ..

    cd ..
    echo "${i} ${j} ${HIT} ${MISS} ${CLSTR} ${UPDT} ${BBOX} ${IST}" >> "${NAME}.txt"
  done
done

rm -rf "work-${NAME}"
