#!/usr/bin/awk

BEGIN{
}
/Network Performance Test/{
  if ($6=="host"){$6="1 | "$6}
  if ($6=="docker"){$6="2 | "$6}
  if ($6=="hyper"){$6="3 | "$6}
  target=$6" | net"
}
/^test_case: /{
  test_case=$2
  idx=1
}
/Throughput|Rate/{
  START=0
  key=test_case" | "target" | "idx
}
{
  START=START+1
  if (test_case == "TCP_STREAM" && START==4){
    f_value[key]=$NF
    idx=idx+1
  }
  else if(test_case == "UDP_STREAM" && START==5){
    f_value[key]=$NF
    idx=idx+1
  }
  else if(test_case == "TCP_RR" && START==4){
    f_value[key]=$NF
    idx=idx+1
  }
  else if(test_case == "TCP_CRR" && START==4){
    f_value[key]=$NF
    idx=idx+1
  }
  else if(test_case == "UDP_RR" && START==4){
    f_value[key]=$NF
    idx=idx+1
  }
 }
END{
  # print "| test-case | no | target | item | idx | Value |"
  # print "| --- | --- | --- | --- | --- | --- |"
  for ( i in f_value ){
    printf "| %s | %s |\n", i, f_value[i]
  }
}