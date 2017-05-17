### nodo1 Monitoring Script Mon Feb 29 10:15:01 CET 2016

######################################################
#		SENSORS VAR FILE                     #
######################################################

_base_path="/opt/cyclops"
_monitor_path=$_base_path"/monitor"

_sensors_path=$_monitor_path"/sensors"
_sensors_config_path=$_sensors_path"/status/conf"
_sensors_script_path=$_sensors_path"/status/scripts"
_sensors_data=$_sensors_path"/status/data"

_sensor_remote_path="/root/cyclops/sensors"

######################################################


#!/bin/bash

_sensor_pid=$(echo $$)

_old_pid=$(head -n 1 $_sensor_remote_path/sensor.pid)
_wait_cycles=0
_wait_process=$(ps ax | grep $_old_pid 2>/dev/null | wc -l )

export LANG="en_EN.UTF-8"

while [[ "$_wait_process" != 0  &&  "$_wait_cycles" -lt 4 ]]
do

	sleep 5s
	_wait_process=$(ps ax | grep $_old_pid 2>/dev/null | wc -l )
	let "_wait_cycles++"

done

if [ "$_wait_cycles" -gt 4 ]
then
	kill -9 $_old_pid
	rm $_sensor_remote_path/sensor.pid 2>/dev/null
fi

echo $_sensor_pid >$_sensor_remote_path/sensor.pid

if [ -f "$_sensor_remote_path/torquemada.sensor.sh" ]
then
	chmod 755 $_sensor_remote_path/torquemada.sensor.sh
	$_sensor_remote_path/torquemada.sensor.sh $_sensor_pid $_sensor_remote_path/sensor.pid &
fi

trap 'kill $(jobs -p)' EXIT

#### hostname monitor script ####

_sensor_name="hostname"
_sensor_status="CHECKING"


_sensor_status=`echo $HOSTNAME` 

echo $_sensor_name":"$_sensor_status"@"
################################
#### mon_time monitor script ####

_sensor_name="mon_time"
_sensor_status="CHECKING"


_sensor_status=`date +%H.%M.%S` 

echo $_sensor_name":"$_sensor_status"@"
################################
#### uptime monitor script ####

_sensor_name="uptime"
_sensor_status="CHECKING"


_sensor_status=`cat /proc/uptime | awk '{ sum = $1/86400; print sum}' | sed 's/\..*/d/'` 

[[ $_sensor_status == [0-3]d ]] && _sensor_status="CHECKING "$_sensor_status || _sensor_status="UP "$_sensor_status

echo $_sensor_name":"$_sensor_status"@"
################################
#### cpu monitor script ####


_sensor_name="cpu"
_sensor_status="CHECKING"

_cpu=`mpstat 2 2 | awk '$1 ~ "^[a-zA-z]*:" { print $NF }' | sed 's/\...$//'`

let _cpu=100-$_cpu

if [ -z "$_cpu" ]
then
	_sensor_status="MARK sensor err"
else
	case "$_cpu" in
		[0-9]|[1-4][0-9])
			_sensor_status="UP $_cpu%"
		;;
		[5-6][0-9])
			_sensor_status="OK $_cpu%"
		;;
		100|[7-9][0-9])
			_sensor_status="CHECKING $_cpu%"
		;;
		*)
			_sensor_status="UNKNOWN"
		;;
		esac
fi

echo $_sensor_name":"$_sensor_status"@"
################################
#### swap monitor script ####

_sensor_name="swap"
_sensor_status="CHECKING"


_swp=`vmstat | awk '{ print $3 }' | tail -n 1`
_space=`swapon -s | tail -n 1 | awk '{ print $3}'`
let _total=($_swp*100)/$_space

case "$_total" in
	[0-9])
		_sensor_status="UP"
	;;
	[1-8][0-9])
		_sensor_status="OK $_total%"
	;;
	9[0-9]|100)
		_sensor_status="MARK $_total%"
	;;
        "")
                _sensor_status="MARK sensor_fail"       
        ;;
	*)
		_sensor_status="UNKNOWN"
	;;
esac

echo $_sensor_name":"$_sensor_status"@"
################################
#### disk_space monitor script ####



_sensor_name="disk_space"
_sensor_status="CHECKING"

_space=`df -l | egrep -v "bullxscs4|systemimager" | egrep "9[0-9]%|100%" | awk '{ print $NF" "$(NF-1) }' | tr '\n' ' '`

if [ -z "$_space" ]
then
	_sensor_status="UP"
else
	_sensor_status="FAIL "$_space
fi

echo $_sensor_name":"$_sensor_status"@"
################################
#### network monitor script ####


_sensor_name="network"
_sensor_status="CHECKING"

if [ -f "$_sensor_remote_path/$HOSTNAME.net.cfg" ]
then
	_net_list=$( cat $_sensor_remote_path/$HOSTNAME.net.cfg | tr '\n' '|' | sed -e 's/|$//')
	_net=`ip link | egrep ^.: | egrep "${_net_list}" | sed -e 's/.. \(.*\):.*state.\(.*\)/ \1 \2 /' | awk '{ print $1" "$2}' | grep DOWN | sed 's/DOWN//' | tr '\n' ' '`
	[ -z "$_net" ] && _sensor_status="UP" || _sensor_status="DOWN "$_net
else
	_sensor_status="DISABLE not configured"
fi

echo $_sensor_name":"$_sensor_status"@"
################################
#### daemon_status monitor script ####

_sensor_name="daemon_status"
_sensor_status="CHECKING"
_debug_code="SRSTDS01"


_daemon_all=0
_daemon_bad=0
_daemon_ok=0

for _daemon in `chkconfig | awk '$5 ~ "3:on" { print $1 }'`
do
	let "_daemon_all++"

	if /etc/init.d/$_daemon status 2>/dev/null >/dev/null
	then
		let "_daemon_ok++"
	else
		let "_daemon_bad++"
	fi

done

if [ $_daemon_bad != 0 ] 
then 
	_sensor_status="FAIL/$_daemon_all/$_daemon_ok/$_daemon_bad/"
else
	_sensor_status="UP/$_daemon_all/$_daemon_ok/"	
fi

echo $_sensor_name":"$_sensor_status"@"
################################
#### heartbeat monitor script ####
_sensor_name="heartbeat"

_sensor_status="CHECKING"


if [ -f /etc/init.d/$_sensor_name ]
then
	_daemon_value=$( service $_sensor_name status 2>/dev/null >/dev/null; echo $?)
	case $_daemon_value in
	0)
		_sensor_status="UP"
	;;
	1)
		_sensor_status="DOWN stop"
	;;
	"")
		_sensor_status="UNKNOWN no data"
	;;
	*)
		_sensor_status="DOWN err.($_daemon_value)"
	;;
	esac
else
	_sensor_status="DISABLE not conf"
fi

echo $_sensor_name":"$_sensor_status"@"
################################
#### httpd monitor script ####
_sensor_name="httpd"

_sensor_status="CHECKING"


if [ -f /etc/init.d/$_sensor_name ]
then
	_daemon_value=$( service $_sensor_name status 2>/dev/null >/dev/null; echo $?)
	case $_daemon_value in
	0)
		_sensor_status="UP"
	;;
	1)
		_sensor_status="DOWN stop"
	;;
	"")
		_sensor_status="UNKNOWN no data"
	;;
	*)
		_sensor_status="DOWN err.($_daemon_value)"
	;;
	esac
else
	_sensor_status="DISABLE not conf"
fi

echo $_sensor_name":"$_sensor_status"@"
################################
#### sshd monitor script ####
_sensor_name="sshd"

_sensor_status="CHECKING"


if [ -f /etc/init.d/$_sensor_name ]
then
	_daemon_value=$( service $_sensor_name status 2>/dev/null >/dev/null; echo $?)
	case $_daemon_value in
	0)
		_sensor_status="UP"
	;;
	1)
		_sensor_status="DOWN stop"
	;;
	"")
		_sensor_status="UNKNOWN no data"
	;;
	*)
		_sensor_status="DOWN err.($_daemon_value)"
	;;
	esac
else
	_sensor_status="DISABLE not conf"
fi

echo $_sensor_name":"$_sensor_status"@"
################################
#### slurm monitor script ####
_sensor_name="slurm"

_sensor_status="CHECKING"


if [ -f /etc/init.d/$_sensor_name ]
then
	_daemon_value=$( service $_sensor_name status 2>/dev/null >/dev/null; echo $?)
	case $_daemon_value in
	0)
		_sensor_status="UP"
	;;
	1)
		_sensor_status="DOWN stop"
	;;
	"")
		_sensor_status="UNKNOWN no data"
	;;
	*)
		_sensor_status="DOWN err.($_daemon_value)"
	;;
	esac
else
	_sensor_status="DISABLE not conf"
fi

echo $_sensor_name":"$_sensor_status"@"
################################

#!/bin/bash

if [ -f $_sensor_remote_path/sensor.pid ]
then
	rm $_sensor_remote_path/sensor.pid 2>&1 >/dev/null
fi

exit 0
