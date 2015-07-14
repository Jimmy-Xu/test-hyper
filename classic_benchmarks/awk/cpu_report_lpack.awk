#!/usr/bin/awk

BEGIN{
}
/CPU Performance Test/{
  if ($6=="host"){$6="1 | "$6}
  if ($6=="docker"){$6="2 | "$6}
  if ($6=="hyper"){$6="3 | "$6}
  target=$6" | cpu"
}
/^test_case: /{
  test_case=$2
  key=test_case" | "target
}
/ Speed/{
  f_mflops[key]=$2
}
END{
  print "| test-case | no | target | item | MFLOPS |"
  print "| --- | --- | --- | --- | --- |"
  for ( i in f_mflops ){
    printf "| %s | %d |\n", i, f_mflops[i]
  }
}