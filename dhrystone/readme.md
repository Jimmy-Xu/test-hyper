
./bench.sh init

(docker run -it hyper:dhrystone ~/dhrystone-deb/dhry 100000000) | grep DMIPS


########################################

# Step 1: build docker image, create test pod
./bench.sh init

# Setp 2: see help
./bench.sh

# Step 3: auto test, output is log/cpu.log
sudo ./bat.sh


# Step 4: generate result
./report.sh

# Step 5: view report with markdown
