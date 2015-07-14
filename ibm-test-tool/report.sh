#!/bin/bash

AWK_DIR=awk

METHOD=$1

if [ "$METHOD" == "Stream" ];then
	rm ${LOG_DIR}/*.tmp -rf >/dev/null 2>&1
	LOG_DIR=log/"${METHOD}"
	cat ${LOG_DIR}/linux.log | col -b > ${LOG_DIR}/linux.log.tmp
	cat ${LOG_DIR}/vm.log | col -b > ${LOG_DIR}/vm.log.tmp
	cat ${LOG_DIR}/docker.log | col -b > ${LOG_DIR}/docker.log.tmp
	cat ${LOG_DIR}/hyper.log | col -b > ${LOG_DIR}/hyper.log.tmp

	dos2unix ${LOG_DIR}/*.tmp

	echo
	echo "| target | idx | GB/s | Function |"
	echo "| --- | --- | --- | --- |"
	cat ${LOG_DIR}/linux.log.tmp | awk -v target="host" -f ${AWK_DIR}/mem_report.awk | sort
	cat ${LOG_DIR}/vm.log.tmp | awk -v target="kvm" -f ${AWK_DIR}/mem_report.awk | sort
	cat ${LOG_DIR}/docker.log.tmp | awk -v target="docker" -f ${AWK_DIR}/mem_report.awk | sort
	cat ${LOG_DIR}/hyper.log.tmp | awk -v target="hyper" -f ${AWK_DIR}/mem_report.awk | sort
else

	echo "usage: ./report.sh <method>"
	echo "method: Stream | fio "
fi