#!/bin/bash

LOG_DIR=log
AWK_DIR=awk

rm ${LOG_DIR}/*.tmp -rf >/dev/null 2>&1

cat ${LOG_DIR}/dhry2.log | col -b > ${LOG_DIR}/dhry2.log.tmp
cat ${LOG_DIR}/whets.log | col -b > ${LOG_DIR}/whets.log.tmp
cat ${LOG_DIR}/lpack.log | col -b > ${LOG_DIR}/lpack.log.tmp

dos2unix ${LOG_DIR}/*.tmp

echo
cat ${LOG_DIR}/dhry2.log.tmp | awk -f ${AWK_DIR}/cpu_report_dhry2.awk

echo
cat ${LOG_DIR}/whets.log.tmp | awk -f ${AWK_DIR}/cpu_report_whets.awk

echo
cat ${LOG_DIR}/lpack.log.tmp | awk -f ${AWK_DIR}/cpu_report_lpack.awk
