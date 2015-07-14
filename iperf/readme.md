
sudo docker build -t hyper:iperf --no-cache=true --rm=true .



apt-get install iperf
yum install iperf

#hyper-ww is server
iperf -s

#packet.net bare metal server is client
iperf -c 52.8.138.39 -i 2 -t 20 -f M

#run in docker
docker run -it hyper:iperf bash -c "iperf -c 52.8.138.39 -i 2 -t 20 -f M"

#run in hyper
sudo hyper run hyper:iperf bash -c "iperf -c 52.8.138.39 -i 2 -t 20 -f M"