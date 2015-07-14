
git clone git@github.com:Jimmy-Xu/byte-unixbench.git@github
cd byte-unixbench
git checkout mine



########################################

# Step 1: build docker image, create test pod
./bench.sh init

# Setp 2: see help
./bench.sh

# Step 3: auto test, output is log/cpu.log
sudo ./bat.sh


# Step 4: generate result
./report.sh

# Step 5: view report with markdown


=====================================================
SEQNO=$1
UBTXT=ubtest.txt
DL=+
ID="i-xxxxx"
TYPE="t1.micro"
FN=$ID$DL$TYPE$DL$SEQNO$DL$UBTXT
COPIES=`cat /proc/cpuinfo|grep processor|wc -l`
./Run -c 1 -c $COPIES > $FN
...
grep "Ssystem Benchmarks Index Score" i-*$UBTXT >ubresults.txt
cat ubresults.txt | sed s/".txt:System Benchmarks Index Score"// | \
  awk '/i-/{print $1";"$2}' > ubresults.csv

