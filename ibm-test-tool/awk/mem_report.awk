#!/usr/bin/awk

BEGIN{
  idx=0
}
/Function/{
  key=target" | "idx
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
  # print "| test-case | no | target | item | idx | GB/s | Function |"
  # print "| --- | --- | --- | --- | --- | --- | --- |"
  for ( i in f_copy ){
    printf "| %s | %s | Copy |\n", i, f_copy[i]
    printf "| %s | %s | Scale |\n", i, f_scale[i]
    printf "| %s | %s | Add |\n", i, f_add[i]
    printf "| %s | %s | Triad |\n", i, f_triad[i]
  }
}