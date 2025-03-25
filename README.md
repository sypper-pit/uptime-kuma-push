# Uptime Kuma Server Monitor

A bash script for monitoring server metrics and reporting to Uptime Kuma.

## Features

- Monitors CPU, memory, and disk usage
- Sends alerts to Uptime Kuma when thresholds are exceeded
- Easy to configure and integrate with cron
- Supports Ubuntu 18+ and similar Linux distributions

## Quick Start

1. Save the script to `/usr/local/bin/uptime_monitor.sh`
2. Make it executable: `chmod +x /usr/local/bin/uptime_monitor.sh`
3. Add to crontab: `*/5 * * * * /usr/local/bin/uptime_monitor.sh`

## Configuration

Edit the script to set your Uptime Kuma push URL and alert thresholds:

```bash
PUSH_URL="https://your-uptime-kuma-url.com/api/push/your-token"
CPU_WARNING=85
MEM_WARNING=90
DISK_WARNING=85
```

## Requirements

- curl
- procps (for top and free commands)
- Access to /proc/meminfo and /proc/stat

## Logging

Logs are written to `/var/log/uptime_monitor.log`
