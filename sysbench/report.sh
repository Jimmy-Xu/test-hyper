#!/bin/bash

LOG_DIR=log
AWK_DIR=awk

rm ${LOG_DIR}/*.tmp -rf >/dev/null 2>&1

cat ${LOG_DIR}/cpu.log | col -b > ${LOG_DIR}/cpu.log.tmp
cat ${LOG_DIR}/mem.log | col -b > ${LOG_DIR}/mem.log.tmp
cat ${LOG_DIR}/io.log | col -b > ${LOG_DIR}/io.log.tmp

dos2unix ${LOG_DIR}/*.tmp

echo
echo "| no | target | item | test-case | num-threads | cpu-max-prime | total time(sec) | min(ms) | avg(ms) | max(ms) |"
echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |"
cat ${LOG_DIR}/cpu.log.tmp | grep -A24 "CPU Performance Test -" | awk -f ${AWK_DIR}/cpu_report.awk | sort

echo
echo "| no | target | item | test-mode | test-case | threads | total-size(GB) | ops/sec | speed(MB/sec) | time(sec) | min(ms) | avg(ms) | max(ms) |"
echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |"
cat ${LOG_DIR}/mem.log.tmp | grep -A26 "Memory Test -" | awk -f ${AWK_DIR}/mem_report.awk | sort

echo
echo "| no | target | item | test-mode | test-case | threads | total-size | block-size | IOPS(req/sec) | speed(MB/sec) | time(sec) | min(ms) | avg(ms) | max(ms) |"
echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |"
cat ${LOG_DIR}/io.log.tmp | grep -A50 "IO Test -" | awk -f ${AWK_DIR}/io_report.awk | sort
