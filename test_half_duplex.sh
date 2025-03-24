#!/bin/bash

PORT=5203
OUTPUT_DIR="output"
CSV_REPORT="$OUTPUT_DIR/performance_report.csv"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Initialize CSV report with headers
initialize_csv_report() {
  echo "Test Number;Source;Min (Mbps);Max (Mbps);Average (Mbps);Standard Deviation (Mbps);Timestamp" >"$CSV_REPORT"
  echo "CSV report initialized at $CSV_REPORT" | prefix_system_output
}

# Function to display help
display_help() {
  echo "Usage: $0 [OPTION]"
  echo "Options:"
  echo "  1   Push and run the android_script.sh"
  echo "  2   Run another thing"
  echo "  -c  Clear all output files"
  echo "  -h  Display this help message"
  echo "  -r  Generate summary report from existing CSV data"
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

# Function to extract statistics from iperf3 output and append to CSV
extract_statistics() {
  local input_file=$1
  local source=$2
  local test_number=$3

  # Create temporary file for data
  local temp_file=$(mktemp)

  # Updated pattern to match the bitrate values
  grep -o "[0-9]\+ Mbits/sec" "$input_file" | grep -o "[0-9]\+" >"$temp_file"

  # Calculate statistics with awk and output to CSV
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
                    printf "%.2f;%.2f;%.2f;%.2f", min, max, avg, std;
                } else {
                    print "0;0;0;0";
                }
            }' "$temp_file")

    # Get current timestamp
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Append to CSV report - FIX: Properly quoting the test_number variable
    echo "${test_number};${source};${stats};${timestamp}" >>"$CSV_REPORT"

    # Display to console - split the stats for better display
    local min=$(echo "$stats" | cut -d';' -f1)
    local max=$(echo "$stats" | cut -d';' -f2)
    local avg=$(echo "$stats" | cut -d';' -f3)
    local std=$(echo "$stats" | cut -d';' -f4)

    echo -e "\n${source} Statistics: Min: ${min}, Max: ${max}, Avg: ${avg}, Std: ${std}" | prefix_system_output
  else
    echo -e "\n${source} Statistics: No data found" | prefix_system_output
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "${test_number};${source};0;0;0;0;${timestamp}" >>"$CSV_REPORT"
  fi

  # Clean up
  rm -f "$temp_file"
}

# Function to generate a summary report from the CSV data
generate_summary_report() {
  if [ ! -f "$CSV_REPORT" ]; then
    echo "CSV report not found. Run tests first." | prefix_system_output
    return
  fi

  echo "Generating summary report..." | prefix_system_output

  # Create summary report
  local summary_file="$OUTPUT_DIR/summary_report.txt"

  {
    echo "===== PERFORMANCE TEST SUMMARY ====="
    echo "Date: $(date)"
    echo "----------------------------------------"

    # Process Client data
    echo "CLIENT SIDE PERFORMANCE:"
    awk -F, '$2=="Client" {
            count++;
            min_sum += $3; max_sum += $4; avg_sum += $5; std_sum += $6;
            if (min_min == "" || $3 < min_min) min_min = $3;
            if (max_max == "" || $4 > max_max) max_max = $4;
        } END {
            if (count > 0) {
                printf "Tests: %d\n", count;
                printf "Min Throughput: %.2f Mbps\n", min_min;
                printf "Max Throughput: %.2f Mbps\n", max_max;
                printf "Average Throughput: %.2f Mbps\n", avg_sum/count;
                printf "Avg Std Deviation: %.2f Mbps\n", std_sum/count;
            } else {
                print "No client data found";
            }
        }' "$CSV_REPORT"

    echo "----------------------------------------"

    # Process Server data
    echo "SERVER SIDE PERFORMANCE:"
    awk -F, '$2=="Server" {
            count++;
            min_sum += $3; max_sum += $4; avg_sum += $5; std_sum += $6;
            if (min_min == "" || $3 < min_min) min_min = $3;
            if (max_max == "" || $4 > max_max) max_max = $4;
        } END {
            if (count > 0) {
                printf "Tests: %d\n", count;
                printf "Min Throughput: %.2f Mbps\n", min_min;
                printf "Max Throughput: %.2f Mbps\n", max_max;
                printf "Average Throughput: %.2f Mbps\n", avg_sum/count;
                printf "Avg Std Deviation: %.2f Mbps\n", std_sum/count;
            } else {
                print "No server data found";
            }
        }' "$CSV_REPORT"

    echo "----------------------------------------"
    echo "Full data available in: $CSV_REPORT"
  } >"$summary_file"

  # Display the summary
  cat "$summary_file" | prefix_system_output
  echo "Summary report saved to $summary_file" | prefix_system_output
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
  local test_number=$1

  # Clear previous output files for this test
  rm -f "$OUTPUT_DIR/android_output_$test_number.txt"
  rm -f "$OUTPUT_DIR/host_output_$test_number.txt"

  # Push script to Android
  adb push android_script.sh /storage/emulated/0/script

  echo "Starting iperf3 on Android (Test #$test_number)..." | prefix_system_output

  # Start the Android iperf3 server process in background and save output
  adb shell "sh /storage/emulated/0/script/android_script.sh $PORT" >"$OUTPUT_DIR/android_output_$test_number.txt" &

  # Start a background process to read and prefix the Android output
  tail -f "$OUTPUT_DIR/android_output_$test_number.txt" | prefix_android_output &
  tail_pid=$!

  # Ensure tail process is terminated when script exits
  trap "kill $tail_pid 2>/dev/null" EXIT

  echo "Starting client..." | prefix_system_output
  sleep 3 # Give the server time to initialize

  echo "Wait 10 seconds..." | prefix_system_output
  # Run the client and save output
  iperf3 -c 192.168.1.16 -p $PORT | tee "$OUTPUT_DIR/host_output_$test_number.txt" | prefix_host_output

  echo "Test #$test_number completed" | prefix_system_output
  # Give tail time to catch up with final output before potentially exiting
  sleep 2

  # Kill the tail process for this iteration
  kill $tail_pid 2>/dev/null

  # Extract statistics
  # extract_statistics "$OUTPUT_DIR/host_output_$test_number.txt" "Client" "$test_number"
  extract_statistics "$OUTPUT_DIR/android_output_$test_number.txt" "Android Tab S7 Plus" "$test_number"
}

host_server() {
  local test_number=$1
  local HOST_IP=$(hostname -I | awk '{print $1}')

  # Clear previous output files for this test
  rm -f "$OUTPUT_DIR/android_output_$test_number.txt"
  rm -f "$OUTPUT_DIR/host_output_$test_number.txt"

  # Start iperf3 server on host
  echo "Starting iperf3 server on host (Test #$test_number)..." | prefix_system_output
  iperf3 -s -p $PORT -1 | tee "$OUTPUT_DIR/host_output_$test_number.txt" | prefix_host_output &
  server_pid=$!

  # Ensure server process is terminated when script exits
  trap "kill $server_pid 2>/dev/null" EXIT

  # Give the server time to initialize
  echo "Waiting for server to initialize..." | prefix_system_output
  sleep 3

  # Push client script to Android
  echo "Pushing client script to Android..." | prefix_system_output
  adb push android_client.sh /storage/emulated/0/script

  echo "Starting iperf3 client on Android (Test #$test_number)..." | prefix_system_output

  # Start the Android iperf3 client process and save output
  adb shell "sh /storage/emulated/0/script/android_client.sh $PORT $HOST_IP" >"$OUTPUT_DIR/android_output_$test_number.txt"

  # Start a background process to read and prefix the Android output
  tail -f "$OUTPUT_DIR/android_output_$test_number.txt" | prefix_android_output &
  tail_pid=$!

  # Ensure tail process is terminated when script exits
  trap "kill $tail_pid 2>/dev/null; kill $server_pid 2>/dev/null" EXIT

  echo "Test running..." | prefix_system_output
  

  echo "Test #$test_number completed" | prefix_system_output
  
  # Give tail time to catch up with final output before potentially exiting
  sleep 2

  # Kill the processes for this iteration
  kill $tail_pid 2>/dev/null
  kill $server_pid 2>/dev/null

  # Extract statistics
  extract_statistics "$OUTPUT_DIR/host_output_$test_number.txt" "21KH ThinkBook 16 G6 IRL" "$test_number"
  # Uncomment if you need Android statistics too
  # extract_statistics "$OUTPUT_DIR/android_output_$test_number.txt" "Android Tab S7 Plus" "$test_number"
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

  # Initialize CSV report
  initialize_csv_report

  for i in $(seq $times); do
    echo "Running test $i of $times..." | prefix_system_output
    android_server "$i"
    sleep 2
  done

  # Generate summary after all tests
  generate_summary_report

  echo "All tests completed. CSV report available at $CSV_REPORT" | prefix_system_output
  ;;
2)
  times=${2:-10}
  time_required=$((times * 10))
  echo "Starting $times tests this gonna take approximately $time_required seconds" | prefix_system_output

  # For the CSV report
  initialize_csv_report

  for i in $(seq $times); do
    echo "Running test $i of $times..." | prefix_system_output
    host_server "$i"
    sleep 2
  done


  
  ;;
-h | --help)
  display_help
  ;;
-c)
  clear_output
  ;;
-r)
  generate_summary_report
  ;;
*)
  echo "Invalid option: $1"
  display_help
  exit 1
  ;;
esac
