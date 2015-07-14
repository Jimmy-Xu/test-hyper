#!/bin/bash

LOG_DIR=log
AWK_DIR=awk

rm ${LOG_DIR}/*.tmp -rf >/dev/null 2>&1

cat ${LOG_DIR}/net.log | col -b > ${LOG_DIR}/net.log.tmp

dos2unix ${LOG_DIR}/*.tmp

echo
echo "| test-case | no | target | item | idx | Value |"
echo "| --- | --- | --- | --- | --- | --- |"
cat ${LOG_DIR}/net.log.tmp | awk -f ${AWK_DIR}/net_report.awk | sort
