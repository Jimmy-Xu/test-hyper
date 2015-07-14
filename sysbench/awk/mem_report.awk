#!/usr/bin/awk

BEGIN{
}
/Memory Test -/{
  if ($8=="host"){$8="1|"$8}
  if ($8=="docker"){$8="2|"$8}
  if ($8=="hyper"){$8="3|"$8}
  target=$8" | mem | "$5"-"$6
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
/Operations performed/{
  sub(/[(]/,"",$4)
  f_opsps[key]=$4
}
/ transferred /{
  f_totol_size[key]=$1
  sub(/[(]/,"",$4)
  f_speed[key]=$4
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
  # print "| no | target | item | test-mode | test-case | threads | total-size(GB) | ops/sec | speed(MB/sec) | time(sec) | min(ms) | avg(ms) | max(ms) |"
  # print "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |"
  for ( i in f_time ){
    printf "| %-6s | %s | %d | %d | %d | %.2f | %s | %s | %s |\n", i, f_threads[i], f_totol_size[i]/1024, f_opsps[i], f_speed[i], f_time[i], f_min[i], f_avg[i], f_max[i]
  }
}