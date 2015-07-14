
http://linux-sunxi.org/Benchmarks

#download and build
	wget 'http://www.roylongbottom.org.uk/classic_benchmarks.tar.gz'
	wget 'http://linux-sunxi.org/images/a/a1/Classic_benchmarks.patch'
	tar -xzf classic_benchmarks.tar.gz
	patch -p0 < Classic_benchmarks.patch
	cd classic_benchmarks/source_code/
	make
#how to use
	./dhry1
	./dhry2
	./lloops
	./lpack
	./whets

	#noneinteractive
	./dhry1 n

#############################################################

#step 1

	git clone https://github.com/Jimmy-Xu/classic_benchmarks.git
	cd classic_benchmarks/source_code
	make

#step 2

 - DMIPS 
	classic_benchmarks/source_code/dhry1 n 
	classic_benchmarks/source_code/dhry2 n

 - MWIPS(MFLOPS) 
	classic_benchmarks/source_code/whets n 
	classic_benchmarks/source_code/lpack n
 - 
	classic_benchmarks/source_code/lloops n
