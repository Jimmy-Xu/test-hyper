#!/usr/bin/awk

BEGIN{
}
/Memory Performance Test/{
  if ($6=="host"){$6="1 | "$6}
  if ($6=="docker"){$6="2 | "$6}
  if ($6=="hyper"){$6="3 | "$6}
  target=$6" | mem"
}
/^test_case: /{
  test_case=$2
  idx=1
}
/Function/{
  key=test_case" | "target" | "idx
  idx=idx+1
}
/Copy:/{
  f_copy[key]=$2
}
/Scale:/{
  f_scale[key]=$2
}
/Add:/{
  f_add[key]=$2
}
/Triad:/{
  f_triad[key]=$2
}

END{
  # print "| test-case | no | target | item | idx | MB/s | Function |"
  # print "| --- | --- | --- | --- | --- | --- | --- |"
  for ( i in f_copy ){
    printf "| %s | %s | Copy |\n", i, f_copy[i]
    printf "| %s | %s | Scale |\n", i, f_scale[i]
    printf "| %s | %s | Add |\n", i, f_add[i]
    printf "| %s | %s | Triad |\n", i, f_triad[i]
  }
}