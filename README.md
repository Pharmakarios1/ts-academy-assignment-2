A suite of Bash diagnostic scripts designed to collect system specs, check disk thresholds, and perform network connectivity checks with logging.

## Required Structure
- `system-info.sh`: Displays system hostname, user, uptime, CPU, memory, OS, kernel, and current directory.
- `disk-check.sh`: Evaluates disk usage against a threshold (1-100%).
- `network-check.sh`: Resolves hostnames, performs ICMP pings, prints network interface details, and tests TCP port availability.
- `logs/`: Contains operation logs generated at runtime.

## Usage

### System Information
```bash
./system-info.sh

### Disk Check
Bash

./disk-check.sh <threshold> [path]
# Example:
./disk-check.sh 80 /

### Network Check
Bash

./network-check.sh <hostname-or-ip> [port]
# Examples:
./network-check.sh google.com
./network-check.sh google.com 443

Exit Codes

    0: Success / Usage below threshold.

    1: Operational threshold exceeded / Port closed or unreachable.

    2: Invalid arguments / Port out of range (1-65535) / Invalid threshold (1-100).

Assumptions

    Target environment runs standard GNU/Linux utilities (df, ip, ping, getent, nc).

    Execution user has read permissions on specified target paths and logs.