mkdir -p log
echo "[$(date +'%F %T')] test cpu"
./bench.sh auto-run "host docker hyper" > log/result.log

