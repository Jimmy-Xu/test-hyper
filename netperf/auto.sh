
mkdir -p log

echo "[$(date +'%F %T')] test net"
./bench.sh auto-run "host docker hyper" > log/net.log
