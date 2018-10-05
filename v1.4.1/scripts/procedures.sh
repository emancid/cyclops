#!/bin/bash

###########################################
#     PROCEDURES MANAGEMENT  SCRIPT       #
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
_debug_code="PROCEDURES "
_debug_prefix_msg="Procedures: "
_exit_code=0

_opt_show="no"
_opt_changes="no"
_opt_action="no"
_opt_node="no"

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

###########################################
#              PARAMETERs                 #
###########################################

_proc_action="start"

while getopts ":a:ct:m:v:h:" _optname
do

        case "$_optname" in
		"a")
			## Create Procedure (depends type (t) (node/dev)  and section (m) (wiki/system)
			echo "ON DESIGN DESK"
			exit 2
		;;
		"t")
			## Set type of procedure for filter script actions (node/dev/slurm/security)
			_opt_type="yes"
			_par_type=$OPTARG

			if [ !"$_par_show" == "node" ] || [ !"$_par_show" == "env" ] || [ !"$_par_show" == "rules" ]
                        then
                                echo "-t [type] select procedure type"
                                echo "          node: procedures designed for nodes/hosts"
                                echo "          env: procedures designed for environment devices like switch,power,etc."
				echo "		rules: show if sensor links procedure"
                                exit 1
                        fi
		;;
		"m")
			## Set section of procedure wiki docs or ia cyclops procedures
			echo "ON DESIGN DESK, ACTUALLY ONLY IA PROCEDURES"
			exit 2

		;;
		"v")
			## Format script output 
                        _opt_show="yes"
                        _par_show=$OPTARG
                        if [ !"$_par_show" == "human" ] || [ !"$_par_show" == "wiki" ] || [ !"$_par_show" == "commas" ]
                        then
                                echo "-v [option] Show formated results"
                                echo "          human: human readable"
                                echo "          wiki:  wiki format readable"
                                echo "          commas: excell readable"
                                exit 1
                        fi
		;;
		"h")
			case "$OPTARG" in
                        "des")
                                echo "$( basename "$0" ) : Cyclops Prodedures Management Command"
				echo "	Default path: $( dirname "${BASH_SOURCE[0]}" )"
				echo "	Config path: $_config_path_mon"
				echo "		Config Codes file: $( echo $_sensors_ia_codes_file | awk -F\/ '{ print $NF }' )"
				echo "	Node IA path: $_sensors_ia_path"
				echo "	Env IA path: $_sensors_env_ia"
				echo "	Wiki path: $_pages_path/operation/procedures "
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
				echo "CYCLOPS PROCEDURE MANAGEMENT COMMAND"
				echo 
				echo "-a [parameter] ON DESIGN DESK , NOT YET OPERATIVE"
				echo "-t [type] select procedure type"
				echo "          node: procedures designed for nodes/hosts"
				echo "          env: procedures designed for environment devices like switch,power,etc."
				echo "		rules: show if sensor links procedure"
				echo "-m [parameter] ON DESIGN DESK , NOT YET OPERATIVE"
				echo "-v [option] Show formated results"
				echo "          human: human readable"
				echo "          wiki:  wiki format readable"
				echo "          commas: excell readable"
				echo "-h [|des] help is help"
				echo "		des: Detailed Command Help"
				exit 0
			else
				echo "ERR: Use -h for help"
				exit 1
			fi
		;;
		"*")
			echo "ERR: Use -h for help"
			exit 1
		;;
	esac
done

shift $((OPTIND-1))

###########################################
#              FUNCTIONs                 #
###########################################


show_node_procedures()
{

        ## NODE IA PROCEDURES

        for _proc_file in $( ls -1 $_sensors_ia_path/* | awk '$1 ~ "rule$" { print $1 }' )
        do
                _code=$( echo $_proc_file | cut -d'.' -f2 )
                _priority=$( echo $_proc_file | awk -F\/ '{ print $NF }' | cut -d'.' -f1 )
                _host=$( cat $_proc_file | grep ^[0-9] | awk -F\; '{ if ( $3 == "" ) { $3="ALL" } { print $3 }}' | tr '\n' ',' | sed 's/,$//' )
                _sensors=$( cat $_proc_file | grep ^[0-9] | cut -d';' -f4- | sed -e 's/;/,/g' | tr '\n' ',' | sed 's/,$//'  )
                _file_des=$( grep "^$_code;" $_sensors_ia_codes_file | cut -d';' -f2 )
                [ -z "$_file_des" ] && _file_des="NONE"

                _wiki_file=$( ls -1 $_pages_path/operation/procedures/*.txt | cut -d'.' -f1 | tr '[:lower:]' '[:upper:]' | grep $_code | wc -l )
                _wiki_index=$( cat $_pages_path/operation/procedures/procedures.txt | grep $_code | wc -l )
                [ "$_wiki_index" -eq 0 ] && _wiki_index="NO" || _wiki_index="YES ("$_wiki_index")"
                if [ "$_wiki_file" -ne 0 ]
                then
                        _wiki_file=$( echo $_code | tr '[:upper:]' '[:lower:]' | sed -e 's/$/\.txt/' )
                        _wiki_version=$( cat $_pages_path/operation/procedures/$_wiki_file | awk -F\| -v _code=$_code '$2 ~ _code { print $0 }' | sed -e 's/ //g' -e 's/@#[A-F0-9]*\://g' -e 's/<[a-z /]*>//g' | tr '|' ';'  | awk -F\; '{ print $8 }' )
                        _wiki_verif=$( cat $_pages_path/operation/procedures/$_wiki_file | awk -F\| -v _code=$_code '$2 ~ _code { print $0 }' | sed -e 's/ //g' -e 's/@#[A-F0-9]*\://g' -e 's/<[a-z /]*>//g' | tr '|' ';'    | awk -F\; '{ print $4 }' )
                        _wiki_opert=$( cat $_pages_path/operation/procedures/$_wiki_file | awk -F\| -v _code=$_code '$2 ~ _code { print $0 }' | sed -e 's/ //g' -e 's/@#[A-F0-9]*\://g' -e 's/<[a-z /]*>//g' | tr '|' ';'    | awk -F\; '{ print $5 }' )
                else
                        _wiki_file="NO EXIST"
                        _wiki_version=""
                        _wiki_verif=""
                        _wiki_opert=""
                fi
                _proc_data=$_proc_data"\n"$_code";"$_file_des";"$_priority";"$_host";"$_sensors";"$_wiki_file";"$_wiki_index";"$_wiki_version";"$_wiki_opert";"$_wiki_verif
        done

        _output=$( echo $_header_procedure_output ; echo -e $_proc_data | sort )

}

show_env_procedures()
{

        ## ENV IA PROCEDURES 

        _proc_data=""

        for _proc_file in $( ls -1 $_sensors_env_ia/*.rule |  grep -v template  )
        do
                _code=$( echo $_proc_file | cut -d'.' -f2 )
                _priority=$( echo $_proc_file | awk -F\/ '{ print $NF }' | cut -d'.' -f1 )
                _env_dev=$( cat $_proc_file | grep ^[0-9] | awk -F\; '{ if ( $3 == "" ) { $3="ALL" } { print $3 }}' | tr '\n' ',' | sed 's/,$//' )
                _sensors=$( cat $_proc_file | grep ^[0-9] | cut -d';' -f4- | sed -e 's/;/,/g' | tr '\n' ',' | sed 's/,$//'  )
                _file_des=$( grep "^$_code;" $_sensors_ia_codes_file | cut -d';' -f2 )
                [ -z "$_file_des" ] && _file_des="NONE"

                _wiki_file=$( ls -1 $_pages_path/operation/procedures/*.txt | cut -d'.' -f1 | tr '[:lower:]' '[:upper:]' | grep $_code | wc -l )
                _wiki_index=$( cat $_pages_path/operation/procedures/procedures.txt | grep $_code | wc -l )
                [ "$_wiki_index" -eq 0 ] && _wiki_index="NO" || _wiki_index="YES ("$_wiki_index")"
                if [ "$_wiki_file" -ne 0 ]
                then
                        _wiki_file=$( echo $_code | tr '[:upper:]' '[:lower:]' | sed -e 's/$/\.txt/' )
                        _wiki_version=$( cat $_pages_path/operation/procedures/$_wiki_file | awk -F\| -v _code=$_code '$2 ~ _code { print $0 }' | sed -e 's/ //g' -e 's/@#[A-F0-9]*\://g' -e 's/<[a-z /]*>//g' | tr '|' ';'  | awk -F\; '{ print $8 }' )
                        _wiki_verif=$( cat $_pages_path/operation/procedures/$_wiki_file | awk -F\| -v _code=$_code '$2 ~ _code { print $0 }' | sed -e 's/ //g' -e 's/@#[A-F0-9]*\://g' -e 's/<[a-z /]*>//g' | tr '|' ';'    | awk -F\; '{ print $4 }' )
                        _wiki_opert=$( cat $_pages_path/operation/procedures/$_wiki_file | awk -F\| -v _code=$_code '$2 ~ _code { print $0 }' | sed -e 's/ //g' -e 's/@#[A-F0-9]*\://g' -e 's/<[a-z /]*>//g' | tr '|' ';'    | awk -F\; '{ print $5 }' )
                else
                        _wiki_file="NO EXIST"
                        _wiki_version=""
                        _wiki_verif=""
                        _wiki_opert=""
                fi
                _proc_data=$_proc_data"\n"$_code";"$_file_des";"$_priority";"$_env_dev";"$_sensors";"$_wiki_file";"$_wiki_index";"$_wiki_version";"$_wiki_opert";"$_wiki_verif
        done

        _output=$( echo $_header_procedure_output ; echo -e $_proc_data | sort )
}

show_rules_link()
{
        echo "SENSOR;IA RULE LINK"
        for _sensor in $( ls -1R $_sensors_script_path/ | sed -e '/^$/d' | grep '.sh$' | grep -v "refactory" | sort -u  | cut -d'.' -f2 )
        do
                if grep -r $_sensor $_sensors_script_path/* >/dev/null
                then
                        echo "$_sensor;exist" 
                else
			[ "$_sensor" ==  "daemon_generic" ] && echo "$_sensor;Generic Sensor, Show Specific Config" || echo "$_sensor;Not exist"
                fi
        done | sort
}

show_procedure_link()
{
	#### NOT YET ACTIVE , COMMAND CHECK LINK BETWEN EXISTING PROCEDURE CODES WITH EXISTING IA RULES ####

	for _procedure in $( cat /etc/cyclops/procedure.ia.codes.cfg | cut -d';' -f1 | awk '{ print $0 }' ) ; do _exist=$( ls -1 /opt/cyclops/monitor/sensors/status/ia/ | grep $_procedure | wc -l ) ; echo $_procedure":"$_exist  ; done
}

print_output()
{

        _header_procedure_output="CODE;DESCRIPTION;PRIORITY;HOST;SENSORS;WIKI FILE;WIKI INDEX;WIKI VER;OPERATIVE;VERIFICATED"


	case "$_par_show" in
	"human")
		echo -e "$_header_procedure_output\n${_output}" | column -s\; -t
	;;
	"wiki")
		echo
		echo "====== Procedure Status ($_par_type) ======"
		echo
		echo "|< 100% >|" 
		echo $_header_procedure_output | sed -e '/^$/d' -e "s/^/|  $_color_title/" -e 's/$/  |/' -e "s/;/  |  $_color_title /g"
		echo "${_output}" | sed -e '/^$/d' -e 's/^/|  /' -e 's/$/  |/' -e 's/;/  |  /g' -e "s/NO/$_color_down &/g" -e "s/YES/$_color_ok &/g" -e "s/SI/$_color_up &/g"

	;;
	"commas")
		echo -e "${_output}"
	;;
	"*")
		echo -e "${_output}"
	;;
	esac
	


}

print_generic()
{

	case "$_par_show" in
	"human")
		echo "${_output}" | column -s\; -t
	;;
	"wiki")
		echo "NO YET IMPLEMENTED IN THIS CASE, USE OTHER FORMAT [human|commas]"
	;;
	"commas")
		echo "${_output}"
	;;
	"*")
		echo "${_output}"
	;;
	esac
	
}


###########################################
#              MAIN EXEC                  #
###########################################

	case "$_par_type" in
	"env")
		show_env_procedures
		print_output
	;;
	"node")
		show_node_procedures
		print_output
	;;
	"rules")
		_output=$( show_rules_link )
		print_generic 
	;;
	esac


 
