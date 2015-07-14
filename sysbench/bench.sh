#!/bin/bash

#######################################
# Env
#######################################
BASE_DIR=$(cd "$(dirname "$0")"; pwd)
JQ=${BASE_DIR}/../../util/jq
SYSBENCH=$(which sysbench)

USE_HYPER_RUN="true"

DRY_RUN="false"

AUTO_RUN="false"
DFT_CPU_NUM="1"
DFT_MEMORY_SIZE="1024"
DFT_MAX_REQUESTS="10000"

EXEC_MODE="live"
#EXEC_MODE="dev"

#######################################
# Parameter
#######################################

TOTAL_MEMSIZE=$(cat /proc/meminfo | grep MemTotal | awk '{printf "%0.f", $2/1024}')
TOTAL_CPUNUM=$(cat /proc/cpuinfo | grep processor | wc -l)

if [ ${TOTAL_CPUNUM} -gt 1 ];then
  DFT_CPU_NUM="2"
fi

#cpu/memory resource for docker & hyper
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
MEMORY_SIZE=$((TOTAL_MEMSIZE/2))  #(MiB)
MAX_REQUESTS="10000"

#docker image and pod
DOCKER_IMAGE="hyper:sysbench"
POD_FILENAME="hyper-sysbench"
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
    #--max-requests(10000*), --percentile(95*), --num-threads(1*), --cpu-max-prime
    SYS_CPU_CASE=( "${MAX_REQUESTS} 95 1 50000"  "${MAX_REQUESTS} 95 ${CPU_NUM} 50000" )

    #--max-requests(10000*), --percentile(95*), --num-threads(1*), --memory-scope(global*|local), --memory-total-size(100G*) --memory-block-size(1K*)
    SYS_MEM_CASE=( "${MAX_REQUESTS} 95 1 global 100G 512"  "${MAX_REQUESTS} 95 ${CPU_NUM} global 400G 64K" )

    #--max-requests(10000*), --percentile(95*), --num-threads(1*), --file-total-size(1G), --file-block-size(16384*), --file-num(128*)
    SYS_IO_CASE=( "${MAX_REQUESTS} 95 1 2G $((512*1)) 5"  "${MAX_REQUESTS} 95 ${CPU_NUM} 2G $((64*1024)) 5" )
  else
    #test case for dev(fast test)
    #--max-requests(10000*), --percentile(95*), --num-threads(1*), --cpu-max-prime
    SYS_CPU_CASE=( "${MAX_REQUESTS} 95 1 5000"  "${MAX_REQUESTS} 95 ${CPU_NUM} 5000" )

    #--max-requests(10000*), --percentile(95*), --num-threads(1*), --memory-scope(global*|local), --memory-total-size(100G*), --memory-block-size(1K*)
    SYS_MEM_CASE=( "${MAX_REQUESTS} 95 1 global 1G 1M"  "${MAX_REQUESTS} 95 ${CPU_NUM} global 1G 1M" )

    #--max-requests(10000*), --percentile(95*), --num-threads(1*), --file-total-size(2G), --file-block-size(16384*), --file-num(128*)
    SYS_IO_CASE=( "${MAX_REQUESTS} 95 1 4M $((16*1024)) 2"  "${MAX_REQUESTS} 95 ${CPU_NUM} 4M $((16*1024)) 2" )
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

  echo "--------- cpu test parameter----------"
  echo -e "| No. | max-requests | percentile | num-threads | cpu-max-prime |"
  echo -n "${WHITE}"
  echo -e "| 1 | ${SYS_CPU_CASE[0]// / | } |"
  echo -e "| 2 | ${SYS_CPU_CASE[1]// / | } |"
  echo "${CYAN}"

  echo "-------- memory test parameter---------"
  echo -e "| No. | max-requests | percentile | num-threads | memory-scope | memory-total-size | memory-block-size |"
  echo -n "${WHITE}"
  echo -e "| 1 | ${SYS_MEM_CASE[0]// / | } |"
  echo -e "| 2 | ${SYS_MEM_CASE[1]// / | } |"
  echo "${CYAN}"

  echo "---------- io test parameter-----------"
  echo -e "| No. | max-requests | percentile | num-threads | file-total-size | file-block-size | file-num |"
  echo -n "${WHITE}"
  echo -e "| 1 | ${SYS_IO_CASE[0]// / | } |"
  echo -e "| 2 | ${SYS_IO_CASE[1]// / | } |"
  echo "${CYAN}"

  #check parameter
  if [ -z "${CPU_NUM}" -o -z "${MEMORY_SIZE}" -o -z "${MAX_REQUESTS}" -o -z "${DOCKER_IMAGE}" -o -z "${CPU_SET}" ];then
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

function install_sysbench() {
  type sysbench > /dev/null 2>&1
  if [ $? -ne 0 ];then
    title "Installing sysbench in host os"
    #apt-get install -y sysbench
    sudo apt-get -y install bzr make automake libc-dev  libtool
    bzr branch lp:~sysbench-developers/sysbench/0.5 ~/sysbench-0.5
    cd ~/sysbench-0.5
    ./autogen.sh
    ./configure --without-mysql
    make
    sudo make install
    cd ${BASE_DIR}
  else
    echo "sysbench already installed"
    sysbench --version
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

function input_max_requests() {

  SET_REQUEST_DONE="false"
  until [[ "${SET_REQUEST_DONE}" == "true" ]];do
    if [ "${AUTO_RUN}" == "true" ];then
      CHOICE=${DFT_MAX_REQUESTS}
    else
      echo -e -n "\n${BOLD}${PURPLE}Please input the ${WHITE}max number${PURPLE} of requests${RESET}(MB)(>=1000,press 'Enter' for ${MAX_REQUESTS}):"
      read CHOICE
    fi
    if [ ! -z ${CHOICE} ];then
      if [[ $CHOICE =~ ^[[:digit:]]+$ ]] && [[ ${CHOICE} -ge 1000 ]];then
        MAX_REQUESTS=${CHOICE}
        SET_REQUEST_DONE="true"
      else
        echo "${CHOICE} is an invalid number, please input a valid memory size!"
      fi
    else
      SET_REQUEST_DONE="true"
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
  input_max_requests

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
  if (echo "${TEST_ITEM[@]}" | grep -w "cpu" &>/dev/null);then
    do_cpu_test "${TEST_TARGET}"
  fi
  if (echo "${TEST_ITEM[@]}" | grep -w "mem" &>/dev/null);then
    do_memory_test "${TEST_TARGET}"
  fi
  if (echo "${TEST_ITEM[@]}" | grep -w "io" &>/dev/null);then
    do_io_test "${TEST_TARGET}"
  fi
  TEST_END_TS=$( date +"%s" )
  TEST_END_TIME=$( date +"%F %T" )
  echo
  echo "Test Start: ${TEST_START_TIME}"
  echo "Test End  : ${TEST_END_TIME}"
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

function cputest_cmd() {
  echo "${SYSBENCH} --test=cpu --max-requests=$1 --percentile=$2 --num-threads=$3 --cpu-max-prime=$4 run"
}

function do_cpu_test() {
  TEST_TARGET=("$1")
  PARAM_NUM=4 # max-requests | percentile | num-threads | cpu-max-prime
  title "${LIGHT}${GREEN}Execute CPU Test in [ $1 ] ${RESET}"
  for (( i = 0 ; i < ${#SYS_CPU_CASE[@]} ; i++ ))
  do
    #get test parameter
    test_case=${SYS_CPU_CASE[$i]}
    TEST_PARAM=(${test_case})
    if [ ${#TEST_PARAM[@]} -ne ${PARAM_NUM} ];then
      echo "Parameter number should be ${PARAM_NUM}, but current is ${#TEST_PARAM[@]}"
      echo "current parameter: ${test_case}"
      exit 1
    fi
    _MAX_REQUESTS=${TEST_PARAM[0]}
    _PERCENTILE=${TEST_PARAM[1]}
    _NUM_THREADS=${TEST_PARAM[2]}
    _CPU_MAX_PRIME=${TEST_PARAM[3]}

    TEST_CMD="$(cputest_cmd ${_MAX_REQUESTS} ${_PERCENTILE} ${_NUM_THREADS} ${_CPU_MAX_PRIME})"

    #start test cpu in host
    if (echo "${TEST_TARGET[@]}" | grep -w "host" &>/dev/null);then
      echo "${WHITE}"
      TESTCOUNT=$((TESTCOUNT+1))
      title "${TESTCOUNT}. CPU Performance Test - host "
      echo "test_case: ${test_case// /-}"
      show_test_cmd  " [ bash -c \"${TEST_CMD}\" ]${WHITE}"
      if [ "${DRY_RUN}" != "true" ];then
        bash -c "${TEST_CMD}"
      fi
      show_test_duration "host - cpu" "${test_case}" "${test_case}"
    fi

    #start test cpu in docker
    if (echo "${TEST_TARGET[@]}" | grep -w "docker" &>/dev/null);then
      echo "${GREEN}"
      TESTCOUNT=$((TESTCOUNT+1))
      title "${TESTCOUNT}. CPU Performance Test - docker"
      echo "test_case: ${test_case// /-}"
      show_test_cmd  " [ docker run -t --memory=${MEMORY_SIZE}m --cpuset-cpus=${CPU_SET// /,} ${DOCKER_IMAGE} ${TEST_CMD} ]${WHITE}"
      if [ "${DRY_RUN}" != "true" ];then
        docker run -t --memory=${MEMORY_SIZE}m --cpuset-cpus=${CPU_SET// /,} ${DOCKER_IMAGE} ${TEST_CMD}
      fi
      show_test_duration "docker - cpu" "${test_case}"
    fi

    #start test cpu inhyper
    if (echo "${TEST_TARGET[@]}" | grep -w "hyper" &>/dev/null);then
      echo "${BLUE}"
      TESTCOUNT=$((TESTCOUNT+1))
      title "${TESTCOUNT}. CPU Performance Test - hyper"
      echo "test_case: ${test_case// /-}"
      if [ ${USE_HYPER_RUN} == "true" ];then
        show_test_cmd  " [ sudo hyper run --cpu=${CPU_NUM} --memory=${MEMORY_SIZE} ${DOCKER_IMAGE} ${TEST_CMD} ]${WHITE}"
        if [ "${DRY_RUN}" != "true" ];then
          sudo hyper run --cpu=${CPU_NUM} --memory=${MEMORY_SIZE} ${DOCKER_IMAGE} ${TEST_CMD}
        fi
      else
        CONTAINER_ID=$(hyper_get_container_id)
        if [ "${CONTAINER_ID}" == " " ];then
          echo "hyper container not exist, exit!" && exit 1
        fi
        show_test_cmd  " [ sudo hyper exec ${CONTAINER_ID} ${TEST_CMD} ]${WHITE}"
        if [ "${DRY_RUN}" != "true" ];then
          sudo hyper exec ${CONTAINER_ID} ${TEST_CMD}
        fi
      fi
      show_test_duration "hyper - cpu" "${test_case}"
    fi
    echo "${RESET}"
  done
}


function memtest_cmd() {
  #echo "${SYSBENCH} --test=memory --num-threads=$3 --memory-block-size=512K --memory-total-size=100G run"
  echo "${SYSBENCH} --test=memory --max-requests=$1 --percentile=$2 --num-threads=$3 --memory-scope=$4 --memory-total-size=$5 --memory-block-size=$6 --memory-oper=$7 --memory-access-mode=$8 run"
}

function do_memory_test() {
  TEST_TARGET=("$1")

  PARAM_NUM=6 # max-requests | percentile | num-threads | memory-scope | memory-total-size | memory-block-size
  title "${LIGHT}${GREEN}Execute Memory Test in [ $1 ] ${RESET}"
  for (( i = 0 ; i < ${#SYS_MEM_CASE[@]} ; i++ ))
  do
    #get test parameter
    test_case=${SYS_MEM_CASE[$i]}
    TEST_PARAM=(${test_case})
    if [ ${#TEST_PARAM[@]} -ne ${PARAM_NUM} ];then
      echo "Parameter number should be ${PARAM_NUM}, but current is ${#TEST_PARAM[@]}"
      echo "current parameter: ${test_case}"
      exit 1
    fi
    _MAX_REQUESTS=${TEST_PARAM[0]}
    _PERCENTILE=${TEST_PARAM[1]}
    _NUM_THREADS=${TEST_PARAM[2]}
    _MEM_SCOPE=${TEST_PARAM[3]}
    _MEM_TOTAL_SIZE=${TEST_PARAM[4]}
    _MEM_BLOCK_SIZE=${TEST_PARAM[5]}

    for oper in read write
    do
      for mode in seq rnd
      do

        TEST_CMD="$(memtest_cmd ${_MAX_REQUESTS} ${_PERCENTILE} ${_NUM_THREADS} ${_MEM_SCOPE} ${_MEM_TOTAL_SIZE} ${_MEM_BLOCK_SIZE} ${oper} ${mode} )"

        #start test cpu in host
        if (echo "${TEST_TARGET[@]}" | grep -w "host" &>/dev/null);then
          echo "${WHITE}"
          TESTCOUNT=$((TESTCOUNT+1))
          title "${TESTCOUNT}. Memory Test - $mode $oper - host"
          echo "test_case: ${test_case// /-}"
          show_test_cmd  " [ bash -c \"${TEST_CMD}\" ]${WHITE}"
          if [ "${DRY_RUN}" != "true" ];then
            bash -c "${TEST_CMD}"
          fi
          show_test_duration "host - mem - ${mode} ${oper}" "${test_case}"
        fi

        #start test cpu in docker
        if (echo "${TEST_TARGET[@]}" | grep -w "docker" &>/dev/null);then
          echo "${GREEN}"
          TESTCOUNT=$((TESTCOUNT+1))
          title "${TESTCOUNT}. Memory Test - $mode $oper - docker"
          echo "test_case: ${test_case// /-}"
          show_test_cmd  " [ docker run -t --memory=${MEMORY_SIZE}m --cpuset-cpus=${CPU_SET// /,} ${DOCKER_IMAGE} ${TEST_CMD} ]${WHITE}"
          if [ "${DRY_RUN}" != "true" ];then
            docker run -t --memory=${MEMORY_SIZE}m --cpuset-cpus=${CPU_SET// /,} ${DOCKER_IMAGE} ${TEST_CMD}
          fi
          show_test_duration "docker - mem - ${mode} ${oper}" "${test_case}"
        fi

        #start test cpu in hyper
        if (echo "${TEST_TARGET[@]}" | grep -w "hyper" &>/dev/null);then
          echo "${BLUE}"
          TESTCOUNT=$((TESTCOUNT+1))
          title "${TESTCOUNT}. Memory Test - $mode $oper - hyper"
          echo "test_case: ${test_case// /-}"
          if [ ${USE_HYPER_RUN} == "true" ];then
            show_test_cmd  " [ sudo hyper run --cpu=${CPU_NUM} --memory=${MEMORY_SIZE} ${DOCKER_IMAGE} ${TEST_CMD} ]${BLUE}"
            if [ "${DRY_RUN}" != "true" ];then
              sudo hyper run --cpu=${CPU_NUM} --memory=${MEMORY_SIZE} ${DOCKER_IMAGE} ${TEST_CMD}
            fi
          else
            CONTAINER_ID=$(hyper_get_container_id)
            if [ "${CONTAINER_ID}" == " " ];then
              echo "hyper container not exist, exit!" && exit 1
            fi
            show_test_cmd  " [ sudo hyper exec ${CONTAINER_ID} ${TEST_CMD} ]${BLUE}"
            if [ "${DRY_RUN}" != "true" ];then
              sudo hyper exec ${CONTAINER_ID} ${TEST_CMD}
            fi
          fi
          show_test_duration "hyper - mem - ${mode} ${oper}" "${test_case}"
        fi
        echo "${RESET}"
      done
    done
  done
}

function iotest_cmd() {
  echo "${SYSBENCH} --test=fileio --file-total-size=$4 --file-num=$6 --file-extra-flags=direct --file-fsync-freq=200 prepare >/dev/null 2>&1 && \
  ${SYSBENCH} --test=fileio --max-requests=$1 --percentile=$2 --num-threads=$3 --file-total-size=$4 --file-block-size=$5 --file-num=$6 --file-test-mode=$7 --file-extra-flags=direct --file-fsync-freq=200 run; \
  ${SYSBENCH} --test=fileio --file-total-size=$4 cleanup"
}

function do_io_test() {
  TEST_TARGET=("$1")

  PARAM_NUM=6 # max-requests | percentile | num-threads | file-total-size | file-block-size | file-num
  title "${LIGHT}${GREEN}Execute IO Test in [ $1 ] ${RESET}"
  for (( i = 0 ; i < ${#SYS_IO_CASE[@]} ; i++ ))
  do
    #get test parameter
    test_case=${SYS_IO_CASE[$i]}
    TEST_PARAM=(${test_case})
    if [ ${#TEST_PARAM[@]} -ne ${PARAM_NUM} ];then
      echo "Parameter number should be ${PARAM_NUM}, but current is ${#TEST_PARAM[@]}"
      echo "current parameter: ${test_case}"
      exit 1
    fi
    _MAX_REQUESTS=${TEST_PARAM[0]}
    _MAX_REQUESTS=$((_MAX_REQUESTS))
    _PERCENTILE=${TEST_PARAM[1]}
    _NUM_THREADS=${TEST_PARAM[2]}
    _FILE_TOTAL_SIZE=${TEST_PARAM[3]}
    _FILE_BLOCK_SIZE=${TEST_PARAM[4]}
    _FILE_NUM=${TEST_PARAM[5]}

    for test_mode in seqwr seqrd rndwr rndrd # rndrw seqrewr
    do
      TEST_CMD="$(iotest_cmd ${_MAX_REQUESTS} ${_PERCENTILE} ${_NUM_THREADS} ${_FILE_TOTAL_SIZE} ${_FILE_BLOCK_SIZE} ${_FILE_NUM} ${test_mode})"

      #start test cpu in host
      if (echo "${TEST_TARGET[@]}" | grep -w "host" &>/dev/null);then
        echo "${WHITE}"
        TESTCOUNT=$((TESTCOUNT+1))
        title "${TESTCOUNT}. IO Test - ${test_mode} - host"
        echo "test_case: ${test_case// /-}"
        show_test_cmd  " [ bash -c \"${TEST_CMD}\" ]${WHITE}"
        if [ "${DRY_RUN}" != "true" ];then
          bash -c "${TEST_CMD}"
        fi
        show_test_duration "host - io - ${test_mode}" "${test_case}"
      fi

      #start test cpu in docker
      if (echo "${TEST_TARGET[@]}" | grep -w "docker" &>/dev/null);then
        echo "${GREEN}"
        TESTCOUNT=$((TESTCOUNT+1))
        title "${TESTCOUNT}. IO Test - ${test_mode} - docker"
        echo "test_case: ${test_case// /-}"
        show_test_cmd  " [ docker run -t --memory=${MEMORY_SIZE}m --cpuset-cpus=${CPU_SET// /,} ${DOCKER_IMAGE} bash -c \"${TEST_CMD}\" ]${GREEN}"
        if [ "${DRY_RUN}" != "true" ];then
          docker run -t --memory=${MEMORY_SIZE}m --cpuset-cpus=${CPU_SET// /,} ${DOCKER_IMAGE} bash -c "${TEST_CMD}"
        fi
        show_test_duration "docker - io - ${test_mode}" "${test_case}"
      fi

      #start test cpu in hyper
      if (echo "${TEST_TARGET[@]}" | grep -w "hyper" &>/dev/null);then
        echo "${BLUE}"
        TESTCOUNT=$((TESTCOUNT+1))
        title "${TESTCOUNT}. IO Test - ${test_mode} - hyper"
        echo "test_case: ${test_case// /-}"
        if [ ${USE_HYPER_RUN} == "true" ];then
          show_test_cmd  " [ sudo hyper run --cpu=${CPU_NUM} --memory=${MEMORY_SIZE} ${DOCKER_IMAGE} /bin/bash -c \"/root/test/io.sh ${_MAX_REQUESTS} ${_PERCENTILE} ${_NUM_THREADS} ${_FILE_TOTAL_SIZE} ${_FILE_BLOCK_SIZE} ${_FILE_NUM} ${test_mode}\" ]${BLUE}"
          if [ "${DRY_RUN}" != "true" ];then
            sudo hyper run --cpu=${CPU_NUM} --memory=${MEMORY_SIZE} ${DOCKER_IMAGE} /bin/bash -c "/root/test/io.sh ${_MAX_REQUESTS} ${_PERCENTILE} ${_NUM_THREADS} ${_FILE_TOTAL_SIZE} ${_FILE_BLOCK_SIZE} ${_FILE_NUM} ${test_mode}"
          fi
        else
          CONTAINER_ID=$(hyper_get_container_id)
          echo "CONTAINER_ID:[$CONTAINER_ID]"
          if [ "${CONTAINER_ID}" == " " ];then
            echo "hyper container not exist, exit!" && exit 1
          fi
          show_test_cmd  " [ sudo hyper exec ${CONTAINER_ID} /bin/bash -c \"/root/test/io.sh ${_MAX_REQUESTS} ${_PERCENTILE} ${_NUM_THREADS} ${_FILE_TOTAL_SIZE} ${_FILE_BLOCK_SIZE} ${_FILE_NUM} ${test_mode}\" ]${BLUE}"
          if [ "${DRY_RUN}" != "true" ];then
            sudo hyper exec ${CONTAINER_ID} /bin/bash -c "/root/test/io.sh ${_MAX_REQUESTS} ${_PERCENTILE} ${_NUM_THREADS} ${_FILE_TOTAL_SIZE} ${_FILE_BLOCK_SIZE} ${_FILE_NUM} ${test_mode}"
          fi
        fi
        show_test_duration "hyper - io - ${test_mode}" "${test_case}"
      fi
      echo "${RESET}"
    done
  done
}


function show_usage() {
  cat <<COMMENT

usage:
    ./bench.sh init   #build Dockerfile for hyper:sysbench
  or
    ./bench.sh clean  #clean old pod and container
  or
    ./bench.sh run   #start all test
  or
    ./bench.sh dry-run   #start all test
  or
    ./bench.sh auto-run   #start all test (noninteractive)
  or
    ./bench.sh run "host docker hyper" "cpu mem io"
  or
    ./bench.sh dry-run "host docker hyper" "cpu mem io"

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
    install_sysbench
  elif [ "$1" == "clean" ];then
    clean_pod
    echo -e "\n===============================================================================================\n"
    clean_docker
  elif [ "$1" == "run" ]; then
    echo "[ full test ]"
    start_test "host docker hyper" "cpu mem io"
  elif [ "$1" == "dry-run" ]; then
    echo "[ full dry-run test ]"
    DRY_RUN="true"
    start_test "host docker hyper" "cpu mem io"
  else
    show_usage
  fi
elif [ $# -eq 3 -a "$1" == "run" ]; then
  echo "[ specified test ]"
  start_test "$2" "$3"
elif [ $# -eq 3 -a "$1" == "dry-run" ]; then
  echo "[ specified dry test ]"
  DRY_RUN="true"
  start_test "$2" "$3"
elif [ $# -eq 3 -a "$1" == "auto-run" ]; then
  echo "[ specified auto test ]"
  AUTO_RUN="true"
  start_test "$2" "$3"
else

  show_usage
fi
