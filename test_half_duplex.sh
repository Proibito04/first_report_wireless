#!/bin/bash

PORT=5203
OUTPUT_DIR="output"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Function to display help
display_help() {
  echo "Usage: $0 [OPTION]"
  echo "Options:"
  echo "  1   Push and run the android_script.sh"
  echo "  2   Run another thing"
  echo "  -c  Clear all output files"
  echo "  -h  Display this help message"
}

# Function to add prefix to Android output with color
prefix_android_output() {
  local GREEN="\033[0;32m"
  local RESET="\033[0m"
  while IFS= read -r line; do
    echo -e "${GREEN}[Android]${RESET} $line"
    sleep 0
  done
}

prefix_host_output() {
  local GREEN="\033[0;35m"
  local RESET="\033[0m"
  while IFS= read -r line; do
    echo -e "${GREEN}[Host]${RESET} $line"
  done
}

prefix_system_output() {
  local GREEN="\033[1;36m"
  local RESET="\033[0m"
  while IFS= read -r line; do
    echo -e "${GREEN}[Message]${RESET} $line"
    sleep 0
  done
}

# Function to extract statistics from iperf3 output
extract_statistics() {
  local input_file=$1
  local source=$2
  # Create temporary file for data
  local temp_file=$(mktemp)

  # Updated pattern to match the bitrate values in the format shown in your output
  grep -o "[0-9]\+ Mbits/sec" "$input_file" | grep -o "[0-9]\+" >"$temp_file"

  # Calculate statistics with awk
  if [ -s "$temp_file" ]; then
    local stats=$(awk '
            BEGIN {
                min = 999999;
                max = 0;
                sum = 0;
                sumsq = 0;
                count = 0;
            }
            {
                if ($1 < min) min = $1;
                if ($1 > max) max = $1;
                sum += $1;
                sumsq += $1 * $1;
                count++;
            }
            END {
                if (count > 0) {
                    avg = sum / count;
                    if (count > 1) {
                        variance = (sumsq - (sum * sum) / count) / (count - 1);
                        std = sqrt(variance);
                    } else {
                        std = 0;
                    }
                    printf "Min: %.2f Mbps, Max: %.2f Mbps, Avg: %.2f Mbps, Std Dev: %.2f Mbps", min, max, avg, std;
                } else {
                    print "No data found";
                }
            }' "$temp_file")
    echo -e "\n${source} Statistics: $stats" | prefix_system_output
  else
    echo -e "\n${source} Statistics: No data found" | prefix_system_output
  fi
  # Clean up
  rm -f "$temp_file"
}

# Function to clear output files
clear_output() {
  echo "Clearing output files..." | prefix_system_output
  rm -rf "$OUTPUT_DIR"/*
  mkdir -p "$OUTPUT_DIR"
  echo "Output files cleared." | prefix_system_output
}

# android server
android_server() {
  # Clear previous output files for this test
  rm -f "$OUTPUT_DIR/android_output.txt"
  rm -f "$OUTPUT_DIR/host_output.txt"

  # Push script to Android
  adb push android_script.sh /storage/emulated/0/script

  echo "Starting iperf3 on Android..." | prefix_system_output

  # Start the Android iperf3 server process in background and save output
  adb shell "sh /storage/emulated/0/script/android_script.sh $PORT" >"$OUTPUT_DIR/android_output.txt" &

  # Start a background process to read and prefix the Android output
  tail -f "$OUTPUT_DIR/android_output.txt" | prefix_android_output &
  tail_pid=$!

  # Ensure tail process is terminated when script exits
  trap "kill $tail_pid 2>/dev/null" EXIT

  echo "Starting client..." | prefix_system_output
  sleep 3 # Give the server time to initialize

  echo "Wait 10 seconds..." | prefix_system_output
  # Run the client and save output
  iperf3 -c 192.168.1.16 -p 5203 | tee "$OUTPUT_DIR/host_output.txt" | prefix_host_output

  echo "Client completed" | prefix_system_output
  # Give tail time to catch up with final output before potentially exiting
  sleep 2

  # Kill the tail process for this iteration
  kill $tail_pid 2>/dev/null

  # Extract statistics
  extract_statistics "$OUTPUT_DIR/host_output.txt" "Client"
  extract_statistics "$OUTPUT_DIR/android_output.txt" "Server"
}

# Check for arguments
if [ $# -eq 0 ]; then
  display_help
  exit 1
fi

# Perform actions based on the argument
case $1 in
1)
  times=${2:-10}
  time_required=$((times * 10))
  echo "Starting $times tests this gonna take approximately $time_required seconds" | prefix_system_output
  for i in $(seq $times); do
    echo "Running test $i of $times..." | prefix_system_output
    android_server
    sleep 2
  done
  echo "All tests completed." | prefix_system_output
  ;;
2)
  # Add your custom command here for option 2
  echo "Running another thing..."
  ;;
-h | --help)
  display_help
  ;;
-c)
  clear_output
  ;;
*)
  echo "Invalid option: $1"
  display_help
  exit 1
  ;;
esac
