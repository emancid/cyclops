###  Monitoring Script mié abr 22 10:32:17 CEST 2015

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


#### hostname monitor script ####

_sensor_name="hostname"
_sensor_status="CHECKING"


_sensor_status=`echo $HOSTNAME` 

echo $_sensor_name":"$_sensor_status
################################
#### mon_time monitor script ####

_sensor_name="mon_time"
_sensor_status="CHECKING"


_sensor_status=`date +%H.%M.%S` 

echo $_sensor_name":"$_sensor_status
################################
#### uptime monitor script ####

_sensor_name="uptime"
_sensor_status="CHECKING"


_sensor_status=`cat /proc/uptime | awk '{ sum = $1/86400; print sum}' | sed 's/\..*/d/'` 

echo $_sensor_name":"$_sensor_status
################################
#### cpu monitor script ####


_sensor_name="cpu"
_sensor_status="CHECKING"

_cpu=`mpstat 1 1 | tail -n 1 | awk '{ print $NF }' | sed 's/\...$//'`

let _cpu=100-$_cpu

if [ -z "$_cpu" ]
then
	_sensor_status="DEAD"
else
	case "$_cpu" in
		[0-9]|[1-4][0-9])
			_sensor_status="UP"
		;;
		[5-7][0-9])
			_sensor_status="OK$_cpu%"
		;;
		100|[8-9][0-9])
			_sensor_status="FAIL$_cpu%"
		;;
		*)
			_sensor_status="UNKNOWN"
		;;
		esac
fi

echo $_sensor_name":"$_sensor_status
################################
#### swap monitor script ####

_sensor_name="swap"
_sensor_status="CHECKING"


_swp=`vmstat | awk '{ print $3 }' | tail -n 1`
_space=`swapon -s | tail -n 1 | awk '{ print $3}'`
let _total=($_swp*100)/$_space

case "$_total" in
	[0-5])
		_sensor_status="UP"
	;;
	[5-9])
		_sensor_status="OK$_total%"
	;;
	[1-4][0-9])
		_sensor_status="FAIL$_total%"
	;;
	[5-9][0-9]|100)
		sensor_status="DOWN$_total%"
	;;
	*)
		sensor_status="UNKNOWN"
	;;
esac

echo $_sensor_name":"$_sensor_status
################################
#### disk_space monitor script ####


_sensor_name="disk_space"
_sensor_status="CHECKING"

_space=`df -l | grep -v bullxscs4 | egrep "[8-9][0-9]%|100%" | awk '{ print $NF" "$(NF-1) }' | tr '\n' ' '`

if [ -z "$_space" ]
then
	_sensor_status="UP"
else
	_sensor_status="FAIL"$_space
fi

echo $_sensor_name":"$_sensor_status
################################
#### network monitor script ####


_sensor_name="network"
_sensor_status="CHECKING"

_net_list=`cat $_sensor_remote_path/$HOSTNAME.net.cfg | tr '\n' '|' | sed 's/\|$//'`

_net=`ip link | egrep ^.: | egrep "$_net_list" | sed -e 's/.. \(.*\):.*state.\(.*\)/ \1 \2 /' | awk '{ print $1" "$2}' | grep DOWN | sed 's/DOWN//' | tr '\n' ' '`

if [ -z "$_net" ]
then
	_sensor_status="UP"
else
	_sensor_status="DOWN"$_net
fi

echo $_sensor_name":"$_sensor_status
################################
#### slurm_queue monitor script ####

_sensor_name="slurm_squeue"
_sensor_status="CHECKING"


_sensor_status=`squeue -w nimbus$_nodo | grep -v JOBID | wc -l`

echo $_sensor_name":"$_sensor_status
################################
#### daemon_status monitor script ####

_sensor_name="daemon_status"
_sensor_status="CHECKING"
_debug_code="SRSTDS01"


_daemon_all=0
_daemon_bad=0
_daemon_ok=0

for _daemon in `chkconfig | awk '$5 == "3:activo" { print $1 }'`
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

echo $_sensor_name":"$_sensor_status
################################
#### sshd monitor script ####
_sensor_name="sshd"

_sensor_status="CHECKING"


if [ -f /etc/init.d/$_sensor_name ]
then
	_daemon_value=`service $_sensor_name status 2>&1 >/dev/null ; echo $?`
	case $_daemon_value in
	0)
		_sensor_status="UP"
	;;
	1)
		_sensor_status="DOWN"
	;;
	*)
		_sensor_status="FAIL"
	;;
	esac
else
	_sensor_status="ERROR"
fi

echo $_sensor_name":"$_sensor_status
################################
#### slurm monitor script ####
_sensor_name="slurm"

_sensor_status="CHECKING"


if [ -f /etc/init.d/$_sensor_name ]
then
	_daemon_value=`service $_sensor_name status 2>&1 >/dev/null ; echo $?`
	case $_daemon_value in
	0)
		_sensor_status="UP"
	;;
	1)
		_sensor_status="DOWN"
	;;
	*)
		_sensor_status="FAIL"
	;;
	esac
else
	_sensor_status="ERROR"
fi

echo $_sensor_name":"$_sensor_status
################################
