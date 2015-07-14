
mkdir -p log

echo "[$(date +'%F %T')] test cpu"
./bench.sh auto-run "host docker hyper" "cpu" > log/cpu.log

echo "[$(date +'%F %T')] test mem"
./bench.sh auto-run "host docker hyper" "mem" > log/mem.log

echo "[$(date +'%F %T')] test io"
./bench.sh auto-run "host docker hyper" "io" > log/io.log
