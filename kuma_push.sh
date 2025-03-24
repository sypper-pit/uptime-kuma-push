#!/bin/bash

# Configuration not use https://site.com/api/push/ZtGQYlfDNf?status=up&msg=OK&ping=
PUSH_URL="https://site.com/api/push/ZtGQYlfDNf"
CPU_WARNING=85
MEM_WARNING=90
DISK_WARNING=85

# Metric collection
cpu_usage=$(LANG=C top -bn1 | grep "Cpu(s)" | awk '{print int(100 - $8)}')
mem_usage=$(LANG=C free | awk '/Mem/ {if ($2 == 0) exit 1; printf "%.0f", ($3/$2)*100}' || echo "error")
disk_usage=$(LANG=C df / | awk 'NR==2 {print $5}' | sed 's/%//' || echo "error")

# Diagnostic output
#echo "Collected metrics:"
#echo "CPU Usage: $cpu_usage"
#echo "Memory Usage: $mem_usage"
#echo "Disk Usage: $disk_usage"

#echo "Raw memory data:"
LANG=C free | grep 'Mem'
#echo "----------------"

# Validate numeric values
if ! [[ "$cpu_usage" =~ ^[0-9]+$ ]] || ! [[ "$mem_usage" =~ ^[0-9]+$ ]] || ! [[ "$disk_usage" =~ ^[0-9]+$ ]]; then
    echo "Error: Invalid metric values detected"
    echo "Received values:"
    echo "CPU Usage: $cpu_usage"
    echo "Memory Usage: $mem_usage"
    echo "Disk Usage: $disk_usage"
    exit 1
fi

# Threshold checking
alert_reason=""

[[ $cpu_usage -ge $CPU_WARNING ]] && alert_reason+="CPU:${cpu_usage}% "
[[ $mem_usage -ge $MEM_WARNING ]] && alert_reason+="MEM:${mem_usage}% "
[[ $disk_usage -ge $DISK_WARNING ]] && alert_reason+="DISK:${disk_usage}% "

# URL encoding function
urlencode() {
    local string="${1}"
    local strlen=${#string}
    local encoded=""
    local pos c o

    for (( pos=0 ; pos<strlen ; pos++ )); do
        c=${string:$pos:1}
        case "$c" in
            [-_.~a-zA-Z0-9] ) o="${c}" ;;
            * )               printf -v o '%%%02x' "'$c"
        esac
        encoded+="${o}"
    done
    echo "${encoded}"
}

# System status output
echo "System Status:"
echo "CPU: $cpu_usage% (threshold: $CPU_WARNING%)"
echo "Memory: $mem_usage% (threshold: $MEM_WARNING%)"
echo "Disk: $disk_usage% (threshold: $DISK_WARNING%)"

if [ -n "$alert_reason" ]; then
    # Send warning status
    warning_msg=$(urlencode "WARNING: ${alert_reason}")
    warning_url="${PUSH_URL}?status=down&msg=${warning_msg}&ping=1&cpu=${cpu_usage}&mem=${mem_usage}&disk=${disk_usage}"
    curl -s -o /dev/null "$warning_url"
    echo "Warning status sent: $warning_url"

    # Immediately send up status
    up_msg=$(urlencode "Server is responsive")
    up_url="${PUSH_URL}?status=up&msg=${up_msg}&ping=1&cpu=${cpu_usage}&mem=${mem_usage}&disk=${disk_usage}"
    curl -s -o /dev/null "$up_url"
    echo "Up status sent: $up_url"
else
    # Send normal up status
    up_msg=$(urlencode "OK")
    up_url="${PUSH_URL}?status=up&msg=${up_msg}&ping=1&cpu=${cpu_usage}&mem=${mem_usage}&disk=${disk_usage}"
    curl -s -o /dev/null "$up_url"
    echo "Normal up status sent: $up_url"
fi

echo "Script execution completed."
