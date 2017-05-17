#!/bin/bash

#### IA SENSORS SCRIPT ####

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

IFS="
"

[ -z "$1" ] && exit 1 || _parent_pid=$1


_config_path="/etc/cyclops"

if [ -z $_config_path/global.cfg ]
then
        echo "Global config file don't exits"
        exit 1
else
        source $_config_path/global.cfg
fi

_system_status="OK"
_rules_detected=0

_ia_codes=""

_audit_status=$( awk -F\; '$1 == "CYC" && $2 == "0003" && $3 == "AUDIT" { print $4 }' $_sensors_sot )

#### FUNCTIONS ####

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

	#### DEPRECATED - IF NEW ONE WORKS FINE - DELETE OLD ONE

        _nodelist=$1

        echo "${_nodelist}" | tr ' ' '\n' | sed -e '/^$/d' -e 's/[0-9]*$/;&/' | sort -t\; -k2,2n -u | awk -F\; '
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

                END {
                        if ( _sep == "-" ) { 
                                _string=_string""_sta"-"_end }
                        else {
                                _string=_string""_sta","_end }
                        print _string"]" }'


}

alerts_gen()
{

	for _alert_incidence in $( echo "${_nodes_err}" | grep -v ";[1-3]$" )
	do
		_alert_host=$( echo $_alert_incidence | cut -d';' -f1 )
		_alert_fail=$( echo $_alert_incidence | cut -d';' -f2 )
		_alert_sens_id=$( echo $_alert_incidence | cut -d';' -f3 )
		_alert_family=$( awk -F\; -v _node="$_alert_host" '$2 == _node { print $3 }' $_type )

		_alert_sens=$( awk -v _id="$_alert_sens_id" '{ _line++ ; if ( _id == _line ) {  print $1 }}' $_config_path_nod/$_alert_family.mon.cfg )
		_alert_id=$( awk -F\; 'BEGIN { _id=0 } $1 == "ALERT" { if ( $3 > _id ) { _id=$3 }} END { _id++ ; print _id }' $_sensors_sot )

		_alert_status=$( awk -F\; -v _node="$_alert_host" -v _sens="$_alert_sens" '$4 == _node && $5 == _sens { print $0 }' $_sensors_sot | wc -l )

		[ "$_alert_status" -eq 0 ] && echo "ALERT;NOD;$_alert_id;$_alert_host;$_alert_sens;$( date +%s );0" >> $_sensors_sot 

		# AUDIT LOG TRACERT
		if [ "$_audit_status" == "ENABLED" ] && [ "$_alert_status" -eq 0 ] 
		then
			[ -z "$_alert_sens" ] && _alert_sens="NULL"
			[ -z "$_alert_fail" ] && _alert_fail="MARK" || _audit_alert=$( echo $_alert_fail | sed -e 's/^F$/FAIL/' -e 's/^D$/DOWN/' -e 's/^U$/UNKNOWN/' -e 's/^K$/UP/' )
			[ -z "$_alert_host" ] && _alert_host="NULL" || $_script_path/audit.nod.sh -i event -e alert -m "$_alert_sens" -s $_audit_alert -n $_alert_host 2>>$_mon_log_path/audit.log
		fi
	done

}

alerts_del()
{


	for _alert_ok_host in $( echo "${_nodes_ok}" | cut -d';' -f1 )
	do
		_alert_ok_status=$( awk -F\; -v _node="$_alert_ok_host" 'BEGIN { _count=0 } $4 == _node { _count++ } END { print _count }' $_sensors_sot )
	
		[ "$_alert_ok_status" -ne 0 ] && sed -i -e "/^ALERT;NOD;[0-9]*;$_alert_ok_host;.*;3/d" -e "s/\(^ALERT;NOD;[0-9]*;$_alert_ok_host;.*;\)[01]$/\12/" $_sensors_sot	
		
		# AUDIT LOG TRACERT 
		# [ "$_audit_status" == "ENABLE" ] && echo "$( date +%s );NOD;system health;host sensors recovery;OK"  >> $_audit_data_path/$_alert_ok_host.activity.txt ### REFACTORING PLEASE
	done
 
}

ia_analisis()
{

for _ia_file in $(ls -1 $_sensors_ia_path | sort -nr | grep rule$ )
do

        _priority=`echo $_ia_file | cut -d'.' -f1`
        _ia_code=`echo $_ia_file | cut -d'.' -f2`

        _ia_code_level=0
        _var_line_level=0
        _ia_code_max=`awk -F\; '{ total=total + ( $1 * $2 ) } END { print total }' $_sensors_ia_path/$_ia_file` 

        _host_list=""
        _host_quantity=0


        for _line in $(echo "${_nodes_err}" )
        do
                _node_name=`echo $_line | cut -d';' -f1`
                _node_family=$(awk -F\; -v _node=$_node_name '$2 == _node { print $3 }' $_type)
                _service_num=`echo $_line | cut -d';' -f3`
                _service_name=$(awk '{ print NR";"$0 }' $_config_path_nod/$_node_family.mon.cfg | awk -F\; -v _num=$_service_num '$1 == _num { print $2 }')

                _var_line_level=`cat $_sensors_ia_path/$_ia_file | grep -v \# | awk -F\; -v _name=$_node_name -v _service=$_service_name '$3 == _name || $3 == "" && $0 ~ _service  { _total=_total + $1 } END { print _total }'`

                if [ ! -z "$_var_line_level" ]
                then
                        let "_rules_detected++"
                        let "_ia_code_level=_ia_code_level + _var_line_level"

                        if [ $(echo $_host_list | grep $_node_name | wc -l) == 0 ]
                        then
                                _host_list=$_host_list" "$_node_name
                                let "_host_quantity++"
                        fi
                fi

        done


        [ "$_ia_code_level" -ne 0 ] && let "_ia_code_percent=(($_ia_code_level * 100) / $_ia_code_max) / $_host_quantity "

        [ -z "$_ia_code_percent" ] && _ia_code_percent=0
        [ -z "$_ia_code_level" ] && _ia_code_level=0

        if [ "$_ia_code_percent" -ge 40 ] && [ "$_ia_code_level" -ne 0 ]
        then
                _ia_code_des=$(cat $_sensors_ia_codes_file 2>/dev/null | grep $_ia_code | cut -d';' -f2)

                [ -z "$_ia_code_des" ] && _ia_code_des="No Description"

		[ "$_host_quantity" -gt 1 ] && _host_range=$( node_group $_host_list ) || _host_range=$_host_list
                _ia_codes=$_ia_codes$( echo "$_priority;$_ia_code_percent%;$_ia_code;$_ia_code_des;$_host_quantity;$_host_range" )"\n"
        fi

done


[ -z "$_ia_codes" ] && _ia_codes=$( echo ";UNKNOWN;UNKNOWN;UNKNOWN;No relevant procedure rules detected (must be more than 40% success to considerate it);$_host_quantity;show detail table below" )

let "_level=$_err_detected + $_rules_detected"

#echo  ";DOWN NODE STATUS - IA ALERT;\n"

if [ "$_rules_detected" != "0" ]
then
        echo "PRIORITY@PROBABILITY@CODE@DESCRIPTION@HOST QTY@HOST(s) NAME"
        echo -e "${_ia_codes}" | sed '/^$/d' | sort -t\; -k1,2n 
else
        echo "UNKNOWN ERRORS DETECTED;;;;;"
fi

}

#### MAIN EXEC ####

_nodes_ok=$( cat $_sensors_ia_tmp_path/$_parent_pid"."$_sensors_ia_tmp_name | awk -F\; '$2 == "K" || $2 == "M" { print $0 }' )
_nodes_err=$( cat $_sensors_ia_tmp_path/$_parent_pid"."$_sensors_ia_tmp_name | awk -F\; '$2 != "K" && $2 != "M" { print $0 }' )
_sot_active_alerts=$( cat $_sensors_sot | grep "^ALERT;NOD" | wc -l )


if [ ! -z "$_nodes_err" ]
then
	alerts_gen
	ia_analisis
fi

[ "$_sot_active_alerts" -ne 0 ] && alerts_del

rm -f $_sensors_ia_tmp_path"/"$_parent_pid"."$_sensors_ia_tmp_name

#### END ####
