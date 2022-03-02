#!/bin/bash

if [ -z "$hostname" ]; then
	logger "missing hostname"
	exit 1
fi

if [ -z "$user" ]; then
	logger "missing user"
	exit 2
fi

if [ -z "$pass" ]; then
	logger "missing pass"
	exit3
fi

if [ -z "$interface" ]; then
	interface="eth0"
fi

if [ -z "$url" ]; then
url="https://dynupdate.no-ip.com/nic/update"
fi

if [ -z "$agent"]; then
agent="Personal noip-ducv6/linux-v1.0"
fi

lastaddr=''

update_ip () {
    addr=$(ip -6 addr show dev $interface | sed -e'/inet6/,/scope global/s/^.*inet6 \([^ ]*\)\/.*scope global.*$/\1/;t;d')
    if [[ $lastaddr != $addr ]]; then
        echo "updating to $addr"
        out=$(curl --get --silent --show-error --user-agent "$agent" --user "$user:$pass" -d "hostname=$hostname" -d "myipv6=$addr" $url)

        echo $out

        if [[ $out == nochg* ]] || [[ $out == good* ]]; then
            lastaddr=$addr
        elif [[ $out == 911 ]]; then
            echo "911 response, waiting 30 minutes"
            sleep 25m
        else
            exit 1
        fi
    fi
}

update_ip
while sleep 5m; do
    update_ip
done
