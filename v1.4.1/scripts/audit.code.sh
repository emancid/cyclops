#!/bin/bash

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

        _sh_color_green='\033[32m'
        _sh_color_red='\033[31m'
        _sh_color_yellow='\033[33m'
        _sh_color_bolt='\033[1m'
        _sh_color_nformat='\033[0m'

        _command_opts=$( echo "$@" | awk -F\- 'BEGIN { OFS=" -" } { for (i=2;i<=NF;i++) { if ( $i ~ /^m/ ) { gsub(/^[a-z] /,"&@",$i) ; gsub (/$/,"@",$i) }}; print $0 }' | tr '@' \' )
        _command_name=$( basename "$0" )
        _command_dir=$( dirname "${BASH_SOURCE[0]}" )
        _command="$_command_dir/$_command_name $_command_opts"

        [ -f "/etc/cyclops/global.cfg" ] && source /etc/cyclops/global.cfg || _exit_code="111"

        [ -f "$_libs_path/ha_ctrl.sh" ] && source $_libs_path/ha_ctrl.sh || _exit_code="112"
        [ -f "$_libs_path/node_group.sh" ] && source $_libs_path/node_group.sh || _exit_code="113"
        [ -f "$_libs_path/node_ungroup.sh" ] && source $_libs_path/node_ungroup.sh || _exit_code="114"

        source $_color_cfg_file

        case "$_exit_code" in
        111)
                echo "Main Config file doesn't exists, please revise your cyclops installation"
                exit 1
        ;;
        112)
                echo "HA Control Script doesn't exists, please revise your cyclops installation"
                exit 1
        ;;
        11[3-4])
                echo "Necesary libs files doesn't exits, please revise your cyclops installation"
                exit 1
        ;;
        esac

#
        _par_typ="status"
        _par_act="all"

        _cyclops_ha=$( awk -F\; '$1 == "CYC" && $2 == "0006" { print $4}' $_sensors_sot )



###########################################
#              PARAMETERs                 #
###########################################

while getopts ":c:d:e:n:f:h:" _optname
do
        case "$_optname" in
                "c")
                        _opt_code_pattern="yes"
                        _par_code_pattern=$OPTARG
                ;;
                "d")
                        _opt_date_start="yes"
                        _par_date_start=$OPTARG
		;;
		"e")
                        _opt_date_end="yes"
                        _par_date_end=$OPTARG
		;;
		"n")
                        _opt_node="yes"
                        _par_node=$OPTARG

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
		;;
		"f")
			_opt_filter="yes"
			_par_filter=$OPTARG
		;;
                "h")
                        _opt_help="yes"
                        _par_help=$OPTARG

                        case "$_par_help" in
                                        "des")
                                                echo "$( basename "$0" ) : Cyclops Issue Control Audit Tool"
                                                echo "  Default path: $( dirname "${BASH_SOURCE[0]}" )"
                                                echo "  Global config path : $_config_path"
                                                echo "          Global config file: global.cfg"
						echo "		Issue Codes Config file: /audit/issuecodes.cfg"
                                                echo

                                                exit 0
                        esac
		;;
		":")
                        case "$OPTARG" in
                        "h")
                                echo
                                echo "CYCLOPS ISSUE CONTROL AUDIT TOOL"
                                echo "  Help to know logbook issue and control state of them"
				echo
				echo "	-c [pattern name|help], select issue code pattern, use help for know avaibility"
				echo
                                echo "FILTER:"
				echo
				echo " 	-n [node|node range] node filter"
                                echo "		You can use @[group or family name] to define range node"
                                echo "		and you can use more than one group/family comma separated"
				echo
                                echo "	-d [date format], start date or range to filter by date:"
                                echo "		[YYYY]: ask for complete year"
                                echo "		[Mmm-YYYY]: ask for concrete month"
                                echo "		year: ask for last year"
                                echo "		[1-9*]month: ask for last month"
                                echo "		week: ask for last week"
                                echo "		[1-9*]day: ask for last n days ( sort by 24h format"
                                echo "		[1-9*]day: ask for last n hours ( sort by hour format"
                                echo "		report: ask for year,month,week,day"
                                echo "		[YYYY-MM-DD]: Implies data from date to now if you dont use -e"
                                echo "	-e [YYYY-MM-DD], end date for concrete start date" 
                                echo "		mandatory use the same format with -d parameter"
				echo

				exit 0
			;;
			esac
		;;
	esac
done

shift $((OPTIND-1))

###########################################
#               FUNCTIONs                 #
###########################################

issue_processing()
{
	audit.nod.sh -v eventlog -f bitacora | 
		sort -t\; -k1n | 
		awk -F\; -v tsb="$_par_ds" -v tse="$_par_de" -v cip="$_code_pattern" -v nd="$_par_node" '
			BEGIN { 
				_fecha=systime() 
			} $1 > tsb && $1 < tse && $3 ~ nd && $0 ~ cip { 
				split($5,ni,":") ; 
				gin[ni[2]]=gin[ni[2]]"\n\t"strftime("%F - %T",$1)" | "$6" | "$3" | "ni[3] 
			} END { 
				for ( i in gin ) { 
					if ( gin[i] !~ "SOLVED" && gin[i] ~ /FAIL|DOWN/ ) { 
						split(i,inc,"-") ; 
						finc=gensub(/.(..)(..)(..)/,"\\1 \\2 \\3","g",inc[1]) ; 
						fts=mktime( "20"finc" 0 0 0") ; 
						_result=(_fecha-fts)/86400 ; 
						print i": ("int(_result)"d age)"gin[i]"\n" 
					} 
				}
			}'
}


issue_processing_temp_all()
{
	audit.nod.sh -v eventlog -f bitacora | 
		sort -t\; -k1n | 
		awk -F\; -v tsb="$_par_ds" -v tse="$_par_de" -v cip="$_code_pattern" -v nd="$_par_node" '
			BEGIN { 
				_fecha=systime() 
			} $1 > tsb && $1 < tse && $3 ~ nd && $0 ~ cip { 
				split($5,ni,":") ; 
				gin[ni[2]]=gin[ni[2]]"\n\t"strftime("%F - %T",$1)" | "$6" | "$3" | "ni[3] 
			} END { 
				for ( i in gin ) { 
					split(i,inc,"-") ; 
					finc=gensub(/.(..)(..)(..)/,"\\1 \\2 \\3","g",inc[1]) ; 
					fts=mktime( "20"finc" 0 0 0") ; 
					_result=(_fecha-fts)/86400 ; 
					print i": ("int(_result)"d age)"gin[i]"\n" 
				}
			}'
}

init_date()
{

        _date_tsn=$( date +%s )

        case "$_par_date_start" in
        *[0-9]hour|hour)
                _hour_count=$( echo $_par_date_start | grep -o ^[0-9]* )
                _par_date_start="hour"

                [ -z "$_hour_count" ] && _hour_count=1

                let _ts_date=3600*_hour_count

                let _par_ds=_date_tsn-_ts_date
                _par_de=$_date_tsn

                _date_filter=$_par_date_start
                _par_date_start=$( date -d @$_par_ds +%Y-%m-%d )
                _par_date_end=$( date +%Y-%m-%d )
        ;;
        *[0-9]day|day)
                _day_count=$( echo $_par_date_start | grep -o ^[0-9]* )
                _par_date_start="day"

                [ -z "$_day_count" ] && _day_count=1

                let _ts_date=86400*_day_count

                let _par_ds=_date_tsn-_ts_date
                _par_de=$_date_tsn

                _date_filter=$_par_date_start
                _par_date_start=$( date -d @$_ts_date +%Y-%m-%d )
                _par_date_end=$( date +%Y-%m-%d )
        ;;
        week|"")
                _ts_date=604800

                let _par_ds=_date_tsn-_ts_date
                _par_de=$_date_tsn

                _date_filter=$_par_date_start
                _par_date_start=$( date -d "last week" +%Y-%m-%d )
                _par_date_end=$( date +%Y-%m-%d )

        ;;
        *[0-9]month|month)
                #_ask_date=$( date -d "last month" +%Y-%m-%d )
                _month_count=$( echo $_par_date_start | grep -o ^[0-9]* )
                _par_date_start="month"

                [ -z "$_month_count" ] && _month_count=1

                let _ts_date=2592000*_month_count

                let _par_ds=_date_tsn-_ts_date
                _par_de=$_date_tsn

                _date_filter=$_par_date_start
                _par_date_start=$( date -d @$_ts_date +%Y-%m-%d )
                _par_date_end=$( date +%Y-%m-%d )
        ;;
        year)
                #_ask_date=$( date -d "last year" +%Y-%m-%d )
                _ts_date=31536000

                let _par_ds=_date_tsn-_ts_date
                _par_de=$_date_tsn

                _date_filter=$_par_date_start
                _par_date_start=$( date -d "last year" +%Y-%m-%d )
                _par_date_end=$( date +%Y-%m-%d )
        ;;
        "Jan-"*|"Feb-"*|"Mar-"*|"Apr-"*|"May-"*|"Jun-"*|"Jul-"*|"Aug-"*|"Sep-"*|"Oct-"*|"Nov-"*|"Dec-"*)
                _date_year=$( echo $_par_date_start | cut -d'-' -f2 )
                _date_month=$( echo $_par_date_start | cut -d'-' -f1 )

                _query_month=$( date -d '1 '$_date_month' '$_date_year +%m | sed 's/^0//' )
                _par_ds=$( date -d '1 '$_date_month' '$_date_year +%s )

                let "_next_month=_query_month+1"
                [ "$_next_month" == "13" ] && let "_next_year=_date_year+1" && _next_month="1" || _next_year=$_date_year

                _par_de=$( date -d $_next_year'-'$_next_month'-1' +%s)

                let "_par_de=_par_de-10"

                _date_filter="month"
                _par_date_start=$( date -d @$_par_ds +%Y-%m-%d )
                _par_date_end=$( date -d @$_par_de +%Y-%m-%d )
        ;;
        2[0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9])
                _par_ds=$( date -d $_par_date_start +%s )
                if [ -z "$_par_date_end" ]
                then
                        _par_de=$( date +%s )
                        _par_date_end=$( date +%Y-%m-%d )
                else
                        _par_de=$( date -d $_par_date_end +%s )
                fi

                let _day_count=(_par_de-_par_ds )/86400

                case "$_day_count" in
                0)
                        _date_filter="hour"
                ;;
                [1-2])
                        _date_filter="day"
                ;;
                [3-9])
                        _date_filter="week"
                ;;
                [1-4][0-9])
                        _date_filter="month"
                ;;
                *)
                        _date_filter="year"
                ;;
                esac
        ;;
        2[0-9][0-9][0-9])
                _par_ds=$( date -d '1 Jan '$_par_date_start +%s )
                _par_de=$( date -d '31 Dec '$_par_date_start +%s )

                _date_filter="year"
                _par_date_start=$( date -d @$_par_ds +%Y-%m-%d )
                _par_date_end=$( date -d @$_par_de +%Y-%m-%d )
        ;;
        *)
                ### IF DATE START WRONG... GET DAY BY DEFAULT ####
                _ts_date=86400

                let _par_ds=_date_tsn-_ts_date
                _par_de=$_date_tsn

                _date_filter=$_par_date_start
                _par_date_start=$( date -d "last day" +%Y-%m-%d )
                _par_date_end=$( date +%Y-%m-%d )
        ;;
        esac

        let "_hour_days=((_par_de-_par_ds)/86400)+1"
}

###########################################
#               MAIN EXEC                 #
###########################################

############### REQUIREMENTS CHECK ##################

	[ "$_cyclops_ha" == "ENABLED" ] && ha_check $_command

	[ ! -f "$_config_path/audit/issuecodes.cfg" ] && echo "ERR: issue codes file doesn't exists, please create it" && exit 1

########### OPTIONS PROCESSING ############

	[ -z "$_opt_date_start" ] && _par_date_start="week"

	init_date
	
	if [ "$_par_code_pattern" == "help" ]
	then
		echo
		echo "Cyclops Audit Module"
		echo "Available codenames for show issues reports"
		echo ""
		awk -F\; 'BEGIN { print "CODENAME;| PATTERN\n-----------;|----------------" } $1 ~ "^[0-9a-z]+$" && NF == 2 { print $1";| "$2 }' $_config_path/audit/issuecodes.cfg | column -t -s\; 
		echo ""
		exit 0
	else
		[ ! -z "$_par_code_pattern" ] && _code_pattern=$( awk -F\; -v cp="$_par_code_pattern" 'NF == 2 && $1 !~ "^[ #]" && $1 == cp { _sd=$2 } END { print _sd }' $_config_path/audit/issuecodes.cfg )
		[ -z "$_code_pattern" ] && echo "Not have a valid issue code pattern" && exit 1
	fi


	[ ! -z "$_par_node" ] && _par_node=$( node_ungroup $_par_node | sed -e 's/ /$|^/g' -e 's,^,/,' -e 's,$,/,' )
	

################ LAUNCHING ###################


	case $_par_filter in
	"all")
		issue_processing_temp_all
	;;
	*)
		issue_processing	
	;;
	esac
