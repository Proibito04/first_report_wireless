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
2. **iperf3 on Termux (Android)** for data transfer testing on the Tab S7 Plus.
3. **Router configuration interface** for monitoring real-time load and verifying connection speeds.

### Types of Tests Performed

- **TCP Throughput Test**:
    - Measure the effective transmission rate (goodput) and compare it to the theoretical maximum.
    - Evaluate the impact of packet size, TCP options, and Wi-Fi configuration.
- **UDP Throughput Test**:
    - Measure the data transmission rate when using User Datagram Protocol.
    - Assess packet loss and the reliability trade-offs compared to TCP.
- **Comparison Test**:
    - Compare the Ethernet-connected PC and Wi-Fi-connected tablet to observe efficiency differences.

### Duration of Tests

- Each test will be run for **60 seconds** per configuration:
    - Different Wi-Fi bands (2.4 GHz and 5 GHz).
    - Varying distances (close, medium, and maximum range).
    - Different levels of network congestion (light, normal, and heavy traffic).

### Metrics Being Measured

1. **Goodput (G)**:
    - Useful data throughput at the application layer.
    - Formula: $$ G = \dfrac{\text{Application Layer Data}}{\text{Time to Complete Transfer}}$$
2. **Efficiency ($η$)**:
    - Measure of protocol efficiency for TCP/UDP over Ethernet and Wi-Fi.
    - Example values:
        - ηTCP=0.949ηTCP​=0.949 (Ethernet)
        - ηUDP=0.957ηUDP​=0.957 (Ethernet)
        - ηTCP over Wi-Fi<0.5ηTCP over Wi-Fi​<0.5
        - ηUDP over Wi-Fi<0.55ηUDP over Wi-Fi​<0.55
3. **Packet Loss** (UDP Test).
4. **RTT (Round Trip Time)** (TCP Test).
5. **Jitter** (UDP Test).
6. **Maximum Capacity (C)** of the bottleneck link.
7. **Impact of TCP Options**:
    - Timestamp, SACK, MSS, Window Scaling.

## Measuring the goodput
