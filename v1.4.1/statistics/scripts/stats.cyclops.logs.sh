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

_config_path="/etc/cyclops"

if [ -f $_config_path/global.cfg ]
then
        source $_config_path/global.cfg
	source $_color_cfg_file
else
        echo "Global config don't exits" 
        exit 1
fi

###########################################
#              PARAMETERs                 #
###########################################

while getopts ":r:d:e:t:f:n:v:w:k:xh:" _optname
do
        case "$_optname" in
		"n")
			# field node [ FACTORY NODE RANGE ] 
			_opt_nod="yes"
			_par_nod=$OPTARG
		;;
                "e")
			# date end
                        _opt_date_end="yes"
                        _par_date_end=$OPTARG
                ;;
                "d")
			# date start
                        _opt_date_start="yes"
                        _par_date_start=$OPTARG
		;;
		"v")
			# format output
			_opt_show="yes"
			_par_show=$OPTARG
		;;
		"s")
			# log data source
			_opt_src="yes"
			_par_src=$OPTARG	
		;;
		"k")
			_opt_ref="yes"
			_par_ref=$OPTARG
		;;
		"r")
			_opt_itm="yes"
			_par_itm=$OPTARG
		;;
		"t")
			_opt_typ="yes"
			_par_typ=$OPTARG
		;;
		"f")
			_opt_file="yes"
			_par_file=$OPTARG
		;;
		"x")
			# DEBUG option
			_opt_debug="yes"
		;;
		"w")
                        _opt_vwiki="yes"
                        _par_vwiki=$OPTARG

			_opt_hidden=$( echo $_par_vwiki | tr ',' '\n' | awk '$0 ~ "hidden" { print "yes" }' )
                        _opt_with=$( echo $_par_vwiki | tr ',' '\n' | grep "^W" | sed 's/W//' )
                        _opt_gtype=$( echo $_par_vwiki | tr ',' '\n' | awk '$0 ~ "^T" { gsub("T","",$1) ; print $1 }' )
			_opt_gvalue=$( echo $_par_vwiki | tr ',' '\n' | awk '$0 == "value" { _sw1="value" } $0  ~ "Tpie" { _sw2="pie" } END { if ( _sw1 == "value" && _sw2 != "Tpie" ) { print "value" }}' ) 
		;;
		"h")
			case "$OPTARG" in
			"des")
				echo "$( basename "$0" ) : Cyclops Command for Logs Module Statistics" 
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
				echo "CYCLOPS STATISTICS: CYC LOGS MODULE"
				echo
				echo "MAIN FIELDS:"
				echo "	-n [[nodename]|[device]|dashboard|cyclops] item from log to stats"
				echo "		[nodename]: name of desired host to ask data log info"
				echo "		[device]: name of monitoring enviroment device to ask data log info"
				echo "		dashboard: ask for system activity info from cyclops dashboard" 
				echo "		cyclops: NOT AVAILABLE YET"
				echo "	-r [sensor|help] sub-item from log to stats" 
				echo "		sensor: what ever available sensor in monitor module"
				echo "		help: show available sensors for host/node/device"
				echo
				echo "STATS:"
				echo "	-t [avg|acu|per|max|min] : Specific Data Processing"
				echo "		avg: Average Data Processing"
				echo "		acu: Acumulate Data Processing"
				echo "		per: Percentage Data, Average Processing (Default)"
				echo "		max|min: Get only Maximun/Minimun Value of date group" 
				echo "	-k [value] : transform percen referenced data with real data"
				echo "		[value] : 100% link max value"
				echo
				echo "FILTER:"
				echo "	-d [date format], start date or range to filter by date:"
				echo "		[YYYY]: ask for complete year"
				echo "		[Mmm-YYYY]: ask for concrete month"
				echo "		year: ask for last year"
				echo "		month: ask for last month"
				echo "		week: ask for last week"
				echo "		[0-9*]day: ask for last n days ( sort by 24h format"
				echo "		[0-9*]day: ask for last n hours ( sort by hour format"
				echo "		report: ask for year,month,week,day"
				echo "		[YYYY-MM-DD]: Implies data from date to now if you dont use -e"
				echo "	-e [YYYY-MM-DD], end date for concrete start date" 
				echo "		mandatory use the same format with -d parameter"
				echo
				echo "SHOW:"
				echo "	-v [graph|human|wiki|commas] optional, commas default."
				echo "		graph, show console graph, only for percent processing sensors"
				echo "		human, show command output human friendly"
				echo "		commas, show command output with ;"
				echo "		wiki, show command output with dokuwiki format"
                                echo "		-w [hidden,W[0-9],[Tbar|Tline|Tpie]] : only with wiki output, use hidden plugin with graph"
                                echo "			hidden: Generates hidden section"       
                                echo "			W[0-9]: Defines wide size (recomended threshold 200~800"
                                echo "			Tbar:   Bar graph"
                                echo "			Tline:  Line graph"
                                echo "			Tpie:   Pie graph"
				echo "			value:  Include values in graph"
				echo
				echo "HELP:"
				echo "	-h [|des] help, this help"
				echo "		des: Detailed Command Help"
				echo
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
#               FUNTIONs                  #
###########################################

calc_data()
{
	_log_stats_data=$( cat $_log_file | 
                                awk -F " : " -v _dr="$_date_filter" -v _tsb="$_par_ds" -v _tse="$_par_de" -v _sf="$_par_itm" -v _tc="$_par_typ" '
                                        BEGIN { 
                                                _to="START" ; 
                                                t=0 ; 
                                                a=1 ; 
						_reg_c="no" ;
                                        } $1 > _tsb && $1 < _tse { 
                                                if ( _dr == "year" ) { _time=strftime("%Y;%m_%b",$1) } ; 
                                                if ( _dr == "month" ) { _time=strftime("%Y-%m_%b;%d",$1) } ; 
                                                if ( _dr == "week" ) { _time=strftime("%Y-%m;%d_%a",$1) } ; 
                                                if ( _dr == "day" ) { _time=strftime("%Y-%m-%d;%Hh",$1) } ; 
                                                if ( _dr == "hour" ) { _time=strftime("%Y-%m-%d;%H:%M",$1) } ; 
						if ( $3 == "DIAGNOSE" ) { gsub(/CHECK /,"",$0) } ;
                                                for (i=3;i<=NF;i++) { 
							split($i,d,"=") ; 
							if ( d[1] == _sf ) { 
								split(d[2],dat," ") ;
								if ( dat[2] ~ "%" ) { 
									gsub("%", "", dat[2]) ; 
									_fld=dat[2] ; 
								} else {
									if ( dat[1] ~ "[0-9]" ) { 
										_fld=dat[1] ;	
									} else {
										_fld=dat[2] ;
									}
								}
								if ( _tc == "per" ) {
									if ( _to != _time ) { 
										print _to"="t/a ; 
										_to=_time ; 
										t=_fld ; 
										a=1 ; 
									} else { 
										t=t+_fld ; 
										a++ ; 
									}
								}
								if ( _tc == "avg" ) {
									if ( _to != _time ) { 
										print _to"="t/a ; 
										_to=_time ; 
										t=_fld ; 
										a=1 ;
									} else { 
										t=t+_fld ; 
										a++ ;
									}
								} 
								if ( _tc == "acu" ) {
									if ( _to != _time ) { 
										print _to"="t ; 
										_to=_time ; 
										t=_fld ; 
									} else { 
										t=t+_fld ; 
									}
								} 
								if ( _tc == "max" ) {
									if ( _to != _time ) {
										print _to"="t ;
										_to=_time ;
										t=_fld ;
									} else {
										if ( t  <= _fld ) { t=_fld }
									}
								}
								if ( _tc == "min" ) {
									if ( _to != _time ) {
										print _to"="t ;
										_to=_time ;
										t=_fld ;
									} else {
										if ( t >= _fld ) { t=_fld }
									}
								_reg_c="yes"
							} 
						} ;
                                        } END { 
                                                if ( _reg_c == "yes" ) { 
							print _to"="t/a ; 
						} else {
							print "no data" ;
						}	
                                        }' | 
                                grep -v START )

}

format_output()
{
        case "$_par_show" in
        graph)      
		[ "$_opt_report" == "yes" ] && echo -e "\nSensor $_par_itm - $_date_filter\n-------------------"
                echo "${_log_stats_data}" | 
                                awk -F\; -v _g="$_sh_color_green" -v _r="$_sh_color_red" -v _y="$_sh_color_yellow" -v _n="$_sh_color_nformat"  -v _tc="$_par_typ" -v _vr="$_par_ref" '
					BEGIN { 
						if ( _tc == "per" ) { _us="%" }
					}
                                        { 
                                                split($2,a,"=") ; 
                                                split(a[2],b,".") ; 
                                                if ( b[1] > 30 ) {
                                                        split(b[1]/1.5,y,".")
                                                        split(b[1]/1.02,r,".")
                                                } else {
                                                        y[1]=20
                                                        r[1]=40
                                                }
						if ( _tc == "per" && _vr ~ "[0-9]+" ) { _ref=(b[1]*_vr)/100 ; _ref="["_ref"]" } ;
                                                if ( b[1] <= 50 ) { _tp=_g""b[1]_us" "_ref" "_n ; hp=a[1] } ;
                                                if ( b[1] > 50 ) { _tp=_y""b[1]_us" "_ref" "_n ; hp=a[1] } ; 
                                                if ( b[1] > 75 ) { _tp=_r""b[1]_us" "_ref" "_n ; hp=_r""a[1]_n } ; 
                                                for (i=1;i<=b[1];i++) { 
                                                        if ( i == 1 ) { _t=_g } ;
                                                        if ( i == y[1] ) { _t=_t""_n""_y } ;
                                                        if ( i == r[1] ) { _t=_t""_n""_r } ;
                                                        _t=_t"#" ; 
                                                        if ( i == b[1] ) { _t=_t""_n } ;
                                                        } ; 
                                                if ( _do != $1 ) { _do=$1 ; _pdo=_do } else { _pdo=" " } ; 
                                                printf "%-12s %-3s::%-s %-s\n",_pdo, hp, _t, _tp ; 
                                                _t="" 
                                        }' 
        ;;
	wiki)

                [ -z "$_graph_color" ] && _graph_color=$( echo $_color_graph | sed -e 's/^@//' -e 's/\:$//' )
                [ -z "$_opt_with" ] && _opt_with="650"
                [ -z "$_opt_gtype" ] && [ "$_opt_gtype" != "bar" ] && [ "$_opt_gtype" != "line" ] && [ "$_opt_gtype" != "pie" ] && _opt_gtype="line"

		case "$_par_itm" in
		OPER_ENV)
			_itm_stg="System Availibility"
			_sen_graph_color=$( echo $_color_ok | sed -e 's/^@//' -e 's/\:$//' )
		;;
		SLURM_LOAD)
			_itm_stg="Slurm Activity"
		;;
		USR_LGN)
			_itm_stg="Connected Users"
		;;
		NOD_LOAD)
			_itm_stg="System CPU Use"
		;;
		*)
			_itm_stg=$_par_itm
		;;
		esac

		[ -z "$_sen_graph_color" ] && _sen_graph_color="#"$( echo $_par_itm | hexdump -e '16/1 "%x" "\n"' | sed 's/.*\(......\)$/\1/' )

		_wiki_output=$( echo "<gchart "$_opt_with"x350 $_opt_gvalue $_opt_gtype $_sen_graph_color #ffffff center>" ;
                echo "${_log_stats_data}" | 
                                awk -F\; '
                                        { 
                                                split($2,a,"=") ; 
                                                split(a[2],b,".") ; 
						gsub("^.*-", "", $1) ;
                                                if ( _do != $1 ) { _do=$1 ; _pdo=_do"_" } else { _pdo=" " } ; 
                                                print _pdo a[1]"="b[1] ; 
                                                _t="" 
                                        }' ; 
		echo "</gchart>" )

		if [ "$_opt_report" == "yes" ]
		then
			case "$_date_filter" in 
			hour)
				[ "$_opt_hidden" == "yes" ] && echo "<hidden $_par_nod - $_itm_stg >"
				_wiki_report_output="|<100%  50% 50%>|\n|  $_color_title Source: $_par_nod - $_itm_stg ($_par_typ)  ||\n|  Last Hour  |  Last 24 Hours  |\n|  "$_wiki_output
			;;
			day)
				_wiki_report_output=$( echo "${_wiki_report_output} | ${_wiki_output}" )
			;;
			month)
				_wiki_report_output=$_wiki_report_output"  |\n|  Last 30 Days  |  Last Year  |\n|  "$_wiki_output
			;;
			year)
				_wiki_report_output=$_wiki_report_output"  |  "$_wiki_output"  |" 
				echo -e "${_wiki_report_output}" 
				[ "$_opt_hidden" == "yes" ] && echo "</hidden>"
			;;
			esac
		else
				echo "${_wiki_output}"
		fi

	;;
	debug)
		echo "DEBUG:"
		echo
		echo "${_log_stats_data}"
		echo
		echo "END DEBUG"
	;;
	human)
		[ "$_opt_report" == "yes" ] && echo -e "\nSensor $_par_itm - $_date_filter\n-------------------"
                echo "${_log_stats_data}" | tr '=' ';' | sed -e 's/;/\-/' -e 's/_[A-Z][a-z][a-z]//' | column -t -s\; 
	;;
        commas|*) 
		[ "$_opt_report" == "yes" ] && echo -e "\nSensor $_par_itm - $_date_filter\n-------------------"
               
		if [ "$_opt_ref" == "yes" ] 
		then
			echo "${_log_stats_data}" | tr '=' ';' | sed -e 's/;/\-/' -e 's/_[A-Z][a-z][a-z]//' | awk -F\; -v _rf="$_par_ref" '{ _orf=($2*_rf)/100 ; print $1";"$2";"_orf }' 
		else
			echo "${_log_stats_data}" | tr '=' ';' | sed -e 's/;/\-/' -e 's/_[A-Z][a-z][a-z]//'  
		fi
		
        ;;
        esac

}


debug()
{
	echo 
	echo "DEBUG:"
	echo "----------------"
	echo "Thrershold betwen:"
	echo "Start Data: $_par_date_start 00:00:00 ($_par_ds)"
	echo "End Data: $_par_date_end 23:59:59 ($_par_de)"
	echo "Base Dir: $_log_file"
	echo "Audit Type: $( [ -z "$_par_src" ] && echo -n all || echo -n $_par_src )"
	echo "Date Filter: $_date_filter"
	echo "Source:$_par_src"
	echo "Item:$_par_itm"
	echo "Node/Device:$_par_nod"
	echo "$_long"
	echo "Files:"
	echo "${_files}"
	echo "----------------"
	set | grep "^_"
	echo "----------------"
	echo
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
        month)
                #_ask_date=$( date -d "last month" +%Y-%m-%d )
                _ts_date=2592000

                let _par_ds=_date_tsn-_ts_date
                _par_de=$_date_tsn

                _date_filter=$_par_date_start
                _par_date_start=$( date -d "last month" +%Y-%m-%d )
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

check_items()
{
	
	case "$_par_nod" in 
	dashboard)
		_sensor_help=$( cat $_log_file | 
					awk -F " : " -v _tsb="$_par_ds" -v _tse="$_par_de" '
					{ 
						_type="unknown"
						for (i=4;i<=NF;i++) { 
							split($i,f,"=") ; 
							if ( f[2] ~ "^[0-9]+" ) { 
								if ( f[2] ~ "^[0-9]+$" ) { _type="numeric:acumulative/maximun values/average" }
								if ( f[2] ~ "%$" ) { _type="percent:percent average" }
								if ( f[2] ~ "^[0-9]+[.][0-9]+$" ) { _type="decimals:acumalative/maximun values/average" }
								if ( f[2] ~ "^[0-9]+w$" ) { _type="watts:watts" }
								print "["f[1]"]:"_type 
							}
						} 
					}' | sort -u )
	;;
	*)
		_sensor_help=$( cat $_log_file | 
					awk -F " : " -v _tsb="$_par_ds" -v _tse="$_par_de" '
					{ 
						_type="unknown"
						for (i=4;i<=NF;i++) { 
							split($i,f,"=") ; 
							split(f[2],d," ") ; 
							if ( d[2] ~ "^[0-9]+" ) { 
								if ( d[2] ~ "^[0-9]+$" ) { _type="numeric:acumulative/maximun values/average" }
								if ( d[2] ~ "%$" ) { _type="percent:percent average" }
								if ( d[2] ~ "^[0-9]+[.][0-9]+$" ) { _type="decimals:acumalative/maximun values/average" }
								if ( d[2] ~ "^[0-9]+w$" ) { _type="watts:watts" }
								print "["f[1]"]:"_type 
							}
						} 
					}' | sort -u )
	;;
	esac

	echo
	echo -e "Available Sensors\n"
	echo -e "Name:Data Type:Avaliable Processing Data\n----:---------:--------------------------\n${_sensor_help}" | column -t -s\:
	echo

}

###########################################
#               MAIN EXEC                 #
###########################################

	### INIT DEFAULT OPTIONS ####

	case "$_par_nod" in
	cyclops)
		echo "Not Available yet"
		exit 1
	;;
	dashboard)
		_log_file=$_pg_dashboard_log
	;;
	"")
		echo -e "\nNeed Log "$_par_src"name\nUse -h for help\n" 
		exit 1
	;;
	*)
		_log_file=$_mon_log_path"/"$_par_nod".pg.mon.log"
	;;
	esac 

	[ -z "$_par_itm" ] && echo -e "\nNeed Log Item\nUse -h for help\n" && exit 1
	[ -z "$_par_date_start" ]  && _par_date_start="day" && unset _par_date_end
	[ -z "$_par_show" ] && _par_show="graph"

	[ -z "$_par_typ" ] && _par_typ="per"
	[ "$_par_typ" == "avg" ] && [ "$_par_show" == "graph" ] && _par_show="commas"
	[ "$_par_typ" == "acu" ] && [ "$_par_show" == "graph" ] && _par_show="commas"

	if [ "$_par_date_start" == "report" ] 
	then
		_par_date_start="hour\nday\nmonth\nyear" 
		_opt_report="yes" 
	fi

	for _par_date_start in $( echo -e "$_par_date_start" ) 
	do

		init_date

		### LAUNCH ###

		if [ -f "$_log_file" ] 
		then
			if [ "$_par_itm" == "help" ]
			then
				check_items
			else
				calc_data
				format_output
			fi
		else
			echo "Log File not exits, check $_par_nod log"
			exit 1
		fi
		
		[ "$_opt_debug" == "yes" ] && debug

	done
