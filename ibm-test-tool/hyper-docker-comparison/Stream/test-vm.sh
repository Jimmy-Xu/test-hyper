rm tmp* -rf
for i in `seq 1 107`
do
	IMG=`mktemp tmpXXX.img`
	echo "create vm($IMG):"$i
	PORT=$((2200+i))
	cp vm.img ${IMG};
	sudo kvm -net nic -net user -hda ${IMG} -hdb ../common/vm/seed.img -m 512M -smp 1 -nographic -redir :${PORT}::22 >results/$IMG.log &
#	sudo kvm -net nic -net user -hda ${IMG} -hdb ../common/vm/seed.img -m 512M -smp 1 -nographic -redir :${PORT}::22 
	sleep 5
done
echo "total vm"
ps -ef | grep qemu | grep -v grep |wc -l 

