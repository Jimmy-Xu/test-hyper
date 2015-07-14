#!/bin/bash

#######################################
# Env
#######################################
BASE_DIR=$(cd "$(dirname "$0")"; pwd)
JQ=${BASE_DIR}/../../util/jq

#REMOTE_NETSERVER="52.8.138.39"    #hyper www

#Type 1
#REMOTE_NETSERVER="147.75.192.171" #hyper-test-jimmy2
#REMOTE_NETSERVER="10.100.0.203"    #hyper-test-jimmy2

#REMOTE_NETSERVER="147.75.192.149" #hyper-test-jimmy
#REMOTE_NETSERVER="10.100.0.207"   #hyper-test-jimmy

#Type 3
#REMOTE_NETSERVER="147.75.192.51" #hyper-perf-t3-2
REMOTE_NETSERVER="10.100.0.61"    #hyper-perf-t3-2

#REMOTE_NETSERVER="147.75.192.129" #hyper-perf-t3-1
#REMOTE_NETSERVER="10.100.0.151"   #hyper-perf-t3-1



USE_HYPER_RUN="true"
DRY_RUN="false"

AUTO_RUN="false"
DFT_CPU_NUM="1"
DFT_MEMORY_SIZE="1024"

EXEC_MODE="live"
#EXEC_MODE="dev"

#######################################
# Parameter
#######################################

TOTAL_MEMSIZE=$(cat /proc/meminfo | grep MemTotal | awk '{printf "%0.f", $2/1024}')
TOTAL_CPUNUM=$(cat /proc/cpuinfo | grep processor | wc -l)

# if [ ${TOTAL_CPUNUM} -gt 1 ];then
#   DFT_CPU_NUM="2"
# fi

#cpu/memory resource for docker & hyper
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
MEMORY_SIZE=$((TOTAL_MEMSIZE/2))  #(MiB)
MAX_REQUESTS="10000"

#docker image and pod
DOCKER_IMAGE="hyper:netperf"
POD_FILENAME="hyper-netperf"
POD_NAME=${POD_FILENAME}
POD_DIR="pod"

#######################################
# Constant
#######################################
#Color Constant
BLACK=`tput setaf 0`   #<reserved>
RED=`tput setaf 1`     #error
GREEN=`tput setaf 2`   #success
YELLOW=`tput setaf 3`  #warning
BLUE=`tput setaf 4`    #infomation
PURPLE=`tput setaf 5`  #exception
CYAN=`tput setaf 6`    #<reserved>
WHITE=`tput setaf 7`   #normal
LIGHT=`tput bold `     #light color
RESET=`tput sgr0`      #restore color setting

#######################################
# Function
#######################################
function generate_test_case() {
  #cpuset-cpus for docker
  CPU_SET=($(seq 0 $((CPU_NUM-1))))
  CPU_SET="${CPU_SET[@]}"

  if [ ${EXEC_MODE} == "live"  ];then
    #test case for live(normal test)
    TEST_NET_CASE=( TCP_STREAM TCP_RR TCP_CRR UDP_STREAM UDP_RR )
  else
    #test case for dev(fast test)
    TEST_NET_CASE=( TCP_STREAM TCP_RR TCP_CRR UDP_STREAM UDP_RR )
  fi
}

function title() {
  echo
  echo "────────────────────────────────────────────────────────"
  echo $@
  echo "────────────────────────────────────────────────────────"
}

function show_test_parameter() {
  echo "${CYAN}"
  title "List all test parameter"

  echo "----------- total resource -----------"
  echo " TOTAL_CPUNUM      : ${WHITE}${TOTAL_CPUNUM}${CYAN}"
  echo " TOTAL_MEMSIZE     : ${WHITE}${TOTAL_MEMSIZE}${CYAN} (MB)"
  echo

  echo "---------- resource to assign ----------"
  echo " CPU_NUM           : ${LIGHT}${YELLOW}${CPU_NUM}${RESET}${CYAN}"
  echo " MEMORY_SIZE       : ${LIGHT}${YELLOW}${MEMORY_SIZE}${RESET}${CYAN} (MB)"
  echo

  echo "------------ docke image -------------"
  echo " DOCKER_IMAGE      : ${WHITE}${DOCKER_IMAGE}${CYAN}"
  echo

  echo "-------- parameter for docker --------"
  echo " --cpuset-cpus=${YELLOW}${CPU_SET// /,}${CYAN}"
  echo " --memory=${YELLOW}${MEMORY_SIZE}m${CYAN}"
  echo

  #check parameter
  if [ -z "${CPU_NUM}" -o -z "${MEMORY_SIZE}" -o -z "${DOCKER_IMAGE}" -o -z "${CPU_SET}" ];then
    echo "Error, some parameter is empty, exit!"
    exit 1
  else
    echo
    if [ "${AUTO_RUN}" != "true" ];then
      pause
    fi
  fi
  echo "${RESET}"
}


function build_dockerfile() {
  title "Building Dockerfile for image ${DOCKER_IMAGE}"
  sudo docker build -t ${DOCKER_IMAGE} --no-cache=true --rm=true .
}

function install_netperf() {
   sudo apt-get install -y netperf
   which netperf > /dev/null 2>&1
   if [ $? -eq 0 ];then
    echo "Install netperf succeed"
   else
    echo "Install netperf failed"
    exit 1
   fi
}

function generate_pod() {
  title "Dynamic update vcpu in pod json"
  #set cpu
  cat "${POD_DIR}/${POD_FILENAME}.pod.tmpl" | ${JQ} ".resource.vcpu=${CPU_NUM}" > "${POD_DIR}/${POD_FILENAME}.tmp"
  cat "${POD_DIR}/${POD_FILENAME}.tmp" | ${JQ} ".resource.memory=${MEMORY_SIZE}" > "${POD_DIR}/${POD_FILENAME}.pod"
  \rm -rf "${POD_DIR}/${POD_FILENAME}.tmp"
  ls -l "${POD_DIR}/${POD_FILENAME}.pod" && cat "${POD_DIR}/${POD_FILENAME}.pod" | ${JQ} "."
  echo "generate pod done."
}

function run_pod() {
  title "Run test pod"
  CONTAINER_ID=$(hyper_get_container_id)
  if [ "${CONTAINER_ID}" == " " ];then
    echo "sudo hyper pod ${POD_DIR}/${POD_FILENAME}.pod"
    sudo hyper pod ${POD_DIR}/${POD_FILENAME}.pod
    if [ $? -ne 0 ];then
      echo "create pod failed,exit!"
      exit 1
    fi
    sleep 3
  else
    echo "${CONTAINER_ID} already running"
  fi
  echo "run pod done."
}

function hyper_get_container_id() {
  POD_NAME=$(cat "${POD_DIR}/${POD_FILENAME}.pod" | ${JQ} -r ".id" )
  if [ "${POD_NAME}" == "" ];then
    echo -n " "
  else
    POD_ID=$(sudo hyper list | grep "${POD_NAME}.*running" | awk '{print $1}' | head -n 1 )
    if [ "${POD_ID}" == "" ];then
      echo -n " "
    else
      CNTR_ID=$(sudo hyper list container | grep "${POD_ID}.*running" | awk '{print $1}')
      if [ "${CNTR_ID}" == "" ];then
        echo -n " "
      else
        echo -n "${CNTR_ID}"
      fi
    fi
  fi
}

function clean_pod() {
  title "Clean old pod with name ${POD_NAME}"

  OLD_RUNNING_POD=$(sudo hyper list | grep "${POD_NAME}.*running"|wc -l)
  echo "old running pod from ${DOCKER_IMAGE} : ${OLD_RUNNING_POD}"
  if [ ${OLD_RUNNING_POD} -gt 0 ];then
    echo -e "stop all runnign pod with name ${POD_NAME}"
    sudo hyper list | grep "${POD_NAME}.*running" | awk '{print $1}' | xargs -i sudo hyper stop {}
  fi

  OLD_PENDING_POD=$(sudo hyper list | grep "${POD_NAME}.*pending"|wc -l)
  echo "old pending pod from ${DOCKER_IMAGE} : ${OLD_PENDING_POD}"
  if [ ${OLD_PENDING_POD} -gt 0 ];then
    echo -e "rm all pending pod with name ${POD_NAME}"
    sudo hyper list | grep "${POD_NAME}.*pending" | awk '{print $1}' | xargs -i sudo hyper rm {}
  fi

  title "current pod (${POD_NAME})"
  sudo hyper list | sed -n '1p;/'${POD_NAME}'/p'
  echo -e "\nclean pod done!"
}

function clean_docker() {
  title "Clean old container and images from ${POD_NAME}"

  OLD_CONTAINER=$(docker ps -a | awk '{print $2,$1}' | grep "${DOCKER_IMAGE}" | wc -l)
  echo "old container from ${DOCKER_IMAGE} : ${OLD_CONTAINER}"
  if [ ${OLD_CONTAINER} -gt 0 ];then
    echo "remove old container"
    docker rm $(docker ps -a | awk '{print $2,$1}' | grep "${DOCKER_IMAGE}" | awk '{print $2}') > /dev/null 2>&1
  fi

  NONE_IMAGES=$(docker images | grep "<none>.*<none>" | wc -l)
  echo "<none> images : ${NONE_IMAGES}"
  if [ ${NONE_IMAGES} -gt 0 ];then
    echo "remove <none>:<none> docker images"
    sudo docker rmi $(docker images | grep "<none>.*<none>" | awk '{print $3}') > /dev/null 2>&1
  fi

  title "current docker images"
  docker images
  title "current docker container"
  docker ps -a | awk '{print $2,$1}' | grep "${DOCKER_IMAGE}"
  echo -e "\nclean docker done!"
}

function pause() {
  read -n 1 -p "${LEFT_PAD}${BLUE}Press any key to continue...${RESET}"
}

function input_cpu_number() {

  SET_CPU_DONE="false"
  until [[ "${SET_CPU_DONE}" == "true" ]];do
    if [ "${AUTO_RUN}" == "true" ];then
      CHOICE=${DFT_CPU_NUM}
    else
      echo -e -n "\n${BOLD}${PURPLE}Please input the ${WHITE}number${PURPLE} of vcpu${RESET}(>=1,press 'Enter' for 1):"
      read CHOICE
    fi
    if [ ! -z ${CHOICE} ];then
      if [[ $CHOICE =~ ^[[:digit:]]+$ ]] && [[ ${CHOICE} -ge 1 ]];then
        CPU_NUM=${CHOICE}
        SET_CPU_DONE="true"
      else
        echo "${CHOICE} is an invalid number, please input a valid cpu number!"
      fi
    else
      CPU_NUM=1
      SET_CPU_DONE="true"
    fi
  done
}

function input_memory_size() {

  SET_MEM_DONE="false"
  until [[ "${SET_MEM_DONE}" == "true" ]];do
    if [ "${AUTO_RUN}" == "true" ];then
      CHOICE=${DFT_MEMORY_SIZE}
    else
      echo -e -n "\n${BOLD}${PURPLE}Please input the ${WHITE}size${PURPLE} of memory${RESET}(MB)(>=28,press 'Enter' for ${MEMORY_SIZE}):"
      read CHOICE
    fi
    if [ ! -z ${CHOICE} ];then
      if [[ $CHOICE =~ ^[[:digit:]]+$ ]] && [[ ${CHOICE} -ge 28 ]];then
        MEMORY_SIZE=${CHOICE}
        SET_MEM_DONE="true"
      else
        echo "${CHOICE} is an invalid number, please input a valid memory size!"
      fi
    else
      SET_MEM_DONE="true"
    fi
  done
}


###########################################

function start_test() {
  TEST_TARGET=("$1")
  TEST_ITEM=("$2")
  echo "${LIGHT}${YELLOW}start test [${TEST_TARGET}] [${TEST_ITEM}]${RESET}"
  echo "${CYAN}"
  echo " TOTAL_CPUNUM      : ${WHITE}${TOTAL_CPUNUM}${CYAN}"
  echo " TOTAL_MEMSIZE     : ${WHITE}${TOTAL_MEMSIZE}${CYAN} (MB)"
  echo -n "${RESET}"

  #1 get cpu, memory and max_request
  input_cpu_number
  input_memory_size

  #2 prepare test parameter
  generate_test_case
  show_test_parameter

  #3 create hyper pod
  if (echo "${TEST_TARGET[@]}" | grep -w "hyper" &>/dev/null);then
    generate_pod
    if [ ${USE_HYPER_RUN} != "true" ];then #no need prepare running pod if user "hyper run"
      run_pod
    fi
  fi

  TESTCOUNT=0

  TEST_START_TS=$( date +"%s" )
  TEST_START_TIME=$( date +"%F %T" )
  #3 start test
  if (echo "${TEST_ITEM[@]}" | grep -w "network" &>/dev/null);then
    do_network_test "${TEST_TARGET}"
  fi
  TEST_END_TS=$( date +"%s" )
  TEST_END_TIME=$( date +"%F %T" )
  echo
  echo "Test Start: ${START_TIME}"
  echo "Test End  : ${END_TIME}"
  echo "Test Duration: $((TEST_END_TS - TEST_START_TS)) (sec)"
}


function show_test_cmd() {
  START_TS=$( date +"%s" )
  START_TIME=$( date +"%F %T" )
  echo "test command line: ${YELLOW}$1 "
}

function show_test_duration() {
  END_TS=$( date +"%s" )
  END_TIME=$( date +"%F %T" )
  TEST_NAME="$1"
  TEST_CASE="$2"
  echo "START_TIME: ${START_TIME}"
  echo "END_TIME : ${END_TIME}"
  echo -e "${LIGHT}${GREEN}test-duration : ${TEST_NAME} : ${TEST_CASE} : $((END_TS - START_TS)) (seconds)\n${RESET}"
}

function networktest_cmd() {
  case "${1}" in
    TCP_STREAM) echo "for i in \$(seq 1 3); do netperf -l 20 -H ${REMOTE_NETSERVER} -t $1 -f K -- -m 2048; done" ;;
    UDP_STREAM) echo "for i in \$(seq 1 3); do netperf -l 20 -H ${REMOTE_NETSERVER} -t $1 -f K -- -m 2048 -R 1; done" ;;
    TCP_RR)     echo "for i in \$(seq 1 3); do netperf -l 20 -H ${REMOTE_NETSERVER} -t $1 -- -r 64,1024; done";;
    TCP_CRR)    echo "for i in \$(seq 1 3); do netperf -l 20 -H ${REMOTE_NETSERVER} -t $1 -- -r 64,1024; done";;
    UDP_RR)     echo "for i in \$(seq 1 3); do netperf -l 20 -H ${REMOTE_NETSERVER} -t $1 -- -r 64,1024; done";;
  esac
}

function do_network_test() {
  TEST_TARGET=("$1")
  PARAM_NUM=1
  title "${LIGHT}${GREEN}Execute Network Test in [ $1 ] ${RESET}"
  for (( i = 0 ; i < ${#TEST_NET_CASE[@]} ; i++ ))
  do
    #get test parameter
    test_case=${TEST_NET_CASE[$i]}
    TEST_PARAM=(${test_case})
    if [ ${#TEST_PARAM[@]} -ne ${PARAM_NUM} ];then
      echo "Parameter number should be ${PARAM_NUM}, but current is ${#TEST_PARAM[@]}"
      echo "current parameter: ${test_case}"
      exit 1
    fi
    _T=${TEST_PARAM[0]}
    TEST_CMD="$(networktest_cmd ${_T})"

    #start test mem in host
    if (echo "${TEST_TARGET[@]}" | grep -w "host" &>/dev/null);then
      echo "${WHITE}"
      TESTCOUNT=$((TESTCOUNT+1))
      title "${TESTCOUNT}. Network Performance Test - host "
      echo "test_case: ${test_case// /-}"
      show_test_cmd  " [ bash -c \"${TEST_CMD}\" ]${WHITE}"
      echo "DRY_RUN:${DRY_RUN}"
      if [ "${DRY_RUN}" != "true" ];then
        bash -c "${TEST_CMD}"
      fi
      show_test_duration "host - mem" "${test_case}" "${test_case}"
    fi

    #start test mem in docker
    if (echo "${TEST_TARGET[@]}" | grep -w "docker" &>/dev/null);then
      echo "${GREEN}"
      TESTCOUNT=$((TESTCOUNT+1))
      title "${TESTCOUNT}. Network Performance Test - docker"
      echo "test_case: ${test_case// /-}"
      show_test_cmd  " [ docker run -t --memory=${MEMORY_SIZE}m --cpuset-cpus=${CPU_SET// /,} ${DOCKER_IMAGE} bash -c \"${TEST_CMD}\" ]${WHITE}"
      if [ "${DRY_RUN}" != "true" ];then
        docker run -t --memory=${MEMORY_SIZE}m --cpuset-cpus=${CPU_SET// /,} ${DOCKER_IMAGE} bash -c "${TEST_CMD}"
      fi
      show_test_duration "docker - mem" "${test_case}"
    fi

    #start test mem in hyper
    if (echo "${TEST_TARGET[@]}" | grep -w "hyper" &>/dev/null);then
      echo "${BLUE}"
      TESTCOUNT=$((TESTCOUNT+1))
      title "${TESTCOUNT}. Network Performance Test - hyper"
      echo "test_case: ${test_case// /-}"
      if [ ${USE_HYPER_RUN} == "true" ];then
        show_test_cmd  " [ sudo hyper run --cpu=${CPU_NUM} --memory=${MEMORY_SIZE} ${DOCKER_IMAGE} bash -c \"${TEST_CMD}\" ]${WHITE}"
        if [ "${DRY_RUN}" != "true" ];then
          sudo hyper run --cpu=${CPU_NUM} --memory=${MEMORY_SIZE} ${DOCKER_IMAGE} bash -c "${TEST_CMD}"
        fi
      else
        CONTAINER_ID=$(hyper_get_container_id)
        if [ "${CONTAINER_ID}" == " " ];then
          echo "hyper container not exist, exit!" && exit 1
        fi
        show_test_cmd  " [ sudo hyper exec ${CONTAINER_ID} bash -c \"${TEST_CMD}\" ]${WHITE}"
        if [ "${DRY_RUN}" != "true" ];then
          sudo hyper exec ${CONTAINER_ID} bash -c "${TEST_CMD}"
        fi
      fi
      show_test_duration "hyper - mem" "${test_case}"
    fi
    echo "${RESET}"
  done

}

function show_usage() {
  cat <<COMMENT

usage:
    ./bench.sh init      #build Dockerfile for hyper:netperf
  or
    ./bench.sh clean     #clean old pod and container
  or
    ./bench.sh run       #start all test
  or
    ./bench.sh dry-run   #start all test
  or
    ./bench.sh auto-run  #start all test (noninteractive)
  or
    ./bench.sh run "host docker hyper"
  or
    ./bench.sh dry-run "host docker hyper"

COMMENT
  exit 1
}


######################################################################
# main
######################################################################
if [ $# -eq 1 ]; then
  if [ "$1" == "init" ];then
    echo "[ init ]"
    build_dockerfile
    install_netperf
  elif [ "$1" == "clean" ];then
    clean_pod
    echo -e "\n===============================================================================================\n"
    clean_docker
  elif [ "$1" == "run" ]; then
    echo "[ full test ]"
    start_test "host docker hyper" "network"
  elif [ "$1" == "dry-run" ]; then
    echo "[ full dry-run test ]"
    DRY_RUN="true"
    start_test "host docker hyper" "network"
  elif [ "$1" == "auto-run" ]; then
    echo "[ full auto-run test ]"
    DRY_RUN="false"
    AUTO_RUN="true"
    start_test "host docker hyper" "network"
  else
    show_usage
  fi
elif [ $# -eq 2 -a "$1" == "run" ]; then
  echo "[ specified test ]"
  start_test "$2" "network"
elif [ $# -eq 2 -a "$1" == "dry-run" ]; then
  echo "[ specified dry test ]"
  DRY_RUN="true"
  start_test "$2" "network"
elif [ $# -eq 2 -a "$1" == "auto-run" ]; then
  echo "[ specified auto test ]"
  AUTO_RUN="true"
  start_test "$2" "network"
else

  show_usage
fi
