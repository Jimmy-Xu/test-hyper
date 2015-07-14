# see http://ubuntu-smoser.blogspot.co.uk/2013/02/using-ubuntu-cloud-images-without-cloud.html
# see http://cloud-images.ubuntu.com/releases or http://uec-images.ubuntu.com/trusty/current/
# http://docs.openstack.org/zh_CN/image-guide/content/ch_obtaining_images.html

#all: id_rsa cloud-localds cirros coreos ubuntu-13.10-server-cloudimg-amd64-disk1.img seed.img play.img
all: id_rsa cloud-localds cirros coreos ubuntu-14.04-server-cloudimg-amd64-disk1.img seed.img play-trusty.img

# download a clean VM image
ubuntu-13.10-server-cloudimg-amd64-disk1.img:
	wget -c http://cloud-images.ubuntu.com/releases/13.10/release-20140409.1/ubuntu-13.10-server-cloudimg-amd64-disk1.img

ubuntu-14.04-server-cloudimg-amd64-disk1.img:
	#wget -c http://cloud-images.ubuntu.com/releases/14.04/release-20140416.1/ubuntu-14.04-server-cloudimg-amd64-disk1.img
	wget -c http://cloud-images.ubuntu.com/releases/14.04/release-20150706/ubuntu-14.04-server-cloudimg-amd64-disk1.img

# convert user data into an ISO image
seed.img: user-data
	cloud-localds seed.img user-data

# build a qcow layer for playing around
play.img: ubuntu-13.10-server-cloudimg-amd64-disk1.img
	qemu-img create -f qcow2 -b ubuntu-13.10-server-cloudimg-amd64-disk1.img play.img

play-trusty.img: ubuntu-14.04-server-cloudimg-amd64-disk1.img
	qemu-img create -f qcow2 -b ubuntu-14.04-server-cloudimg-amd64-disk1.img play.img

cloud-localds:
	if [ ! -f /usr/local/bin/cloud-localds ];then \
		sudo apt-get install cloud-utils;\
		wget -c https://launchpad.net/cloud-utils/trunk/0.27/+download/cloud-utils-0.27.tar.gz;\
		tar xzvf cloud-utils-0.27.tar.gz;\
		sudo cp cloud-utils-0.27/bin/cloud-localds /usr/local/bin;\
	else \
		echo "cloud-localds already installed";\
	fi

id_rsa:
	chmod 400 ../id_rsa

cirros:
	if [ ! -f cirros-0.3.3-x86_64-disk.img ];then \
		wget -c http://download.cirros-cloud.net/0.3.3/cirros-0.3.3-x86_64-disk.img;\
	else \
		echo "cirros-0.3.3-x86_64-disk.img already downloaded";\
	fi

coreos:
	if [ ! -f coreos_production_qemu_image.img ];then \
		wget -c  http://stable.release.core-os.net/amd64-usr/current/coreos_production_qemu_image.img.bz2 -O - | bzcat > coreos_production_qemu_image.img;\
	else \
		echo "coreos_production_qemu_image.img already downloaded";\
	fi


clean:
	rm *.img
