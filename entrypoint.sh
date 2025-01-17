#!/bin/sh
set -e

confd -onetime -backend env --log-level debug

cat /etc/openvpn-monitor/openvpn-monitor.conf

exec "$@"
