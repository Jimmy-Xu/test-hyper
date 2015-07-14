#!/usr/bin/awk

BEGIN{
}
/CPU Performance Test/{
  if ($6=="host"){$6="1|"$6}
  if ($6=="docker"){$6="2|"$6}
  if ($6=="hyper"){$6="3|"$6}
  target=$6" | cpu"
}
/^test_case: /{
  test_case=$2
  key=target" | "test_case
}
/Number of threads/{
  if ( $4>1 ){
    f_threads[key]=$4" threads"
  }
  else{
    f_threads[key]=$4" thread"
  }
}
/Primer numbers limit/{
  f_primer[key]=$4
}
/    total time:/{
  sub("s","",$3)
  f_time[key]=$3
}
/min:/{
  sub("ms","",$2)
  f_min[key]=$2
}
/avg:/{
  sub("ms","",$2)
  f_avg[key]=$2
}
/max:/{
  sub("ms","",$2)
  f_max[key]=$2
}
END{
  #print "| no | target | item | test-case | num-threads | cpu-max-prime | total time(sec) | min(ms) | avg(ms) | max(ms) |"
  #print "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |"
  for ( i in f_time ){
    printf "| %-6s | %s | %s | %s | %s | %s | %s |\n", i, f_threads[i], f_primer[i], f_time[i], f_min[i], f_avg[i], f_max[i]
  }
}