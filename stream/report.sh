#!/bin/bash

LOG_DIR=log
AWK_DIR=awk

rm ${LOG_DIR}/*.tmp -rf >/dev/null 2>&1

cat ${LOG_DIR}/mem.log | col -b > ${LOG_DIR}/mem.log.tmp

dos2unix ${LOG_DIR}/*.tmp

echo
echo "| test-case | no | target | item | idx | MB/s | Function |"
echo "| --- | --- | --- | --- | --- | --- | --- |"
cat ${LOG_DIR}/mem.log.tmp | awk -f ${AWK_DIR}/mem_report.awk | sort
