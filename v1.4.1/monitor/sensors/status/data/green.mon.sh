### green Monitoring Script Mon Feb 29 10:15:02 CET 2016

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

#!/bin/bash

if [ -f $_sensor_remote_path/sensor.pid ]
then
	rm $_sensor_remote_path/sensor.pid 2>&1 >/dev/null
fi

exit 0
