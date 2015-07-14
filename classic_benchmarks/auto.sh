mkdir -p log

echo "[$(date +'%F %T')] test dhry2"
./bench.sh auto-run "host docker hyper" "dhry2" > log/dhry2.log

echo "[$(date +'%F %T')] test whets"
./bench.sh auto-run "host docker hyper" "whets" > log/whets.log

echo "[$(date +'%F %T')] test lpack"
./bench.sh auto-run "host docker hyper" "lpack" > log/lpack.log
