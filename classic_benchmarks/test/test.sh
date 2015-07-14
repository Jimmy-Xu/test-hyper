#/bin/bash

# echo "[$(date +'%F %T')] test cpu - dhry1"
# classic_benchmarks/source_code/dhry1 n

case "$1" in
	dhry2)
	  echo "[$(date +'%F %T')] test cpu - dhry2"
	  classic_benchmarks/source_code/dhry2 n
	  ;;
	whets)
	  echo "[$(date +'%F %T')] test cpu - whets"
	  classic_benchmarks/source_code/whets n
	  ;;
	lpack)
	  echo "[$(date +'%F %T')] test cpu - lpack"
	  classic_benchmarks/source_code/lpack n
	  ;;
	*)
	  echo "Usage: ./test.sh <method>"
	  echo "method: dhry2 | whets | lpack"
	  ;;
esac



