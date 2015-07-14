
mkdir -p log

 
echo "[$(date +'%F %T')] test mem"
./bench.sh auto-run "host docker hyper" > log/mem.log
 