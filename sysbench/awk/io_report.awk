#!/usr/bin/awk

BEGIN{
}
/IO Test -/{
  if ($7=="host"){$7="1|"$7}
  if ($7=="docker"){$7="2|"$7}
  if ($7=="hyper"){$7="3|"$7}
  target=$7" | io | "$5
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
/^Block size/{
  f_block_size[key]=$3
}
/Total transferred/{
  f_totol_size[key]=$7
  sub(/[(]/,"",$8)
  sub(/[)]/,"",$8)
  if (index($8,"Mb/sec")){
    sub("Mb/sec","",$8)
  }
  if (index($8,"Gb/sec")){
    sub("Gb/sec","",$8)
    $8=$8*1024
  }
  f_speed[key]=$8
}
/Requests\/sec executed/{
  f_req[key]=$1
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
  #print "| no | target | item | test-mode | test-case | threads | total-size | block-size | IOPS(req/sec) | speed(MB/sec) | time(sec) | min(ms) | avg(ms) | max(ms) |"
  #print "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |"
  for ( i in f_time ){
    printf "| %-6s | %s | %s | %s | %d | %.2f | %.2f | %s | %s | %s |\n", i, f_threads[i], f_totol_size[i], f_block_size[i], f_req[i], f_speed[i], f_time[i], f_min[i], f_avg[i], f_max[i]
  }
}