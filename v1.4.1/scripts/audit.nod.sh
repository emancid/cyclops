#!/bin/bash

###########################################
#            AUDIT NODES SCRIPT           #
###########################################

#    GPL License
#
#    This file is part of Cyclops Suit.
#
#    Foobar is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Foobar is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

############# VARIABLES ###################
#

IFS="
"

_pid=$( echo $$ )
_debug_code="AUDIT NODES "
_debug_prefix_msg="Audit Nodes Main: "
_exit_code=0

_par_filter="none"
_sh_action="show"

## GLOBAL --

_config_path="/etc/cyclops"

_server_proc=$( nproc | awk '{ _proc=$1+1 } END { print _proc}'  )
_par_wait_time="20s"

if [ ! -f $_config_path/global.cfg ]
then
        echo "Global config file don't exits"
        exit 1
else
        source $_config_path/global.cfg
	source $_config_path_sys/wiki.cfg
fi

source $_color_cfg_file

## CYCLOPS OPTION STATUS CHECK

_audit_status=$( awk -F\; '$1 == "CYC" && $2 == "0003" && $3 == "AUDIT" { print $4 }' $_sensors_sot )
_cyclops_ha=$( awk -F\; '$1 == "CYC" && $2 == "0006" { print $4}' $_sensors_sot )

###########################################
#              PARAMETERs                 #
###########################################

[ "$#" == "0" ] && echo "ERR: Use -h for help" && exit 1

_command_opts=$( echo "$@" | awk -F\- 'BEGIN { OFS=" -" } { for (i=2;i<=NF;i++) { if ( $i ~ /^m/ ) { gsub(/^[a-z] /,"&@",$i) ; gsub (/$/,"@",$i) }}; print $0 }' | tr '@' \' )

while getopts ":dh:kg:n:i:e:m:s:v:f:x" _optname
do

        case "$_optname" in
                "d")
                        _opt_daemon="yes"
			_sh_action="daemon"
			_par_gen="wiki"
                ;;
		"n")
                        _opt_node="yes"
                        _par_node=$OPTARG
			_audit_code_type="NOD"

			if [ "$_par_node" == "all" ] 
			then
				_long=$( cat $_type | sed -e '/^#/d' -e '/^$/d' | cut -d';' -f2 )
			else
				_name=$( echo $_par_node | cut -d'[' -f1 | sed 's/[0-9]*$//' )
				_range=$( echo $_par_node | sed -e "s/$_name\[/{/" -e 's/\([0-9]*\)\-\([0-9]*\)/\{\1\.\.\2\}/g' -e 's/\]$/\}/' -e "s/$_name\([0-9]*\)/\1/"  )
				_values=$( eval echo $_range | tr -d '{' | tr -d '}' )
				_long=$( echo "${_values}" | tr ' ' '\n' | sed "s/^/$_name/" )
			fi
		;;
		"i")
			_opt_insert="yes"
			_par_insert=$OPTARG
			
			_sh_action="insert"

			if [ !"$_par_insert" == "event" ] || [ !"$_par_insert" == "bitacora" ] || [ !"$_par_insert" == "issue" ]
			then
				echo "-i [option] Insert register in audit files, option -e and -m mandatory. Only accept ONE node"
				echo "		event: event happens over node"
				echo "		bitacora: human tech event register over node"
				exit 1
			fi
		;;
		"e")
			_opt_event="yes"
			_par_event=$( echo $OPTARG | tr [:lower:] [:upper:] )

		;;
		"m")
			_opt_msg="yes"
			_par_msg=$OPTARG

                        if [ -z "$_par_msg" ]
                        then
                                echo "-m [mensage text] Dependency from option -i, insert mensage text over audit event"
                                exit 1
                        fi
		;;
		"s")
                        _opt_stat="yes"
                        _par_stat=$( echo $OPTARG | tr [:lower:] [:upper:] )

			#if [ something ]
                        #then
                        #        echo "-s [option] Dependency from option -i, assign event status to audit event"
			#	echo "		OK/UP/FAIL/DOWN: Alert event status info"
			#	echo "		UP/DRAIN/DIAGNOSE/CONTENT: Monitoring Node status info"
                        #        exit 1
                        #fi
		;;
		"k")
			_opt_graph="yes"
		;;
		"v")
			_opt_show="yes"
			_par_show=$OPTARG
			_sh_action="show"

                        if [ !"$_par_show" == "human" ] || [ !"$_par_show" == "wiki" ] || [ !"$_par_show" == "commas" ] || [ !"$_par_show" == "original" ] || [ !"$_par_show" == "debug" ]
                        then
                                echo "-v [option] Show formated results"
                                echo "          human: human readable"
                                echo "          wiki:  wiki format readable"
                                echo "          commas: excell readable"  
				echo "		original: data in original format"
				echo "		eventlog: activiy and bitacora events, if you don't especify node show all"
                                exit 1
                        fi
		;;
		"f")
                        _opt_filter="yes"
                        _par_filter=$OPTARG

                        if [ !"$_par_filter" == "activity" ] || [ !"$_par_filter" == "bitacora" ] || [ !"$_par_filter" == "settings" ] || [ !"$_par_filter" == "resume" ] || [ !"$_par_filter" == "main" ]
                        then
                                echo "-f [option] filter Show option info"
                                echo "          activity: Node Activity Info"
                                echo "          bitacora: Custom Info about node"
                                echo "          settings: Audit Soft and Hard Info"  
                                echo "          resume: Basic Node Info"
				echo "		.. you can add more than option separated with commas"
                                exit 1
			fi
		;;
		"g")
			_opt_gen="yes"
			_par_gen=$OPTARG
			_sh_action="gen"

			if [ !"$_par_gen" == "data" ] || [ !"$_par_gen" == "wiki" ] || [ !"$_par_gen" == "index" ] || [ !"$_par_gen" == "all" ]
			then
				echo "-g [option] generate required audit data"
				echo "		data: host audit data from diferent sources"
				echo "		wiki: generate wiki pages from existing data files"
				echo "		index: regenerate wiki index"
				echo "		all: recreate all audit phases"
				exit 1
			fi	
		;;
		"x")
			_opt_debug="yes"
			_sh_action="debug"
		;;
		"h")
			case "$OPTARG" in
			"des")
				echo "$( basename "$0" ) : Cyclops Audit Module, insert bitacora events, log nodes and device event, and inventary system"
				echo "	Default path: $( dirname "${BASH_SOURCE[0]}" )"
				echo "	Data path: $_audit_data_path"
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
				echo "CYCLOPS AUDIT MODULE MANAGEMENT COMMAND"
				echo "	Insert bitacora or event in audit cyclops database"
				echo "	Or show registered information about main system or nodes"
				echo
				echo "-d        daemon executing, exclusive option"
				echo "-i [option] Insert register in audit files, option -e and -m mandatory. Only accept ONE node"
				echo "		event: event happens over node"
				echo "		bitacora: human tech event register over node"
				echo "		issue: interactive mode for friendly use, exclusive option"
				echo "	-e [option] Dependency from option -i, select avaible event type"
				echo "		alert: critical event over node"
				echo "		status: change node status"     
				echo "		info: informative event over node"
				echo "	-m [mensage text] Dependency from option -i, insert mensage text over audit event"
				echo "	-s [option] Dependency from option -i, assign event status to audit event"
				echo "		OK/UP/FAIL/DOWN: Alert event status info"
				echo "		UP/DRAIN/DIAGNOSE/CONTENT: Monitoring Node status info"
				echo "-n [nodename|family|type] Choose one node, family or type of nodes"
				echo "	options are indicated in $_type"
				echo "	nodename: can use regexp, BEWARE, test before"
				echo "-v [option] Show formated results EXCLUSIVE OPTION"
				echo "	human: human readable"
				echo "	wiki:  wiki format readable"
				echo "	commas: excell readable"
				echo "	eventlog: activiy and bitacora events, if you don't especify node show all"
				echo "-f [option] filter Show option info (only human/commas -v option)"
				echo "	main: global bitacora"
				echo "	activity: Node Activity Info"
				echo "	bitacora: Custom Info about node"
				echo "	settings: Audit Soft and Hard Info"  
				echo "	resume: Basic Node Info"
				echo "	.. you can add more than option separated with commas"
				echo "-g [option] generate required audit data"
				echo "	data: host audit data from diferent sources"
				echo "	wiki: generate wiki pages from existing data files"
				echo "		-k: if you want to generate graph info on index, use this option"
				echo "	index: regenerate wiki index"
				echo "	all: generate all audit steps data extractor ( implies -k )"
				echo "-h [|des] help is help"
				echo "	des: Detailed help about command" 
				echo
				exit 0
			else
				echo "ERR: Use -h for help"
				exit 1
			fi
                ;;
                *)
                        echo "WHATs HAPPEND?!"
                        echo $_optname" "$_OPTARG
                        exit 1
                ;;
                --)
                        echo "OPssss!!!"
                        echo $_optname" "$OPTARG
                        exit 1
                ;;
		"")
			echo "HEY GUY!!! ANY OPTION PLEASE"
			exit 1
		;;
        esac

done

shift $((OPTIND-1))



###########################################
#              FUNCTIONs                  #
###########################################

node_group()
{

        _prefix=$( echo "${1}" | sed -e 's/^ *//' -e 's/ *$//' | tr ' ' '\n' | sed 's/^\([a-zA-Z_-]*\)[0-9]*$/\1/' | sort -u )

        for _node_prefix in $( echo "${_prefix}" )
        do
               _node_range=$_node_range""$( echo "${1}" | sed -e 's/^ *//' -e 's/ *$//' | tr ' ' '\n' | grep "^$_node_prefix" | sed 's/[0-9]*$/;&/' | sort -t\; -k2,2n -u | awk -F\; '
                { if ( NR == "1" ) { _sta=$2 ; _end=$2  ; _string=$1"[" }
                else {
                    if ( $2 == _end + 1 ) {
                        _sep="-" ;
                        _end=$2 }
                        else
                        {
                            if ( _sep == "-" ) { 
                                _string=_string""_sta"-"_end"," }
                                else {
                                    _string=_string""_sta"," }
                            _sep="," ;
                            _sta=$2 ;
                            _end=$2 ;
                        }
                    }
                }

                END { if ( $2 == _end + 1 ) {
                        _sep="-" ;
                        _end=$2 }
                        else
                        {
                            if ( _sep == "-" ) { 
                                _string=_string""_sta"-"_end }
                                else {
                                    _string=_string""_sta }
                            _sep="," ;
                            _sta=$2 ;
                            _end=$2 ;
                        }
                        print _string"]" }' )","
        done

        echo "$_node_range" | sed 's/\,$//'
}

node_group_old()
{       
	#### DEPRECATED - IF NEW ONE WORKS FINE - DELETE THIS FUNCTION

        echo "${1}" | sed -e 's/^ *//' -e 's/ *$//' | tr ' ' '\n' | sed 's/[0-9]*$/;&/' | sort -t\; -k2,2n -u | awk -F\; '
                { if ( NR == "1" ) { _sta=$2 ; _end=$2  ; _string=$1"[" }
                else {
                    if ( $2 == _end + 1 ) {
                        _sep="-" ;
                        _end=$2 }
                        else
                        {
                            if ( _sep == "-" ) { 
                                _string=_string""_sta"-"_end"," }
                                else {
                                    _string=_string""_sta"," }
                            _sep="," ;
                            _sta=$2 ;
                            _end=$2 ;
                        }
                    }
                }

                END { if ( $2 == _end + 1 ) {
                        _sep="-" ;
                        _end=$2 }
                        else
                        {
                            if ( _sep == "-" ) { 
                                _string=_string""_sta"-"_end }
                                else {
                                    _string=_string""_sta }
                            _sep="," ;
                            _sta=$2 ;
                            _end=$2 ;
                        }
                        print _string"]" }'

 
}

extract_static_data()
{

	# GENERATE HOST CYCLOPS DATA AND HOST STATIC SETTINGS DATA FILES 

	for _host_data in $( awk -F\; '$7 == "up" { print $0 }' $_type )
	do
		_host_name=$( echo $_host_data | cut -d';' -f2 )
		_host_file=$( echo $_host_name | tr '[:upper:]' '[:lower:]' )
		_host_type=$( echo $_host_data | cut -d';' -f3 )
		_host_group=$( echo $_host_data | cut -d';' -f4 )
		_host_os=$( echo $_host_data | cut -d';' -f5 )
		_host_pwr=$( echo $_host_data | cut -d';' -f6 )
		_host_mng_state=$( echo $_host_data | cut -d';' -f7 )

		# HOST HEADER

		echo "host name;host type;host group;host os;host mng status;last update" > $_audit_data_path/$_host_file.header.txt
		echo $_host_name";"$_host_type";"$_host_group";"$_host_os";"$_host_mng_state";"$( date +%Y-%m-%d\ %H:%M:%S )  >> $_audit_data_path/$_host_file.header.txt

		# HOST SETTINGS

		ext_static_data_thread &
	done
	wait

}

ext_static_data_thread()
{

		cat $( find $_audit_scripts_path/$_host_os/ -name "*.sh" | grep -v template ) > $_cyclops_temp_path/$_host_file.audit.temp.sh
                [ -f $_cyclops_temp_path/$_host_file.audit.temp.sh ] && chmod 755 $_cyclops_temp_path/$_host_file.audit.temp.sh

                _output_settings=$( ssh -o ConnectTimeout=12 -o StrictHostKeyChecking=no $_host_name  "bash -s" < $_cyclops_temp_path/$_host_file".audit.temp.sh" )
                _ssh_err=$?

                if [ "$_ssh_err" -eq 0 ]
                then
                        echo "${_output_settings}" > $_audit_data_path/$_host_file.settings.txt
                fi

}

read_data()
{

	# SHOW HOST DATA FILTER OR NOT # UNDER FACTORING

	if [ "$_par_filter" == "main" ]
	then
		_par_node=$_par_filter
		_host_node=$_par_node
		_host_file=$( echo $_host_node | tr '[:upper:]' '[:lower:]' )

		_host_data=$_audit_data_path"/"$_host_file

		show_data
	else
		if [ -z "$_par_node" ]
		then
			_long=$( cat $_type | awk -F\; '$1 ~ "[0-9]" { print $2 }' )	
			[ "$_par_show" == "eventlog" ] && _long=$_long"\nmain"
		fi

		_count=0

		for _host_node in $( echo -e "${_long}" )
		do

			_host_file=$( echo $_host_node | tr '[:upper:]' '[:lower:]' )
			_host_data=$_audit_data_path"/"$_host_file
			if [ "$_par_show" == "wiki" ] 
			then
				show_data &
			else
				show_data
			fi
	
			if [ "$_par_show" == "wiki" ]
			then
				let _count++ 
				[ "$_count" -ge "$_server_proc" ] && _count=0 && sleep $_par_wait_time 
			fi
		done
	fi



}

generate_wiki_view()
{

	## PRE-PROCESSING

	#- GRAPHS INFO

	#_node_gyear=$( date +%Y )
	_node_gyear=$( date -d "last year" +%Y-%m-%d )
	_node_gbegin=$( date +%s )
	_node_gdays=10
	_node_gbegin=$( echo "" | awk -v _dt="$_node_gdays" -v _dn="$_node_gbegin" '{ _dt=_dt*24*60*60 ; _db=_dn-_dt ; print strftime("%Y-%m-%d",_db) }')

	_node_graph_global=$( $_stat_extr_path/stats.cyclops.audit.totals.sh -b $_node_gyear -v wiki -g month -n $_host_name ) 
	_node_graph_mngt=$( $_stat_extr_path/stats.cyclops.audit.totals.sh -b $_node_gbegin -v wiki -w Tbar -e mngt -g day -n $_host_name )
	_node_graph_alerts=$( $_stat_extr_path/stats.cyclops.audit.totals.sh -b $_node_gbegin -v wiki -w W700 -e alerts -g day -n $_host_name )
	_node_graph_issues=$( $_stat_extr_path/stats.cyclops.audit.totals.sh -b $_node_gbegin -v wiki -w W700 -e issues -g day -n $_host_name )

	unset _node_graph_sensors

	for _graph_sens_line in $( awk -F\; -v _fam="$_host_type" '$1 == _fam { print $3";"$4";"$5 }' $_stat_sensor_cfg_file )
	do
		_node_sens_name=$( echo $_graph_sens_line | cut -d';' -f1 )
		_node_sens_proc=$( echo $_graph_sens_line | cut -d';' -f2 )
		_node_sens_grap=$( echo $_graph_sens_line | cut -d';' -f3 )

		_node_graph_sensors=$_node_graph_sensors"\n"$( $_stat_extr_path/stats.cyclops.logs.sh -v wiki -d report -n $_host_name -t $_node_sens_proc -r $_node_sens_name -w hidden,T$_node_sens_grap )
	done

	#- SETTINGS INFO

	_output_settings=$( echo "${_output_settings}" | sort -t\; -k1,1n -k2,2 -k3,3n | cut -d';' -f3- | awk -F\; -v _tcolor="$_color_title" '
	BEGIN { 
		OFS=";" ; 
		_header="none" ; 
		_flevel="none" 
	} {
		if ( _header == $2 )
			{ if ( _flevel == $3 )
				{ _line="|  :::" ; 
				for (i=4;i<=NF;i++) 
					{ _line=_line"  |  "$i } 
				}
			else
				{ _flevel=$3;
				_line="|  "_tcolor" "$3 ; 
				for (i=4;i<=NF;i++) 
					{ _line=_line"  |  "$i } 
				}
			}
		else
			{ _header=$2 ; _flevel=$3 ; 
				if ( NR != 1 ) 
					{ print "</hidden>" } ; 
			 print "<hidden "_header" >" ; print "|< 100% 20% >|" ; 
			_line="|  "_tcolor" "$3 ; 
			for (i=4;i<=NF;i++) 
				{ _line=_line"  |  "$i } 
			}
		print _line"  |" ; _line="" 
	} END { 
		print "</hidden>" 
	}' )

	#- ACTIVITY INFO
	
	_output_activity=$( echo "${_output_activity}" | awk -F\; '$1 ~ "^[0-9]" { 
		_date=strftime("%Y;%m %b;%d %a;%H:%M:%S",$1) ; 
		split(_date,d,";") ; 
		if ( _doy != d[1] ) { _doy=d[1] ; _pdoy=_doy } else { _pdoy=":::" } ; 
		if ( _dom != d[2] ) { _dom=d[2] ; _pdom=_dom } else { _pdom=":::" } ; 
		if ( _dod != d[3] ) { _dod=d[3] ; _pdod=_dod } else { _pdod=":::" } ; 
		print _pdoy";"_pdom";"_pdod";"d[4]";"$4";"$5";"$6 
		} ' )
	_output_activity=$( echo "${_output_activity}" | sed -e "s/OK/$_color_ok &/" -e "s/UP/$_color_up &/" -e "s/DOWN/$_color_down &/" -e "s/FAIL/$_color_fail &/" -e "s/DRAIN/$_color_disable &/" -e "s/CONTENT/$_color_unknown &/" ) 
	_output_activity=$( echo "${_output_activity}" | sed -e "s/ALERT/$_color_fail &/g" -e "s/INFO/$_color_up &/g" -e "s/REPAIR/$_color_mark &/" -e  "s/DIAGNOSE/$_color_check &/g" -e "s/STATUS/$_color_up &/g" -e "s/SOLVED/$_color_ok &/g" )
	_output_activity=$( echo "${_output_activity}" | sed -e "s/UNLINK/$_color_mark &/" -e "s/LINK/$_color_mark &/" -e "s/REACTIVE/$_color_rzr &/" -e "s/CONTENT/$_color_down &/" )
	_output_activity=$( echo "${_output_activity}" | sed -e 's/^/|  /' -e 's/$/  |/' -e 's/;/  |  /g' )

	#- BITACORA INFO

	if [ ! -z "$_output_bitacora" ]
	then
		_output_bitacora=$( echo "${_output_bitacora}" | awk -F\; '$1 ~ "^[0-9]" { 
			_date=strftime("%Y;%m %b;%d %a;%H:%M:%S",$1) ; 
			split(_date,d,";") ; 
			if ( _doy != d[1] ) { _doy=d[1] ; _pdoy=_doy } else { _pdoy=":::" } ; 
			if ( _dom != d[2] ) { _dom=d[2] ; _pdom=_dom } else { _pdom=":::" } ; 
			if ( _dod != d[3] ) { _dod=d[3] ; _pdod=_dod } else { _pdod=":::" } ; 
			print _pdoy";"_pdom";"_pdod";"d[4]";"$4";"$5";"$6 
			} ' )
		_output_bitacora=$( echo "${_output_bitacora}" | sed -e "s/OK/$_color_ok &/" -e "s/UP/$_color_up &/" -e "s/DOWN/$_color_down &/" -e "s/FAIL/$_color_fail &/" -e "s/DRAIN/$_color_disable &/" -e "s/CONTENT/$_color_unknown &/" -e "s/ISSUE/$_color_fail &/"  )
		_output_bitacora=$( echo "${_output_bitacora}" | sed -e "s/ALERT/$_color_fail &/g" -e "s/INFO/$_color_up &/g" -e "s/REPAIR/$_color_mark &/" -e  "s/DIAGNOSE/$_color_check &/g" -e "s/STATUS/$_color_disable &/g" -e "s/SOLVED/$_color_ok &/g" )
		_output_bitacora=$( echo "${_output_bitacora}" | sed -e 's/^/|  /' -e 's/$/  |/' -e 's/;/  |  /g' )
	fi

	## FORMATING

	echo "====== NODE INFO ======"

	echo "|< 100% 20% 16% 16% 16% 16% 16% >|"
	echo "|  $_color_title {{ :wiki:cyclops_title.png |}}  ||||||"	
	echo "|  $_color_header HOST NAME  |  $_color_header TYPE  |  $_color_header GROUP  |  $_color_header OS  |  $_color_header MNG STATUS  |  $_color_header LAST UPDATE  |"
	echo "|  $_host_name               |  $_host_type          |  $_host_group          |  $_host_os          |  $_host_mng_state           |  $_host_last_upd             |"
	echo 

	echo "|< 100% >|"
	echo "|  $_color_header $_host_name Year $_node_gyear events  |"
	echo "|  ${_node_graph_global}  |"
	echo

	echo "<hidden Global Graphs>"
	echo "|< 100% 50% 50% >|"
	echo "|  $_color_header Management Activity Last $_node_gdays  ||"
	echo "|  ${_node_graph_mngt}  ||"
	echo "|  $_color_header Alerts Activity Last $_node_gdays  |  $_color_header Incident Activity Last $_node_gdays  |"
	echo "|  ${_node_graph_alerts}  |  ${_node_graph_issues}  |"
	echo "</hidden>"

	echo "<hidden Sensors Graphs>"
	echo -e "${_node_graph_sensors}"
	echo "</hidden>"

	echo "<hidden HOST SETTINGS>"
	echo "${_output_settings}"
	echo "</hidden>"
	echo

	echo "<hidden HOST ACTIVITY>"
	echo "|< 100% 10% 10% 10% 10% 10% 40% 10% >|"
	echo "|  $_color_header YEAR  |  $_color_header MONTH  |  $_color_header DAY  |  $_color_header HOUR  |  $_color_header EVENT  |  $_color_header  ACTIVITY  |  $_color_header  STATUS  |"
	echo "${_output_activity}"
	echo "</hidden>"
	echo 

	echo "<hidden HOST BITACORA>"
	echo "|< 100% 10% 10% 10% 10% 10% 40% 10% >|"
	echo "|  $_color_header YEAR  |  $_color_header MONTH  |  $_color_header DAY  |  $_color_header HOUR  |  $_color_header EVENT  |  $_color_header  ACTIVITY  |  $_color_header  STATUS  |"
        echo "${_output_bitacora}"
	echo "</hidden>"
	echo
	
}

generate_wiki_index()
{
	
	_date_now=$( date +%s )
	_date_year=$( date +%Y )
	_date_start_analisys=$_date_year
	#_date_start_analisys=$( echo $_date_now | awk '{ print strftime("%Y-%m-%d",$1-31536000) }' )

	generate_wiki_index_header

	echo "====== GROUP DETAILED AUDIT ======"

	for _host_type in $( cat $_type | cut -d';' -f4 | sort -u )
	do

		_host_wiki_count=0	
		_host_wiki_group="|  "
		_ctrl_new_line=0
		_host_list=""
	
		for _host_wiki in $( awk -F\; -v _type="$_host_type" '$4 == _type { print $2 }' $_type  )
		do

			if [ -f $_audit_wiki_path/$_host_wiki.audit.txt ] 
			then
				[ "$_ctrl_new_line" -eq 9 ] && _new_line="  |\n|  " || _new_line="  |  " 
				[ "$_ctrl_new_line" -eq 9 ] && _ctrl_new_line=0 || let "_ctrl_new_line++"
				_check_days=10
				[ -f $_audit_data_path/$_host_wiki".activity.txt" ] && _check_file=$( cat $_audit_data_path/$_host_wiki".activity.txt" | awk -F\; -v _dt="$_check_days" -v _dn="$_date_now" -v _cf="$_color_check" -v _cu="$_color_up" 'BEGIN { _dt=_dt*24*60*60 ; _db=_dn-_dt ; _status=_cu } $1 > _db && $4 ~ "ALERT" { _status=_cf } END { print _status }' ) || _check_file=$_color_disable

				_host_wiki_group=$_host_wiki_group" "$_check_file" <fc white> [[ .:$_host_wiki.audit|$_host_wiki ]] </fc> "$_new_line
				let "_host_wiki_count++"
				_host_list=$_host_list""$_host_wiki" "
			fi
		done
		
		if [ "$_host_wiki_count" -ne 0 ]
		then	
			#### PROCESING DATA ####

			_host_list=$( node_group $_host_list )
			_graph_days=20
			#_graph_year=$_date_year ### TRY NEW DATE--- BASED 12 MONTHs
			_graph_year=$_date_start_analisys
			_graph_begin=$_date_now
			_graph_begin=$( echo "" | awk -v _dt="$_graph_days" -v _dn="$_graph_begin" '{ _dt=_dt*24*60*60 ; _db=_dn-_dt ; print strftime("%Y-%m-%d",_db) }')

			#### AUDIT GRAPHS --

			_family_graph=$( $_stat_extr_path/stats.cyclops.audit.totals.sh -c -b $_graph_year -v wiki -g month -n $_host_list ) 
			_family_gmngt=$( $_stat_extr_path/stats.cyclops.audit.totals.sh -c -b $_graph_year -v wiki -w Tbar -e mngt -g month -n $_host_list )
			_family_galert=$( $_stat_extr_path/stats.cyclops.audit.totals.sh -c -b $_graph_year -v wiki -w W700 -e alerts -g month -n $_host_list ) 
			_family_issue=$( $_stat_extr_path/stats.cyclops.audit.totals.sh -b $_graph_year -v wiki -w W700 -e issues -g month -n $_host_list )
			_mngt_graph=$(  $_stat_extr_path/stats.cyclops.audit.totals.sh -b $_graph_begin -v wiki -w Tbar -e mngt -g day -n $_host_list ) 
			_alert_graph=$( $_stat_extr_path/stats.cyclops.audit.totals.sh -b $_graph_begin -v wiki -w W700 -e alerts -g day -n $_host_list )  
			_issue_graph=$( $_stat_extr_path/stats.cyclops.audit.totals.sh -b $_graph_begin -v wiki -w W700 -e issues -g day -n $_host_list ) 

			#### TABLE DATA --

			_table_events_p=$( $_stat_extr_path/stats.cyclops.audit.totals.sh -c -b $_graph_year -v commas -g month -n $_host_list | awk -F\; 'NR > 4 && $0 != "END OF FILE" { d[$1]=$2 } END { for ( i in d ) { _b=_b""d[i]";" } print ";"_b }' ) 
			_table_gmngt_p=$( $_stat_extr_path/stats.cyclops.audit.totals.sh -c -b $_graph_year -v commas -e mngt -g month -n $_host_list | awk -F\; 'NR > 4 && $0 != "END OF FILE" { d[$1]=$2 } END { for ( i in d ) { _b=_b""d[i]";" } print ";"_b }' ) 
			_table_galert_p=$( $_stat_extr_path/stats.cyclops.audit.totals.sh -c -b $_graph_year -v commas -e alerts -g month -n $_host_list | awk -F\; 'NR > 4 && $0 != "END OF FILE" { d[$1]=$2 } END { for ( i in d ) { _b=_b""d[i]";" } print ";"_b }') 
			_table_issue_p=$( $_stat_extr_path/stats.cyclops.audit.totals.sh -b $_graph_year -v commas -e issues -g month -n $_host_list | awk -F\; 'NR > 4 && $0 != "END OF FILE" { d[$1]=$2 } END { for ( i in d ) { _b=_b""d[i]";" } print ";"_b }' )

			_table_events=$_table_events""$_host_type""$_table_events_p"\n"
			_table_mngts=$_table_mngts""$_host_type""$_table_gmngt_p"\n"
			_table_alerts=$_table_alerts""$_host_type""$_table_galert_p"\n"
			_table_issues=$_table_issues""$_host_type""$_table_issue_p"\n"

			#### RISK ANALISYS --

			_risk_week_day=$( $_script_path/audit.nod.sh -v commas -f activity -n $_host_list | awk -F\; -v _date="$_graph_year" '$1 ~ _date && $5 == "ALERT" { split($1,d,"-") ; _ts=mktime( d[1]" "d[2]" "d[3]" 0 0 1" ) ; _nday=strftime("%u",_ts) ; _dday=strftime("%a",_ts) ; a[_nday";"_dday]++ ; _t++ } END { for( i in a ) { print i";"(a[i]*100)/_t }}' | sort -n | cut -d';' -f2- )
			_risk_month_day=$( $_script_path/audit.nod.sh -v commas -f activity -n $_host_list | awk -F\; -v _date="$_graph_year" '$1 ~ _date && $5 == "ALERT" { split($1,h,"-") ; a[h[3]]++ ; _t++ } END { for( i in a ) { print i";"(a[i]*100)/_t }}' | sort -n )
			_risk_hour=$( $_script_path/audit.nod.sh -v commas -f activity -n $_host_list | awk -F\; -v _date="$_graph_year" '$1 ~ _date && $5 == "ALERT" { split($2,h,":") ; a[h[1]]++ ; _t++ } END { for( i in a ) { print i";"(a[i]*100)/_t }}' | sort -n )
			_risk_node=$( $_script_path/audit.nod.sh -v commas -f activity -n $_host_list | awk -F\; -v _date="$_graph_year" '$1 ~ _date && $5 == "ALERT" { a[$1";"$4]++ } END { for( i in a ) { print i";"a[i] }}' | awk -F\; '{ sum[$2]+=$3 ; sumsq[$2]+=$3*$3 ; lin[$2]++ } END { for ( i in sum ) { _mda+=sqrt(sumsq[i]/lin[i] - (sum[i]/lin[i])*(sum[i]/lin[i])) ; _mdt++ } ; _md=_mda/_mdt; for ( i in sum ) { _des=sqrt(sumsq[i]/lin[i] - (sum[i]/lin[i])*(sum[i]/lin[i])) ; if ( _des >  _md ) { print i";"_des } }}' | sort -t\; -k2,2nr )  # STANDARD DEVIATION, NODES WITH  MORE AVERAGE DEVIA... 
			_risk_sensor=$( $_script_path/audit.nod.sh -v commas -f activity -n $_host_list | awk -F\; -v _date="$_graph_year" '$1 ~ _date && $5 == "ALERT" { a[$1";"$6]++ } END { for( i in a ) { print i";"a[i] }}' | awk -F\; '{ sum[$2]+=$3 ; sumsq[$2]+=$3*$3 ; lin[$2]++ } END { for ( i in sum ) { print i";"sqrt(sumsq[i]/lin[i] - (sum[i]/lin[i])*(sum[i]/lin[i])) }}' | sort -t\; -k2,2nr ) # STANDARD DEVIATION ALERT SENSORS.

			#### PRINT SUB-PAGES ####

			print_wiki_section >$_audit_wiki_path/$_host_type".txt"

		fi

	done			

	#### PROCESSING MAIN INDEX DETAILS ####

	#### GROUPS DETAILs --

	_table_dates=$( $_stat_extr_path/stats.cyclops.audit.totals.sh -c -b $_graph_year -v commas -e mngt -g month -n $_host_list | grep ^[0-9][0-9][0-9][0-9] | cut -d';' -f1 | tr '\n' ';' | sed -e 's/^/;/' -e 's/$/\n/' ) 

	_table_event_mark=$( echo -e "${_table_events}" | sed -e 's/;$//' | cut -d';' -f2- | awk -F\; 'BEGIN { OFS=";" } { for ( i=1 ; i<=NF ; i++ ) { if ( m[i] <= $i ) { m[i]=$i ; p[i]=NR }}} END { print "" ; for ( a in p ) { print a"."p[a] }}' | sort -n | cut -d'.' -f2 | tr '\n' '.'  )

	_table_mngt_mark=$( echo -e "${_table_mngts}" | sed -e 's/;$//' | cut -d';' -f2- | awk -F\; 'BEGIN { OFS=";" } { for ( i=1 ; i<=NF ; i++ ) { if ( m[i] <= $i ) { m[i]=$i ; p[i]=NR }}} END { print "" ; for ( a in p ) { print a"."p[a] }}' | sort -n | cut -d'.' -f2 | tr '\n' '.'  )
	_table_alert_mark=$( echo -e "${_table_alerts}" | sed -e 's/;$//' | cut -d';' -f2- | awk -F\; 'BEGIN { OFS=";" } { for ( i=1 ; i<=NF ; i++ ) { if ( m[i] <= $i ) { m[i]=$i ; p[i]=NR }}} END { print "" ; for ( a in p ) { print a"."p[a] }}' | sort -n | cut -d'.' -f2 | tr '\n' '.'  )
	_table_issue_mark=$( echo -e "${_table_issues}" | sed -e 's/;$//' | cut -d';' -f2- | awk -F\; 'BEGIN { OFS=";" } { for ( i=1 ; i<=NF ; i++ ) { if ( m[i] <= $i ) { m[i]=$i ; p[i]=NR }}} END { print "" ; for ( a in p ) { print a"."p[a] }}' | sort -n | cut -d'.' -f2 | tr '\n' '.'  )

	#### RISK ANALISYS --

	_risk_week_day=$( $_script_path/audit.nod.sh -v commas -f activity | awk -F\;  -v _date="$_graph_year" '$1 ~ _date && $5 == "ALERT" { split($1,d,"-") ; _ts=mktime( d[1]" "d[2]" "d[3]" 0 0 1" ) ; _nday=strftime("%u",_ts) ; _dday=strftime("%a",_ts) ; a[_nday";"_dday]++ ; _t++ } END { for( i in a ) { print i";"(a[i]*100)/_t }}' | sort -n | cut -d';' -f2- ) 
	_risk_month_day=$( $_script_path/audit.nod.sh -v commas -f activity | awk -F\;  -v _date="$_graph_year" '$1 ~ _date && $5 == "ALERT" { split($1,h,"-") ; a[h[3]]++ ; _t++ } END { for( i in a ) { print i";"(a[i]*100)/_t }}' | sort -n ) 
	_risk_hour=$( $_script_path/audit.nod.sh -v commas -f activity | awk -F\;  -v _date="$_graph_year" '$1 ~ _date && $5 == "ALERT" { split($2,h,":") ; a[h[1]]++ ; _t++ } END { for( i in a ) { print i";"(a[i]*100)/_t }}' | sort -n ) 
	_risk_node=$( $_script_path/audit.nod.sh -v commas -f activity | awk -F\;  -v _date="$_graph_year" '$1 ~ _date && $5 == "ALERT" { a[$1";"$4]++ } END { for( i in a ) { print i";"a[i] }}' | awk -F\; '{ sum[$2]+=$3 ; sumsq[$2]+=$3*$3 ; lin[$2]++ } END { for ( i in sum ) { _mda+=sqrt(sumsq[i]/lin[i] - (sum[i]/lin[i])*(sum[i]/lin[i])) ; _mdt++ } ; _md=_mda/_mdt; for ( i in sum ) { _des=sqrt(sumsq[i]/lin[i] - (sum[i]/lin[i])*(sum[i]/lin[i])) ; if ( _des >  _md ) { print i";"_des } }}' | sort -t\; -k2,2nr )  # STANDARD DEVIATION, NODES WITH MORE AVERAGE DEVIA
	_risk_sensor=$( $_script_path/audit.nod.sh -v commas -f activity | awk -F\;  -v _date="$_graph_year" '$1 ~ _date && $5 == "ALERT" { a[$1";"$6]++ } END { for( i in a ) { print i";"a[i] }}' | awk -F\; '{ sum[$2]+=$3 ; sumsq[$2]+=$3*$3 ; lin[$2]++ } END { for ( i in sum ) { print i";"sqrt(sumsq[i]/lin[i] - (sum[i]/lin[i])*(sum[i]/lin[i])) }}' | sort -t\; -k2,2nr ) # STANDARD DEVIATION ALERT SENSORS.

	#_risk_node=$( $_script_path/audit.nod.sh -v commas -f activity | awk -F\; '$5 == "ALERT" { a[$4]++ ; _t++ } END { for( i in a ) { print i";"(a[i]*100)/_t}}' | sort -t\; -k2,2nr | head -n 20 )  # 20 MOST PERCENT ALERTS EVENT NODES
	#_risk_sensor=$( $_script_path/audit.nod.sh -v commas -f activity | awk -F\; '$5 == "ALERT" { a[$6]++ ; _t++ } END { for( i in a ) { print i";"(a[i]*100)/_t }}' | sort -t\; -k2,2nr | head -n 20 ) # SORT PERCENT ALERT SENSORSs 

	#### PRINT MAIN PAGE SECTION DETAILS ####

	echo "===== EVENT DATA ====="
	echo
	echo "  * All event data are referenciated per node, for comparative reasons betwen different groups"
	echo
	echo "|< 100% 15%>|"
	echo $_table_dates | sed -e "s/^/|  $_color_graph <fc white> ALL EVENTs <\/fc>/" -e 's/;$/  |/' -e "s/;/  |  $_color_header  /g" 
	#echo -e "${_table_events}" | awk -F\; -v _c="$_color_header" 'BEGIN { OFS="  |  "} { $1=_c" ** [[.:"$1"|"$1"]] **" ; print "|  "$0 }' 
	echo -e "${_table_events}" | awk -F\; -v _c="$_color_header" -v _ia="$_table_event_mark" -v _cm="$_color_graph" 'BEGIN { OFS="  |  " ; split(_ia,x,".") } { $1=_c" ** [[.:"$1"|"$1"]] **" ; for ( i=2 ; i<=NF ; i++ ) { if ( x[i] == NR ) { $i=_cm" <fc white>"$i"</fc>" }} ; print "|  "$0 }' 
	echo

	echo "===== MANAGEMENT DATA ====="
	echo
	echo "  * This events are register when human activity is detected"
	echo "  * This information is referenciated per node, for compartive reasons"
	echo
	echo "|< 100% 15% >|"
	echo $_table_dates | sed -e "s/^/|  $_color_ok MNGT EVENTs /" -e 's/;$/  |/' -e "s/;/  |  $_color_header  /g" 
	echo -e "${_table_mngts}" | awk -F\; -v _c="$_color_header" -v _ia="$_table_mngt_mark" -v _cm="$_color_ok" 'BEGIN { OFS="  |  " ; split(_ia,x,".") } { $1=_c" ** [[.:"$1"|"$1"]] **" ; for ( i=2 ; i<=NF ; i++ ) { if ( x[i] == NR ) { $i=_cm" "$i }} ; print "|  "$0 }' 
	echo

	echo "===== ALERT DATA ====="
	echo
	echo "  * This data are generated when cyclops detect alert in a sensor or administrator register a manual alert"
	echo "  * This information is referenciated per node, for compartive reason"
	echo
	echo "|< 100% 15% >|"
	echo $_table_dates | sed -e "s/^/|  $_color_fail ALERT EVENTs/" -e 's/;$/  |/' -e "s/;/  |  $_color_header  /g" 
	echo -e "${_table_alerts}" | awk -F\; -v _c="$_color_header" -v _ia="$_table_alert_mark" -v _cm="$_color_fail" 'BEGIN { OFS="  |  " ; split(_ia,x,".") } { $1=_c" ** [[.:"$1"|"$1"]] **" ; for ( i=2 ; i<=NF ; i++ ) { if ( x[i] == NR ) { $i=_cm" "$i }} ; print "|  "$0 }' 
	echo

	echo "===== ISSUE DATA ====="
	echo
	echo "  * This data are filter for issue cyclops register type (commonly manual register)"
	echo "  * Show the relevants incidents in the system" 
	echo "  * This information ** NOT ** referenciated per node"
	echo
	echo "|< 100% 15% >|"
	echo $_table_dates | sed -e "s/^/|  $_color_down <fc white>ISSUE EVENTs<\/fc>/" -e 's/;$/  |/' -e "s/;/  |  $_color_header  /g" 
	echo -e "${_table_issues}" | awk -F\; -v _c="$_color_header" -v _ia="$_table_issue_mark" -v _cm="$_color_down" 'BEGIN { OFS="  |  " ; split(_ia,x,".") } { $1=_c" ** [[.:"$1"|"$1"]] **" ; for ( i=2 ; i<=NF ; i++ ) { if ( x[i] == NR ) { $i=_cm" <fc white>"$i"</fc>" }} ; print "|  "$0 }' 
	echo

	echo "====== RISK ANALISYS ======"
	echo
	echo "  * This information are little gauge to knows resources or moments with more or less risk in the system could be in troubles"
	echo
	echo "|< 100% >|"
	echo "|  $_color_header ** RISK ANALISYS CYC GAUGEs - $_graph_year DATE FILTER **  ||"
	echo "|  $_color_title MONTH DAY (%)  ||"
	echo "|  <gchart 850x350 bar #0040FF #ffffff center>" ; echo "${_risk_month_day}" | sed 's/;/=/' ; echo "</gchart>  ||"
	echo "|  $_color_title WEEK DAY (%)  |  $_color_title HOUR (%)  |"
	echo "|  <gchart 700x350 bar #F7BE81 #ffffff center>" ; echo "${_risk_week_day}"  | sed 's/;/=/' ; echo "</gchart>  |  <gchart 700x350 bar #FA5856 #ffffff center>" ; echo "${_risk_hour}" | sed 's/;/=/' ; echo "</gchart>  |"
	echo "|  ||"
	echo "|  $_color_title TOP RISK NODES (STANDARD DEVIATION (SD) - ONLY TOP 20 AVERAGE DEVIATION NODES)  |  $_color_title TOP RISK SENSORS (STANDARD DEVIATION)  |"
	echo "|  <gchart 700x350 hbar #FA5858 #ffffff value center>" ; echo "${_risk_node}" | sed 's/;/=/' | head -n 30 ; echo "</gchart>  |  <gchart 700x350 hbar #F7BE81 #ffffff value center>" ; echo "${_risk_sensor}" | sed 's/;/=/' ; echo "</gchart>  |"
	echo

	echo "====== MAIN BITACORA TIMELINE ======"
	echo
	echo "  * We are working on timeline plugin to get best interface experience with this information, until finish you see the list of events"
	echo "<hidden MAIN BITACORA EVENTS $_global_graph_date>"
        echo "${_global_main_bit}"
        echo "</hidden>"

}

print_wiki_section()
{

	echo "===== GROUP: $_host_type ====="

	echo "==== GRAPHS ===="

	echo "|< 100% >|"
	echo "|  $_color_header ** $_host_type - Audit Events - Events per Node - $_host_wiki_count Nodes **  |"
	echo "|  $_family_graph  |"
	echo "<hidden Audit Detailed Graphs - Current Year $_graph_year >"
	echo "|< 100% 50% 50% >|"
	echo "|  $_color_header  Management Activity - Per Node ($_host_wiki_count N)  ||"
	echo "|  $_family_gmngt  ||"
	echo "|  $_color_header Alerts Activity - Per Node ($_host_wiki_count N)  |  $_color_header Issues Activity  |"
	echo "|  $_family_galert  |  $_family_issue  |"
	echo "</hidden>"
	echo "<hidden Audit Detailed Graphs - Last $_graph_days days>"
	echo "|< 100% 50% 50% >|"
	echo "|  $_color_header  Management Activity  - Last $_graph_days days  ||"
	echo "|  ${_mngt_graph}  ||"
	echo "|  $_color_header  Alerts Activity  |  $_color_header  Issues Activity  |"
	echo "|  ${_alert_graph}  |  ${_issue_graph}  |"
	echo "</hidden>"

	echo "==== DATA ===="
	echo 
	echo "  * ** Audit Node Detailed Info: **If node has had an alert event in last $_check_days days it is mark" 
	echo 
	echo "|< 100% 10% 10% 10% 10% 10% 10% 10% 10% 10% 10% >|"
	echo -e "$_host_wiki_group"
	echo

	echo "==== RISK ANALISYS ===="
	echo
        echo "  * This information are little gauge to knows resources or moments with more or less risk in the system could be in troubles"
        echo
        echo "|< 100% >|"
        echo "|  $_color_header ** RISK ANALISYS CYC GAUGEs - $_host_type - $_graph_year DATE FILTER **  ||"
        echo "|  $_color_title MONTH DAY (%)  ||"
        echo "|  <gchart 850x350 bar #0040FF #ffffff center>" ; echo "${_risk_month_day}" | sed 's/;/=/' ; echo "</gchart>  ||"
        echo "|  $_color_title WEEK DAY (%)  |  $_color_title HOUR (%)  |"
        echo "|  <gchart 700x350 bar #F7BE81 #ffffff center>" ; echo "${_risk_week_day}"  | sed 's/;/=/' ; echo "</gchart>  |  <gchart 700x350 bar #FA5856 #ffffff center>" ; echo "${_risk_hour}" | sed 's/;/=/' ; echo "</gchart>  |"
        echo "|  ||"
        echo "|  $_color_title TOP RISK NODES (STANDARD DEVIATION (SD) - ONLY TOP 20 DEVIATION AVERAGE NODES)  |  $_color_title TOP RISK SENSORS (STANDARD DEVIATION)  |"
        echo "|  <gchart 700x350 hbar #FA5858 #ffffff value center>" ; echo "${_risk_node}" | sed 's/;/=/' | head -n 30 ; echo "</gchart>  |  <gchart 700x350 hbar #F7BE81 #ffffff value center>" ; echo "${_risk_sensor}" | sed 's/;/=/' ; echo "</gchart>  |"
        echo

}

generate_wiki_index_header()
{

	#_global_graph_date=$( date +%Y )
	_global_graph_date=$_date_start_analisys
	_global_graph=$( $_stat_extr_path/stats.cyclops.audit.totals.sh -b $_global_graph_date -v wiki -g month )
	_global_graph_mngt=$( $_stat_extr_path/stats.cyclops.audit.totals.sh -b $_global_graph_date -e mngt -w Tbar -v wiki -g month )
	_global_graph_alerts=$( $_stat_extr_path/stats.cyclops.audit.totals.sh -b $_global_graph_date -e alerts -v wiki -g month )
	_global_graph_issues=$( $_stat_extr_path/stats.cyclops.audit.totals.sh -b $_global_graph_date -e issues -v wiki -g month )

	_global_main_bit=$( cat $_audit_data_path/main.bitacora.txt | awk -F\; -v _d="$_global_graph_date" 'BEGIN { OFS=";" } { $1=strftime("%Y-%m-%d;%H:%M:%S",$1) } $1 ~ "^"_d { print $1";"$3";"$4";"$5";"$6 }' ) 
	_global_main_bit=$( echo "${_global_main_bit}" | sed "1 i\ $_color_header date;$_color_header time;$_color_header source;$_color_header event;$_color_header message;$_color_header state" )
	_global_main_bit=$( echo "${_global_main_bit}" | sed -e "s/UP/$_color_up &/g" -e "s/OK/$_color_ok &/g" -e "s/FAIL/$_color_fail &/g" -e "s/DOWN/$_color_down &/g" -e "s/ALERT/$_color_fail &/g" -e "s/INFO/$_color_up &/g" )
	_global_main_bit=$( echo "${_global_main_bit}" | sed -e "s/DRAIN/$_color_disable &/g" -e "s/REPAIR/$_color_mark &/" -e  "s/DIAGNOSE/$_color_check &/g" -e "s/STATUS/$_color_disable &/g" -e "s/CONTENT/$_color_mark &/g" )
	_global_main_bit=$( echo "${_global_main_bit}" | sed -e "s/SOLVED/$_color_ok &/g" )
	_global_main_bit=$( echo "${_global_main_bit}" | sed -e "s/TESTING/$_color_check &/g" -e "s/UPGRADE/$_color_mark &/" -e "s/ENABLE/$_color_ok &/g" -e "s/INTERVENTION/$_color_mark &/g" -e "s/ISSUE/$_color_fail &/" )
	_global_main_bit=$( echo "${_global_main_bit}" | sed -e 's/^/|  /' -e 's/;/  |  /g' -e 's/$/  |/' )
	_global_main_bit=$( echo "${_global_main_bit}" | sed '1 i\|< 100% 10% 10% 10% 10% 50% 10%>|' )

	echo

	echo "====== CYCLOPS AUDIT SYSTEM ======"
	echo

	echo "|< 80% >|"
	echo "|  $_color_header  ** Global Audit Events Graph $_global_graph_date **  |"
	echo "|  ${_global_graph}  |"
	echo 

	echo "<hidden Global Audit Management Activity $_global_graph_date>"
	echo "|< 100% >|"
	echo "|  ${_global_graph_mngt}  |"
	echo "</hidden>"

	echo "<hidden Global Audit Alerts $_global_graph_date>"
	echo "|< 100% >|"
	echo "|  ${_global_graph_alerts}  |"
	echo "</hidden>"

	echo "<hidden Global Audit Incidents $_global_graph_date>"
	echo "|< 100% >|"
	echo "|  ${_global_graph_issues}  |"
	echo "</hidden>"

}

insert_event()
{

	### [DATE(UNIX)];[DEVICE(NOD|DEV|GEN)];[HOST|DEV NAME];[TYPE EVENT(ALERT|INFO|STATUS|...)];[MENSAGE TXT] ###

	case "$_par_insert" in
	event)
		echo "$( date +%s );$_audit_code_type;$_par_node;$_par_event;$_par_msg;$_par_stat" >> $_audit_data_path/$_par_node.activity.txt
	;;
	bitacora)
		echo "$( date +%s );$_audit_code_type;$_par_node;$_par_event;$_par_msg;$_par_stat" >> $_audit_data_path/$_par_node.bitacora.txt
	;;
	issue)

		echo
                echo "CYCLOPS AUDIT MODULE:"
		echo "Interactive Audit insert event method"
		echo
		echo "Please register the next fields for audit issue event"
		echo "Probably your activity have been monitoring"
		echo
		
		interactive_event
		
		echo -n "Are you sure? : "
		while read -r -n 1 -s _ask_ok
		do
			case "$_ask_ok" in 
			Y|y)
				[ -z $_ask_node ] && $_script_path/audit.nod.sh -i bitacora -e $_ask_event -s $_ask_state -m $_msg_insert || $_script_path/audit.nod.sh -i bitacora -e $_ask_event -s $_ask_state -n $_ask_node -m $_msg_insert
				if [ "$_ask_email" == "Y" ] || [ "$_ask_email" == "y" ]
				then
					$_script_path/cyclops.sh -p medium -m $_ask_node" : "$_msg_insert -l
				fi
				break
			;;
			N|n)
				echo
				interactive_event
				echo -n "Are you sure? : "
			;;
			esac
		done

		echo
		exit

	;;
	esac

}

interactive_event()
{
		unset _ask_event

		while [ "$_ask_event" != "ISSUE" ] && [ "$_ask_event" != "ALERT" ] && [ "$_ask_event" != "INFO" ] || [ "$_ask_state" == "help" ]
		do
			echo -n "Type of event (ISSUE|ALERT|INFO|help) : "
                	read _ask_event
			if [ "$_ask_event" != "ISSUE" ] && [ "$_ask_event" != "ALERT" ] && [ "$_ask_event" != "INFO" ] && [ "$_ask_event" != "help" ] 
			then
				echo "Please enter a valid state"
			fi
			
			if [ "$_ask_event" == "help" ]
			then
				echo "	ISSUE: Issue type event, something bad is happening"
				echo "	ALERT: Alert type event, you don't know exactly which is the problem but something is happening"
				echo "	INFO: Info event, you want to report about something"
			fi
		done

		unset _ask_node
		_real_node="none"

		while [ "$_ask_node" != "$_real_node" ]
		do
			echo -n "Node Name ( if blank generic event inserted ) : "
	                read _ask_node
			_real_node=$( cat $_type | awk -F\; -v _n="$_ask_node" '$2 == _n { print $2 }' ) 
			[ "$_ask_node" != "$_real_node" ] && echo "Please Enter a valid nodename"
		done

		_ask_procedure="blank"
		_real_procedure="none"

		while [ "$_ask_procedure" != "$_real_procedure" ] && [ ! -z "$_ask_procedure" ] || [ "$_ask_procedure" == "help" ]
		do
			echo -n "Which Procedure code will be executed? (write \"help\" for list all available procs) : "
                	read _ask_procedure
			_real_procedure=$( cat $_sensors_ia_codes_file | awk -F\; -v _p="$_ask_procedure" '$1 == _p { print $1 }' )
			[ "$_ask_procedure" == "$_real_procedure" ] && _ask_proc_des=$( cat $_sensors_ia_codes_file | awk -F\; -v _p="$_ask_procedure" '$1 == _p { print $2 }' ) 
			if [ "$_ask_procedure" != "$_real_procedure" ] && [ ! -z "$_ask_procedure" ] && [ "$_ask_procedure" != "help" ] 
			then
				echo "Please Enter Valid Procedure or blank if you dont have any" 
			fi

			[ "$_ask_procedure" == "help" ] && cat $_sensors_ia_codes_file | sed -e 's/;/ - /'
		done

		echo -n "Have issue code? (if yes put it else let blank) : " 
		read _ask_issue

		unset _ask_state

		while [ "$_ask_state" != "FAIL" ] && [ "$_ask_state" != "OK" ] && [ "$_ask_state" != "DOWN" ] && [ "$_ask_state" != "SOLVED" ] && [ "$_ask_state" != "UP" ] && [ "$_ask_state" != "INFO" ] || [ "$_ask_state" == "help" ]
		do
			echo -n "State of issue (FAIL/OK/DOWN/SOLVED/UP/INFO/help) : " 
			read _ask_state

			if [ "$_ask_state" != "FAIL" ] && [ "$_ask_state" != "OK" ] && [ "$_ask_state" != "DOWN" ] && [ "$_ask_state" != "SOLVED" ] && [ "$_ask_state" != "UP" ] && [ "$_ask_state" != "INFO" ] && [ "$_ask_state" != "help" ] 
			then
				echo "Please enter a valid state"
			fi
			
			if [ "$_ask_state" == "help" ]
			then
				echo "	FAIL: Fail event, some host/node or something is failing"
				echo "	DOWN: Host/node or something is down, not working at all"
				echo "	OK: Event info is ok, correct status"
				echo "	UP: Host/node or something is operative/functional"
				echo "	INFO: Event only wants to show info data"
				echo "	SOLVED: Event is linking to a issue that is solved"
			fi
		done

		unset _ask_msg
	
		while [ -z "$_ask_msg" ]
		do
			echo -n "Issue Message/Description : " 
			read _ask_msg

			[ -z "$_ask_msg" ] && echo "Please don't leave blank this field, put a descriptive message"
		done

		_ask_msg=$( echo "$_ask_msg" | tr '[:upper:]' '[:lower:]' | sed -e 's/\;/,/g'  )

		echo -n "Want to send informative mail (Y/N)? : "
                while read -r -n 1 -s _ask_email
		do
			case "$_ask_email" in
			Y|y|N|n)
				break
			;;
			esac
		done

		echo
		echo "Information to be insert in bitacora module:"
		echo "Event Type: $_ask_event"
                echo "Host/node name: $( [ -z "$_ask_node" ] && echo -n MAIN\ BITACORA || echo -n $_ask_node )"
                echo "Procedure code: $( [ -z "$_ask_procedure" ] && echo -n NONE || echo -n $_ask_procedure )"
                echo "Issue code: $( [ -z "$_ask_issue" ] && echo -n NONE || echo -n $_ask_issue )"
                echo "Event state: $_ask_state"
                echo "Descriptive Message: $_ask_msg"
		echo "Send Email: $_ask_email"

		_msg_insert=$( logname )" : "$( [ ! -z "$_ask_issue" ] && echo -n $_ask_issue": " )""$( [ ! -z "$_ask_procedure" ] && echo -n $_ask_procedure" : "$_ask_proc_des" : " )""$_ask_msg

}

ha_check()
{

	_ha_master_host=$( cat $_sensors_sot | grep "^CYC;0006;HA" | cut -d';' -f5 )
	_ha_slave_host=$( cat $_ha_cfg_file | awk -F\; -v _m="$_ha_master_host" '$1 == "ND" && $2 != _m { print $2 }' )
	_ha_role_me=$( cat $_ha_role_file )

	if [ "$HOSTNAME" != "$_ha_master_host" ]
	then    
		if [ "$_ha_role_me" == "SLAVE" ]
		then    
			if [ "$_sh_action" == "daemon" ]
			then
				exit 0
			else
				echo "WARNING: HA CONFIG ENABLED"
				echo "$HOSTNAME in SLAVE mode" 
				echo "Trying to execute command on master node ($_ha_master_host)"
				echo
				ssh $_ha_master_host "$_script_path/audit.nod.sh ${_command_opts}"
				_exit_code=$?
				[ "$_exit_code" != "0" ] && echo "ERROR ($_exit_code): please connect to $_ha_master_host to exec the command"
				exit $?
			fi
		fi
	else    
		if [ "$_ha_role_me" == "SLAVE" ]
		then    
			[ "$_sh_action" != "daemon" ] && echo -e "WARNING: HA CONFIG ON POSIBLE SPLIT BRAIN SITUATION force MASTER on UPDATER node" 
			exit 1
		fi
	fi
}

last_log_pg()
{
	_date_now=$( date +%s )
	let "_date_old=_date_now - 604800"

	_par_show="eventlog"
	_last_log_output=$( read_data | cut -d';' -f1,3- | sort -t\; -n | awk -F\; -v now="$_date_now" -v old="$_date_old" 'BEGIN { OFS=";" } { if ( $1 >= old && $1 <= now ) { $1=strftime("%Y-%m-%d;%H:%M:%S",$1) ; print $0 }}' ) 
	
	echo "${_last_log_output}" | tail -n 10
}

show_data()
{

                [ -f "$_host_data.header.txt" ] && _output_header=$( cat $_host_data.header.txt ) || _output_header="NO DATA EXTRACTED"
                [ -f "$_host_data.settings.txt" ] && _output_settings=$( cat $_host_data.settings.txt )  || _output_settings="NO DATA EXTRACTED"
                [ -f "$_host_data.activity.txt" ] && _output_activity=$( cat $_host_data.activity.txt )  || _output_activity="NO ACTIVITY DATA"
                [ -f "$_host_data.bitacora.txt" ] && _output_bitacora=$( cat $_host_data.bitacora.txt )  || _output_bitacora="NO BITACORA DATA"
                
                [ -z "$_output_header" ] && _output_header="NO DATA EXTRACTED"
                [ -z "$_output_settings" ] && _output_settings="NO DATA EXTRACTED"
                [ -z "$_output_activity" ] && _output_activity="NO ACTIVITY DATA"
                [ -z "$_output_bitacora" ] && _output_bitacora="NO BITACORA DATA"
                
                case "$_par_show" in
                wiki)   
                        _host_name=$(  echo "${_output_header}" | tail -n 1 | cut -d';' -f1 )
                        _host_type=$(  echo "${_output_header}" | tail -n 1 | cut -d';' -f2 )
                        _host_group=$( echo "${_output_header}" | tail -n 1 | cut -d';' -f3 )
                        _host_os=$(    echo "${_output_header}" | tail -n 1 | cut -d';' -f4 )
                        _host_mng_state=$( echo "${_output_header}" | tail -n 1 | cut -d';' -f5 )
			_host_last_upd=$( echo "${_output_header}" | tail -n 1 | cut -d';' -f6 )
                        
			generate_wiki_view > $_audit_wiki_path/$_host_file.audit.txt
			[ -f "$_audit_wiki_path/$_host_file.audit.txt" ] && chown $_apache_usr:$_apache_grp $_audit_wiki_path/$_host_file.audit.txt

                ;;
                commas) 
                        [ "$_par_filter" == "none" ] || [[ $_par_filter == *"resume"* ]] && [ ! "$_output_header" == "NO DATA EXTRACTED" ]  && echo "${_output_header}"
                        [ "$_par_filter" == "none" ] || [[ $_par_filter == *"settings"* ]] && [ ! "$_output_settings" == "NO DATA EXTRACTED" ] && echo "${_output_settings}" | sort -t\; -k1,1n -k2,2 -k3,3n | cut -d';' -f4-
                        [ "$_par_filter" == "none" ] || [[ $_par_filter == *"activity"* ]] && [ ! "$_output_activity" == "NO ACTIVITY DATA" ] && echo "${_output_activity}" | awk -F\; 'BEGIN { OFS=";" } {$1=strftime("%Y-%m-%d;%H:%M:%S",$1); print $0 }'
                        [ "$_par_filter" == "none" ] || [[ $_par_filter == *"bitacora"* ]] && [ ! "$_output_bitacora" == "NO BITACORA DATA" ] && echo "${_output_bitacora}" | awk -F\; 'BEGIN { OFS=";" } {$1=strftime("%Y-%m-%d;%H:%M:%S",$1); print $0 }'
			[ "$_par_filter" == "main" ] && [ ! "$_output_bitacora" == "NO BITACORA DATA" ] && echo "${_output_bitacora}" | awk -F\; 'BEGIN { OFS=";" } {$1=strftime("%Y-%m-%d;%H:%M:%S",$1); print $0 }'
                ;;
                human)  
                        echo
                        echo "INFO: $_host_node"
                        echo "==================================="
                        echo
                        
                        if [ "$_par_filter" == "none" ] || [[ $_par_filter == *"resume"* ]]
                        then    
                                echo "${_output_header}" | column -s\; -t
                                echo
                        fi
                        
                        if [ "$_par_filter" == "none" ] || [[ $_par_filter == *"settings"* ]]
                        then    
                                echo "SETTINGS INFO:"
                                echo "-----------------------------------"
                                echo "${_output_settings}" | sort -t\; -k1,1n -k2,2 -k3,3n | cut -d';' -f4- | column -s\; -t
                                echo
                        fi
                        
                        if [ "$_par_filter" == "none" ] || [[ $_par_filter == *"activity"* ]]
                        then    
                                if [ "$_output_activity" == "NO ACTIVITY DATA" ]
                                then    
                                        echo "NO ACTIVITY INFO"
                                        echo
                                else    
                                        echo "ACTIVITY INFO:"
                                        echo "-----------------------------------"
                                        echo "${_output_activity}" | awk -F\; 'BEGIN { print "DATE;TIME;EVENT;ACTIVITY;STATUS" } {$1=strftime("%d-%m-%Y;%H:%M:%S",$1); print $1";"$4";"$5";"$6 }' | column -s\; -t
                                        echo
                                fi
                        fi
                        
                        if [ "$_par_filter" == "none" ] || [[ $_par_filter == *"bitacora"* ]] || [ "$_par_filter" == "main" ]
                        then    
                                if [ "$_output_bitacora" == "NO BITACORA DATA" ]
                                then    
                                        echo "NO BITACORA INFO"
                                        echo
                                else    
                                        echo "BITACORA INFO:"
                                        echo "-----------------------------------"
                                        echo "${_output_bitacora}" | awk -F\; 'BEGIN { print "DATE;TIME;EVENT;ACTIVITY;STATUS" } {$1=strftime("%d-%m-%Y;%H:%M:%S",$1); print $1";"$4";"$5";"$6 }' | column -s\; -t
                                fi
                        fi
                ;;
                original)
                        echo "${_output_header}"
                        echo "${_output_settings}" 
                        echo "${_output_activity}"
                        echo "${_output_bitacora}"
                ;;
                eventlog) 
                        [ "$_par_filter" == "none" ] || [[ $_par_filter == *"activity"* ]] && [ ! "$_output_activity" == "NO ACTIVITY DATA" ] && echo "${_output_activity}"
                        [ "$_par_filter" == "none" ] || [[ $_par_filter == *"bitacora"* ]] && [ ! "$_output_bitacora" == "NO BITACORA DATA" ] && echo "${_output_bitacora}"
                        [ "$_par_filter" == "main" ] && [ ! "$_output_bitacora" == "NO BITACORA DATA" ] && echo "${_output_bitacora}"
                ;;
                debug)  
                        echo "${_output_settings}"
                ;;
                esac

}

###########################################
#              MAIN EXEC                  #
###########################################

	case $_sh_action in
	gen)
		case $_par_gen in 
		data)
			[ "$_cyclops_ha" == "ENABLED" ] && ha_check
			extract_static_data
		;;
		wiki)
			_par_show="wiki"

			[ "$_cyclops_ha" == "ENABLED" ] &&  ha_check
			read_data	

		;;
		index)

			[ "$_cyclops_ha" == "ENABLED" ] &&  ha_check

		;;
		all)
			[ "$_cyclops_ha" == "ENABLED" ] && ha_check

			_par_show="wiki"
			_opt_graph="yes"

			extract_static_data
			read_data

		;;
		esac
	;;
	fail)
		_par_show="wiki"

		[ "$_cyclops_ha" == "ENABLED" ] &&  ha_check

		extract_static_data
		read_data

	;;
	show)
		[ -z $_par_show ] && _par_show="human"

		[ "$_cyclops_ha" == "ENABLED" ] &&  ha_check

		read_data
	;;
	insert)

		[ "$_cyclops_ha" == "ENABLED" ] &&  ha_check

		[ -z $_par_node ] && _par_node="main" && _audit_code_type="GEN" 
		[ -z $_opt_msg ] && [ "$_par_insert" != "issue" ] && echo "ERR: Need a Message to insert in bitacora node" && exit 1 
		[ -z $_par_event ] && _par_event="INFO"
		[ -z $_par_stat ] && _par_stat="INFO" 

		insert_event
	;;
	daemon)
		_par_show="wiki"
		_opt_graph="yes"

		[ "$_cyclops_ha" == "ENABLED" ] &&  ha_check

		[ ! -d $_audit_wiki_path ] && mkdir -p $_audit_wiki_path

		#### GENERATE NODE PAGE INFO ####
		extract_static_data
		read_data
		#### ^^^^ ####

		last_log_pg >$_last_event_log

	;;
	debug)
		echo "DEBUG: MODE"
		echo 
		echo "COOL OUTPUT"
		echo
		last_log_pg
		echo 
		echo "REPORT"
		echo
		echo "date old: $_date_old" 
		echo "date now: $_date_now"
	;;
	esac
