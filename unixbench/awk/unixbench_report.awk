#!/usr/bin/awk

BEGIN{
}
/CPU Performance Test/{
  if ($6=="host"){$6="1 | "$6}
  if ($6=="docker"){$6="2 | "$6}
  if ($6=="hyper"){$6="3 | "$6}
  target=$6
}
/^test_case: /{
  test_case=$2
  key=test_case" | "target
}
/System Benchmarks Index Score/{
  f_score[key]=$5
}
END{
  print "| test-case | no | target | score |"
  print "| --- | --- | --- | --- |"
  for ( i in f_score ){
    printf "| %s | %s |\n", i, f_score[i]
  }
}