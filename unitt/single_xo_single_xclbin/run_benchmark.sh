#!/bin/bash

handle_error() {
    echo "Error: Command failed with exit code $?"
    exit 1
}
trap 'handle_error' ERR

# Function to display usage information
usage() {
  echo "Usage: $0 -p /path/to/directory_or_file"
  echo "Options:"
  echo "  -p    Specify the path to the build folder (required)"
  echo "  -f    Specify the frequency of the FPGA in MHz (optional)"
  exit 1
}

# Initialize variables
BUILD_FOLDER=""
FREQUENCY=""

# Parse command-line options
while getopts ":p:f:" opt; do
  case $opt in
    p)
      BUILD_FOLDER=$OPTARG
      ;;
    f)
      FREQUENCY=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

# Check if the path argument is provided
if [ -z "$BUILD_FOLDER" ]; then
  echo "Error: Path to the build folder of the ubench to run is required."
  usage
fi
if [ -z "$FREQUENCY" ]; then
  echo "Error: Frequency of the application must be specified."
  usage
fi


echo ${BUILD_FOLDER}


SCRIPT=$(readlink -f "$0")
SCRIPT_DIR=$(dirname ${SCRIPT})


#BUILD_FOLDER=${SCRIPT_DIR}/.build_global_mem_bw/
TEMP_RESULTS_FILE=${SCRIPT_DIR}/.results_temp
RESULTS_FILE=${SCRIPT_DIR}/results.csv

XCLBIN=${BUILD_FOLDER}/FPGA/hw/global_mem_bw.xclbin
HOST_APP=${BUILD_FOLDER}/host/global_mem_bw_host



# Run the host app
${HOST_APP} ${XCLBIN} 2>&1 | tee ${TEMP_RESULTS_FILE}



# Get the data
PLATFORM=$(xclbinutil -i ${XCLBIN} --info | grep "Platform VBNV" | cut -d : -f 2 | tr -d " ")
THROUGHPUT=$(cat ${TEMP_RESULTS_FILE} | grep Throughput | cut -d = -f 2 | tr -d " " | cut -d "(" -f 1)


[ -f ${RESULTS_FILE} ] || echo "frequency,platform,throughput" > ${RESULTS_FILE}
echo ${FREQUENCY},${PLATFORM},${THROUGHPUT} >> ${RESULTS_FILE}

rm -f "${TEMP_RESULTS_FILE}"

