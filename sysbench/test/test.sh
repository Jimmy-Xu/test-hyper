#!/bin/bash
export PATH=/usr/local/bin:${PATH}

NUM_THREADS=(1 2)
CPU_MAX1=(5000 10000 50000)
CPU_MAX2=(10000 50000 100000)


cd /root/
if [ $# -eq 0 ] || [ $# -gt 0 -a "$1" == "1" ];then
  echo "use CPU_MAX1"
  CPU_MAX=(${CPU_MAX1[@]})
  LOG=cpu1.log
else
  echo "use CPU_MAX2"
  CPU_MAX=(${CPU_MAX2[@]})
  LOG=cpu2.log
fi

\rm ${LOG} -rf
touch ${LOG}

idx=1
echo
echo "$(date +'%F %T') Begin..."
for (( i = 0 ; i < ${#NUM_THREADS[@]} ; i++ ))
do
  thread="${NUM_THREADS[$i]}"
  for (( j = 0 ; j < ${#CPU_MAX[@]} ; j++ ))
  do
    cpu_max="${CPU_MAX[$j]}"
    echo "$(date +'%F %T') ${idx} (${thread},${cpu_max})";sysbench --test=cpu --cpu-max-prime=${cpu_max} --num-threads=${thread} run | grep 'total time:' >>${LOG}
    idx=$((idx+1))
  done
done

echo
echo "$(date +'%F %T') End!"
cat ${LOG}