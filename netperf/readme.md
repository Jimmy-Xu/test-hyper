#test case

- use two packet.net bare metal server (hostA, hostB)
  - hostA (server - run netserver)
  - hostB (client - run netperf)
- test type
  - TCP_STREAM
  - TCP_RR
  - TCP_CRR
  - UDP_STREAM
  - UDP_RR
- user private ip
- test duration: 60 seconds
- repeat count : 5

####################################################

#start netperf server in remote
  netserver

#build docker image
  ./bench.sh init

#start test
  ./auto.sh

#generate report
  ./report.sh

171 client  149 server
| test-case | no | target | item | Throughput(KBytes/sec) |
| --- | --- | --- | --- | --- |
| UDP_STREAM | 1 | host | net | 117375.75 |
| UDP_STREAM | 2 | docker | net | 153.53 |
| UDP_STREAM | 3 | hyper | net | 179.08 |
| TCP_STREAM | 1 | host | net | 114917.95 |
| TCP_STREAM | 2 | docker | net | 114917.85 |
| TCP_STREAM | 3 | hyper | net | 114918.72 |

| test-case | no | target | item | Throughput(KBytes/sec) |
| --- | --- | --- | --- | --- |
| UDP_STREAM | 2 | docker | net | 153.53 |
| UDP_STREAM | 1 | host | net | 117371.00 |
| UDP_STREAM | 3 | hyper | net | 179.09 |
| TCP_STREAM | 2 | docker | net | 114917.23 |
| TCP_STREAM | 3 | hyper | net | 114915.63 |
| TCP_STREAM | 1 | host | net | 114903.42 |


171 server  149 client
| test-case | no | target | item | Throughput(KBytes/sec) |
| --- | --- | --- | --- | --- |
| UDP_STREAM | 1 | host | net | 117373.22 |
| UDP_STREAM | 2 | docker | net | 153.53 |
| UDP_STREAM | 3 | hyper | net | 117357.46 |
| TCP_STREAM | 1 | host | net | 114917.67 |
| TCP_STREAM | 2 | docker | net | 114912.24 |
| TCP_STREAM | 3 | hyper | net | 114916.96 |

| test-case | no | target | item | Throughput(KBytes/sec) |
| --- | --- | --- | --- | --- |
| UDP_STREAM | 2 | docker | net | 153.53 |
| UDP_STREAM | 1 | host | net | 117374.25 |
| UDP_STREAM | 3 | hyper | net | 117294.21 |
| TCP_STREAM | 2 | docker | net | 114902.30 |
| TCP_STREAM | 3 | hyper | net | 114899.93 |
| TCP_STREAM | 1 | host | net | 114918.89 |


| test-case | no | target | item | Throughput(KBytes/sec) |
| --- | --- | --- | --- | --- |
| UDP_STREAM | 2 | docker | net | 153.53 |
| UDP_STREAM | 1 | host | net | 117373.77 |
| UDP_STREAM | 3 | hyper | net | 117250.65 |
| TCP_STREAM | 2 | docker | net | 114912.71 |
| TCP_STREAM | 3 | hyper | net | 114913.90 |
| TCP_STREAM | 1 | host | net | 114906.69 |
