#sudo hyper list pod | grep hyper-stream | grep -v "pod-.*running" | awk '{print $1}' | xargs -i sudo hyper stop {}
#sudo hyper list pod | grep hyper-stream | grep -v "pod-.*running" | awk '{print $1}' | xargs -i sudo hyper rm {}
#sudo hyper list | grep hyper-stream | grep running | wc -l


# bulk create hyper pod
for i in `seq 1 251`
do
	echo "create pod :"$i
	sudo hyper pod hyper-stream.pod
	sleep 2
done
echo "total hyper pod"
sudo hyper list | grep running | wc -l

