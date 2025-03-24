# Wi-Fi Performance Study Setup

## Device Specifications

### PC (Ethernet-Connected Device)

- **Model**: Lenovo ThinkBook 16 G6 IRL
- **Processor**: 13th Gen Intel® Core™ i7-13700H × 20
- **Memory**: 32.0 GB
- **Storage**: 512.1 GB
- **Graphics**: Intel® Graphics (RPL-P)
- **Operating System**: Ubuntu 24.04.2 LTS (64-bit)
- **Kernel Version**: Linux 6.11.0-19-generic
- **Network Connection**: Ethernet (1 Gbps)

### Tablet (Wi-Fi Device)

- **Model**: Samsung Galaxy Tab S7 Plus (SM-T970)
- **Processor**: Qualcomm Snapdragon 865+
- **Wi-Fi Capability**: Wi-Fi 6 (802.11ax)
- **Operating System**: Android
- **Network Connection**: Wi-Fi

## Network Infrastructure

- **Router Model**: IliadBox (R1)
- **Wi-Fi Standards**: 802.11ax/Wi-Fi 6
- **Frequency Bands**: Dual-band (2.4 GHz and 5 GHz)
- **Maximum Theoretical Speed**: 1 Gbps

## Testing Environment

- **Distance Between Devices**: 2 meters
- **Physical Barriers**: a chipboard compartment
- **Potential Interference Sources**: none
- **Testing Time**: 24/03/2025 16:00 - 17:00
- **Network Congestion**: Google Nest mini and some smart home devices

## Testing Methodology

### Tools Used for Measurement

1. **iperf3 on Linux (Ubuntu)** for data transfer testing on the PC.
2. **iperf3 on Termux (Android)** for data transfer testing on the Tab S7 Plus. [repo](https://github.com/davidBar-On/android-iperf3/)
3. **Router configuration interface** for monitoring real-time load and verifying connection speeds.

### Types of Tests Performed

**TCP Throughput Test**:

- Measure the effective transmission rate (goodput) and compare it to the theoretical maximum.
- Evaluate the impact of packet size, TCP options, and Wi-Fi configuration.

### Duration of Tests

Each test will be run for **10 seconds** per configuration
 
## Measuring the goodput

I started this mesurament by create a script that will run the iperf3 for 10 times to 10 times.

### Pre-requisites

On your Android device install iperf3 form the official repo.

### Running the script

Script Usage Instructions

To run the script: `./testhalfduplex.sh <mode> <n_test>`

Where:
- `<mode>` specifies the test configuration:
  - 1 = Android device acts as the receiver
  - 2 = Laptop acts as the receiver
- `<n_test>` is the number of tests to run (defaults to 10 if not specified)

Additional parameters:

- `-c` Clear all previous test results
- `-h` Display help information
- `-r` Generate summary report from existing CSV data without running new tests

The script creates an output folder containing detailed results of each test along with a CSV file that compiles all test metrics for easy analysis. Results include throughput measurements (minimum, maximum, average) and performance stability metrics (standard deviation).

Example commands:

- `./testhalfduplex.sh 1 5` - Run 5 tests with Android as receiver
- `./testhalfduplex.sh 2` - Run 10 tests with laptop as receiver
- `./testhalfduplex.sh -r`- Generate summary report from existing data

### Results

Goodput represents the actual useful data transferred per unit of time, excluding protocol overhead.

For **ThinkBook 16 G6 IRL**:
- Average throughput: 278.03 Mbps
- TCP/IP overhead (typically ~5-10%): ~13.90-27.80 Mbps
- Estimated goodput: ~250.23-264.13 Mbps

For **Tab S7 Plus**:
- Average throughput: ~628.62 Mbps
- TCP/IP overhead: ~31.43-62.86 Mbps
- Estimated goodput: ~565.76-597.19 Mbps

Key Observations
Performance Difference:

1. The Tab S7 Plus achieves approximately **2.26x higher throughput** than the ThinkBook when operating as a server. This significant difference suggests hardware capabilities or network configuration advantages
2. Stability Analysis:
ThinkBook shows relatively consistent performance (std dev range: 3.58-37.99)
Tab S7 Plus shows generally stable performance.
3. Performance Ranges:
ThinkBook: 167-382 Mbps (215 Mbps range)
Tab S7 Plus: 550-682 Mbps (132 Mbps range, excluding Test 8)


