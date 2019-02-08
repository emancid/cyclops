#!/bin/bash

# ps -eFl
# F S UID        PID  PPID  C PRI  NI ADDR SZ WCHAN    RSS PSR STIME TTY          TIME CMD
#echo "date;host;user;ppid;pid;status;process"

## GLOBAL --

_config_path="/etc/cyclops"

if [ ! -f $_config_path/global.cfg ]
then
        echo "Global config file don't exits"
        exit 1
else
        source $_config_path/global.cfg
fi

source $_color_cfg_file

## LOCAL --

_opt_kill_msg="check"
_opt_type="yes"
_opt_type="zombie"

#### LIBS ####

        source $_libs_path/node_group.sh
        source $_libs_path/node_ungroup.sh

###########################################
#              PARAMETERs                 #
###########################################

while getopts ":t:v:n:u:kh:" _optname
do

        case "$_optname" in
                "v")
                        _opt_show="yes"
                        _par_show=$OPTARG
                        if [ !"$_par_show" == "human" ] || [ !"$_par_show" == "wiki" ] || [ !"$_par_show" == "commas" ]
                        then
                                echo "-v [option] Show formated results"
                                echo "          human: human readable"
                                echo "          wiki:  cyclops format readable"
                                echo "          commas: excell readable"
                                exit 1
                        fi
                ;;
                "t")
                        _par_type=$OPTARG
                        if [ !"$_par_show" == "zombie" ] || [ !"$_par_show" == "orphan" ]
                        then
                                echo "-t [option] Choose type of problematic process"
                                echo "          zombie: Classic Zombie Process"
                                echo "          orphan: Strange Behaviour of process (only compute nodes)"
				exit 1
                        fi
                ;;
		"n")
			_opt_node="yes"
			_par_node=$OPTARG

                        #_name=$( echo $_par_node | cut -d'[' -f1 | sed 's/[0-9]*$//' )
                        #_range=$( echo $_par_node | sed -e "s/$_name\[/{/" -e 's/\([0-9]*\)\-\([0-9]*\)/\{\1\.\.\2\}/g' -e 's/\]$/\}/' -e "s/$_name\([0-9]*\)/\1/"  )
                        #_values=$( eval echo $_range | tr -d '{' | tr -d '}' )
                        #_long=$( echo "${_values}" | tr ' ' '\n' | sed "s/^/$_name/" )

                        #[ -z $_range ] && echo "Need nodename or range of nodes" && exit 1

			_ctrl_grp=$( echo $_par_node | grep @ 2>&1 >/dev/null ; echo $? )

			if [ "$_ctrl_grp" == "0" ]
			then
				_par_node_grp=$( echo "$_par_node" | tr ',' '\n' | grep ^@ | sed 's/@//g' | tr '\n' ',' )
				_par_node=$( echo $_par_node | tr ',' '\n' | grep -v ^@ | tr '\n' ',' )
				_par_node_grp=$( awk -F\; -v _grp="$_par_node_grp" '{ split (_grp,g,",") ; for ( i in g ) {  if ( $2 == g[i] || $3 == g[i] || $4 == g[i] ) { _n=_n""$2","  }}} END { print _n }' $_type )
				_par_node_grp=$( node_group $_par_node_grp )
				_par_node=$_par_node""$_par_node_grp

				[ -z "$_par_node" ] && echo "ERR: Don't find nodes in [$_par_node_grp] definited group(s)/family(s)" && exit 1
			fi

			_long=$( node_ungroup $_par_node | tr ' ' '\n' )
		;;
		"u")
			_opt_user="yes"
			_par_user=$OPTARG

			if [ -z "$_par_user" ]
			then
				echo "-u [user] filter actions with user name"
				exit 1
			fi
		;;
		"k")
			_opt_kill="yes"
			_opt_kill_msg="kill"
		;;
		"h")
			case "$OPTARG" in
			"des")
				echo "$( basename "$0" ) : tool for clean compute node user task and zombie process"
				echo "	Default path: $( dirname "${BASH_SOURCE[0]}" )"
				exit 0
			;;
			"*")
				echo "ERR: Use -h for help"
				exit 1
			;;
			esac
		;;
		":")
			if [ "$OPTARG" == "h" ]
			then
				echo
				echo "CYCLOPS TOOL: ZOMBIE AND ORPHAN CLEANER"
				echo
		                echo "-v [option] Show formated results"
                                echo "          human: human readable"
                                echo "          wiki:  cyclops format readable"
                                echo "          commas: excell readable"
				echo "-t [option] Choose type of problematic process"
				echo "		zombie: Classic Zombie Process"
				echo "		orphan: Strange Behaviour of process (only compute nodes)"
                                echo "-n [nodename|family|type] Choose one node, family or type of nodes"
                                echo "          options are indicated in $_type"
                                echo "          nodename: can use regexp, BEWARE, test before"
				echo "-u [user] filter action with user name"
				echo "-k Apply Kill Signal to detected processes"
				echo "-h Help this help"
				echo "	des: Detailed Command Help"
				exit 0
			else
				echo "ERR: Use -h for help"
				exit 1
			fi
		;;
        esac
done

shift $((OPTIND-1))

## DEBUG PARAMETERS --
#echo "-v : "$_opt_show" : "$_par_show
#echo "-t : "$_opt_type" : "$_par_type
#echo "-n : "$_opt_node" : "$_par_node
#echo "-k : "$_opt_kill
####

if [ -z "$_par_node" ] || [ -z "$_opt_node" ] && [ "$_par_type" != "intruder" ]
then 
	echo "No node/group/family specificated, use -n option"
	exit 1
fi

###########################################
#              FUNCTIONs                  #
###########################################

ps_zombie_check()
{

	for _zombie in $(  ps -eFl | awk '$2 ~ "^Z"  {if ( $16 ~ "[0-9]*" ) { print $3";"$4";"$2";"$NF";"$5 }}' | grep -v "^UID;PID;S;CMD;PPID" )
	do

		_user=$( echo $_zombie | cut -d';' -f1 )
		_pid=$( echo $_zombie | cut -d';' -f2 )
		_status=$( echo $_zombie | cut -d';' -f3 )
		_process=$( echo $_zombie | cut -d';' -f4 )
		_ppid=$( echo $_zombie | cut -d';' -f5 )

		echo $( date +%s )";"$HOSTNAME";"$_user";"$_ppid";"$_pid";"$_status";"$_process";NO ACTION REQUIRED"

	done
}

ps_zombie_kill()
{

        for _zombie in $(  ps -eFl | awk '$2 ~ "^Z"  {if ( $16 ~ "[0-9]*" ) { print $3";"$4";"$2";"$NF";"$5 }}' | grep -v "^UID;PID;S;CMD;PPID" )
        do

                _user=$( echo $_zombie | cut -d';' -f1 )
                _pid=$( echo $_zombie | cut -d';' -f2 )
                _status=$( echo $_zombie | cut -d';' -f3 )
                _process=$( echo $_zombie | cut -d';' -f4 )
                _ppid=$( echo $_zombie | cut -d';' -f5 )

                _kill_status=$( kill -9 $_ppid 2>&1 >/dev/null ; echo $? )

		case "$_kill_status" in
			0)
				_kill_status="KILLED"
			;;
			*)
				_kill_status="CAN'T KILL IT ($_kill_status)"
			;;
		esac

                echo $( date +%s )";"$HOSTNAME";"$_user";"$_ppid";"$_pid";"$_status";"$_process";"$_kill_status 

        done
}

ps_orphan_check()
{

	for _orphan in $( ps -eFl | awk '{if ( $16 ~ "[0-9]*" ) { print $3";"$4";"$2";"$NF";"$5 }}' | egrep -v ^"root|rpc|dbus|ntp|munge" | grep -v "^UID;PID;S;CMD;PPID" )
	do
		if [ ! -z "$_orphan" ]
		then			
			_user=$( echo $_orphan | cut -d';' -f1 )
			_pid=$( echo $_orphan | cut -d';' -f2 )
			_status=$( echo $_orphan | cut -d';' -f3 )
			_process=$( echo $_orphan | cut -d';' -f4 )
			_ppid=$( echo $_orphan | cut -d';' -f5 )

			echo $( date +%s )";"$HOSTNAME";"$_user";"$_ppid";"$_pid";"$_status";"$_process";NO ACTION REQUIRED"
		fi
	done
}

ps_intruder_check()
{

        for _intruder in $( ps -eFl | grep -v sshd |  awk '$17 ~ "ssh" && $3 == "root" || $3 != "root" { print $3";"$4";"$2";"$NF";"$5 }' | egrep -v ^"rpc|dbus|ntp|munge" | grep -v "^UID;PID;S;CMD;PPID" )
        do
                if [ ! -z "$_intruder" ]
                then
                        _user=$( echo $_intruder | cut -d';' -f1 )
                        _pid=$( echo $_intruder | cut -d';' -f2 )
                        _status=$( echo $_intruder | cut -d';' -f3 )
                        _process=$( echo $_intruder | cut -d';' -f4 )
                        _ppid=$( echo $_intruder | cut -d';' -f5 )

                        echo $( date +%s )";"$HOSTNAME";"$_user";"$_ppid";"$_pid";"$_status";"$_process";INTRUDER DETECTED"
		else
			echo $( date +%s )";NO INTRUDER DETECTED"
                fi
        done
}


ps_orphan_kill()
{

        for _orphan in $( ps -eFl | awk '{if ( $16 ~ "[0-9]*" ) { print $3";"$4";"$2";"$NF";"$5 }}' | egrep -v ^"root|rpc|dbus|ntp|munge" | grep -v "^UID;PID;S;CMD;PPID" )
        do
                if [ ! -z "$_orphan" ]
                then                    
                        _user=$( echo $_orphan | cut -d';' -f1 )
                        _pid=$( echo $_orphan | cut -d';' -f2 )
                        _status=$( echo $_orphan | cut -d';' -f3 )
                        _process=$( echo $_orphan | cut -d';' -f4 )
                        _ppid=$( echo $_orphan | cut -d';' -f5 )

                        _kill_status=$( kill -9 $_pid 2>&1 >/dev/null ; echo $? ) 
			
			case "$_kill_status" in
				0)
					_kill_status="KILLED"
				;;
				*)
					_kill_status="CAN'T KILL IT ($_kill_status)"
				;;
			esac		
	
                        echo $( date +%s )";"$HOSTNAME";"$_user";"$_ppid";"$_pid";"$_status";"$_process";"$_kill_status
                fi
        done
}

ps_intruder_kill()
{
        for _intruder in $( ps -eFl |  awk '$17 ~ "ssh" && $3 == "root" || $3 != "root" { print $3";"$4";"$2";"$NF";"$5 }' | egrep -v ^"rpc|dbus|ntp|munge" | grep -v "^UID;PID;S;CMD;PPID" )
        do
                if [ ! -z "$_intruder" ]
                then
                        _user=$( echo $_intruder | cut -d';' -f1 )
                        _pid=$( echo $_intruder | cut -d';' -f2 )
                        _status=$( echo $_intruder | cut -d';' -f3 )
                        _process=$( echo $_intruder | cut -d';' -f4 )
                        _ppid=$( echo $_intruder | cut -d';' -f5 )

                        _kill_status=$( kill -9 $_pid 2>&1 >/dev/null ; echo $? )

                        case "$_kill_status" in
                                0)
                                        _kill_status="KILLED"
                                ;;
                                *)
                                        _kill_status="CAN'T KILL IT ($_kill_status)"
                                ;;
                        esac

                        echo $( date +%s )";"$HOSTNAME";"$_user";"$_ppid";"$_pid";"$_status";"$_process";"$_kill_status
                fi
        done
}

ctrl_zombie()
{
	for _node in $( echo "${_long}" )
	do
		if [ "$_opt_kill" == "yes" ]
		then
			ssh -o ConnectTimeout=10 $_node "$(typeset -f) ; ps_zombie_kill" 2>/dev/null &
			[ "$?" == "0" ] && _audit_status="OK" || _audit_status="FAIL"
			$_script_path/audit.nod.sh -i event -e alert -s $_audit_status -n $_node -m "zombie kill action" 2>/dev/null 
		else
			ssh -o ConnectTimeout=10 $_node "$(typeset -f) ; ps_zombie_check" 2>/dev/null &
		fi
	done
	wait

	[ -z "$_node" ] && echo $( date +%s )";"$_par_node";NODE(s) NOT FINDED"
}

ctrl_orphan()
{
        for _node in $( echo "${_long}" )
        do

		_check_node=$( cat $_type | awk -F\; -v _n="$_node" '$2 == _n && $4 ~ "compute" { print "0" }' )
		if [ "$_check_node" == "0" ]
		then
			_job_ctrl=$( ssh -o ConnectTimeout=10 $_node squeue -w $_node |  grep -v "PARTITION" | wc -l )
			if [ "$_job_ctrl" -eq 0 ] 
			then
				if [ "$_opt_kill" == "yes" ] 
				then
					ssh -o ConnectTimeout=10 $_node "$(typeset -f) ; ps_orphan_kill" 2>/dev/null & 
					[ "$?" == "0" ] && _audit_status="OK" || _audit_status="FAIL"
					$_script_path/audit.nod.sh -i event -e alert -s $_audit_status -n $_node -m "orphan kill action" 2>/dev/null 
				else
					ssh -o ConnectTimeout=10 $_node "$(typeset -f) ; ps_orphan_check" 2>/dev/null &
				fi
			else
				echo  $( date +%s )";"$_node";WARNING: JOBS ACTIVE, NO ACTION OVER IT"
			fi
		else
			echo $( date +%s )";"$_node";IGNORE ACTION: NO COMPUTE NODE"
		fi
        done
	wait

	[ -z "$_node" ] && echo $( date +%s )";"$_par_node";NODE(s) NOT FINDED OR NOT COMPUTE NODE(s)"
}

ctrl_intruder()
{
        for _node in $( cat $_type | egrep ";up$|;diagnose$" | cut -d';' -f2 )
        do
		if [ "$_opt_kill" == "yes" ]
		then
			echo "BEWARE: STILL NOT IMPLEMENTED"
			#ssh $_node "$(typeset -f) ; ps_intruder_kill" 2>/dev/null &
		else
			ssh -o ConnectTimeout=10 $_node "$(typeset -f) ; ps_intruder_check" 2>/dev/null &
			[ $? -ne 0 ] && echo "ERROR CONNECTING $_node"
		fi
        done
        wait
}

print_output()
{

	if [ -z "$_output" ]
	then
		echo "NO $_par_type DETECTED IN $_par_node"
	else
		case "$_par_show" in 
			"human")
				echo -e "date;time;hostname;user;ppid;pid;status;process;kill status\n${_output}" | awk -F\; 'BEGIN { OFS=";"} {if ( $1 ~ "^[0-9]*$" && $0 !~  "^$" ) { $1=strftime("%d-%m-%Y;%H:%M",$1) } ; print $0 }' | column -s\; -t
			;;
			"commas")
				echo "${_output}"
			;;
			"wiki")
				echo "NO YET IMPLEMENTED"
				echo "${_output}"
			;;
			*)
				echo "IF YOU DON'T CHOOSE ANY FORMAT YOU GET COMMAS!!!"
				echo "${_output}"
			;;
		esac
	fi

}

###########################################
#              MAIN EXEC                  #
###########################################


	case "$_par_type" in
	"zombie")
		echo ":processing $_par_type"
		_output=$( ctrl_zombie )
	;;
	"orphan")
		echo ":processing $_par_type"
		_output=$( ctrl_orphan )
	;;
	"intruder")
		echo ":processing $_par_type"
		_output=$( ctrl_intruder )	
	;;
	*)
		echo "BAD PROCESS TYPE, EXIT"
		exit 1
	;;
	esac

	print_output


