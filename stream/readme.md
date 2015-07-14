
git clone https://github.com/Jimmy-Xu/STREAM.git



###################################################
TDS=`cat /proc/cpuinfo|grep processor | wc -l`
export OMP_NUM_THREADS=$TDS
MTXT=stream.txt
DL=+
ID="i-xxxx"
TYPE="t1.micro"
FN=$ID$DL$TYPE$DL$TDS$DL$MTXT
./stream | egrep \
	"Number of Threads requested|Function|Triad|Failed|Expected|Observed" > $FN

MTXT=sysbench-mem.txt
FN=$ID$DL$TYPE$DL$TDS$DL$MTXT
./sysbench --num-threads=$TDS --test=memory run >%FN
