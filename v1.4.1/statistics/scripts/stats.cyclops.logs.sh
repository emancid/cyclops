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
	[ -f "$_color_cfg_file" ] && source $_color_cfg_file

	[ -f "$_libs_path/ha_ctrl.sh" ] && source $_libs_path/ha_ctrl.sh || _exit_code="112"
	[ -f "$_libs_path/node_ungroup.sh" ] && source $_libs_path/node_ungroup.sh || _exit_code="114"
	[ -f "$_libs_path/init_date.sh" ] && source $_libs_path/init_date.sh || _exit_code="118"
else
        echo "Global config don't exits" 
        exit 1
fi

	_command_opts=$( echo "~$@~" | tr -d '~' | tr '@' '#' | awk -F\- 'BEGIN { OFS=" -" } { for (i=2;i<=NF;i++) { if ( $i ~ /^[a-z] / ) { gsub(/^[a-z] /,"&@",$i) ; gsub(/ $/,"",$i) ; gsub (/$/,"@",$i) }}; print $0 }' | tr '@' \' | tr '#' '@'  | tr '~' '-' ) 
        _command_name=$( basename "$0" )
        _command_dir=$( dirname "${BASH_SOURCE[0]}" )
        _command="$_command_dir/$_command_name $_command_opts"

        case "$_exit_code" in
        111)
                echo "Main Config file doesn't exists, please revise your cyclops installation"
                exit $_exit_code 
        ;;
        112)
                echo "HA Control Script doesn't exists, please revise your cyclops installation"
                exit $_exit_code 
        ;;
        11[3-8])
                echo "Necesary libs files doesn't exits, please revise your cyclops installation"
                exit $_exit_code 
        ;;
        esac

_cyclops_ha=$( awk -F\; '$1 == "CYC" && $2 == "0006" { print $4}' $_sensors_sot )
_par_ref="empty"
_par_src="node"

###########################################
#              PARAMETERs                 #
###########################################

while getopts ":r:d:e:t:f:n:v:w:k:s:xlh:" _optname
do
        case "$_optname" in
		"n")
			# field node [ FACTORY NODE RANGE ] 
			_opt_nod="yes"
			_par_nod=$OPTARG
			_sh_opt=$_sh_opt" -"$_optname" "$OPTARG
		;;
                "e")
			# date end
                        _opt_date_end="yes"
                        _par_date_end=$OPTARG
			_sh_opt=$_sh_opt" -"$_optname" "$OPTARG
                ;;
                "d")
			# date start
                        _opt_date_start="yes"
                        _par_date_start=$OPTARG
			_sh_opt=$_sh_opt" -"$_optname" "$OPTARG
		;;
		"v")
			# format output
			_opt_show="yes"
			_par_show=$OPTARG
			_sh_opt=$_sh_opt" -"$_optname" "$OPTARG
		;;
		"s")
			# log data source
			_opt_src="yes"
			_par_src=$OPTARG	
			_sh_opt=$_sh_opt" -"$_optname" "$OPTARG
		;;
		"k")
			_opt_ref="yes"
			_par_ref=$OPTARG
			_sh_opt=$_sh_opt" -"$_optname" "$OPTARG
		;;
		"r")
			_opt_itm="yes"
			_par_itm=$OPTARG
			_sh_opt=$_sh_opt" -"$_optname" '"$OPTARG"'"
		;;
		"t")
			_opt_typ="yes"
			_par_typ=$OPTARG
			_sh_opt=$_sh_opt" -"$_optname" "$OPTARG
		;;
		"f")
			_opt_fil="yes"
			_par_fil=$OPTARG
			_sh_opt=$_sh_opt" -"$_optname" "$OPTARG
		;;
		"l")
			_opt_loop="yes"
		;;
		"x")
			# DEBUG option
			_opt_debug="yes"
		;;
		"w")
                        _opt_vwiki="yes"
                        _par_vwiki=$OPTARG
			_sh_opt=$_sh_opt" -"$_optname" "$OPTARG

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
				exit 0
			;;
			esac
		;;
		":")
			if [ "$OPTARG" == "h" ]
			then
				echo
				echo "CYCLOPS STATISTICS: CYC LOGS MODULE"
				echo
				echo "MAIN:"
				echo "	-n [[nodename]|[device]|dashboard|[quota]|[slurm]] item from log to stats"
				echo "		[nodename]: name of desired host to ask data log info"
				echo "		[device]: name of monitoring enviroment device to ask data log info"
				echo "		[slurm]: name of slurm environment configurating in cyclops"
				echo "		[quota]: name of user to get quota data"
				echo "		dashboard: ask for system activity info from cyclops dashboard" 
				echo "	-r [sensor|help] sub-item from log to stats" 
				echo "		sensor: what ever available sensor in monitor module"
				echo "		help: show available sensors for host/node/device"
				echo "	-s [log source]: specify data source"
				echo "		node|env: by default source"
				echo "		quota: quota cyclops service module data source"
				echo "		slurm: slurm cyclops service module data source"
				echo "		dashboard: cyclops monitoring plugin data source"
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
				echo "		[1-9*]year: ask for last [n] year"
				echo "		[1-9*]month: ask for last [n] month"
				echo "		week: ask for last week"
				echo "		[1-9*]day: ask for last [n] days ( sort by 24h format )"
				echo "		[1-9*]hour: ask for last [n] hours ( sort by hour format )"
				echo "		report: ask for year,month,week,day"
				echo "		[YYYY-MM-DD]: Implies data from date to now if you dont use -e"
				echo "	-e [YYYY-MM-DD], end date for concrete start date" 
				echo "		mandatory use the same format with -d parameter"
				echo "	-f [[field1=value1],[field2=vale2],...], one or more log fields with value"
				echo "		you can add one or more field log with a value comma separated"
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
				echo "		-l ,Do loop with 3 mins update life"
				echo
				echo "HELP:"
				echo "	-h [|des] help, this help"
				echo "		des: Detailed Command Help"
				echo
				exit 0
			else
				echo "ERR: Use -h for help"
				exit 0 
			fi
		;;
		"*")
			echo "ERR: Use -h for help"
			exit 0 
		;;
	esac
done

shift $((OPTIND-1))

###########################################
#               FUNTIONs                  #
###########################################

calc_data()
{
	_log_stats_data=$( cat $_log_file | sort -t\; -n | 
        			awk -F " : " -v _dr="$_date_filter" -v _tsb="$_date_tsb" -v _tse="$_date_tse" -v _sf="$_par_itm" -v _tc="$_par_typ" -v _pf="$_par_fil" '
                                        BEGIN { 
                                                _to="START" ; 
                                                t=0 ; 
                                                a=1 ; 
						_reg_c="no" ;
						_tf=split(_pf,ff,",") ;
						_mod=_tc
                                        } $1 > _tsb && $1 < _tse { 
                                                if ( _dr == "year" ) { _time=strftime("%Y;%m_%b",$1) } ; 
                                                if ( _dr == "month" ) { _time=strftime("%Y-%m_%b;%d",$1) } ; 
                                                if ( _dr == "week" ) { _time=strftime("%Y-%m;%d_%a",$1) } ; 
                                                if ( _dr == "day" ) { _time=strftime("%Y-%m-%d;%Hh",$1) } ; 
                                                if ( _dr == "hour" ) { _time=strftime("%Y-%m-%d;%H:%M",$1) } ; 
						if ( $3 == "DIAGNOSE" ) { gsub(/CHECK /,"",$0) } ;
						_fe=0 ; _fet=0 ; _cm=0 ; _ofc=0 ; _of=0
                                                for (i=3;i<=NF;i++) { 
							split($i,d,"=") ; 
							if ( d[1] == _sf ) { 
								_ofc=d[2] ; 
								_fe=1 ; 
							}
							if ( _tf > 0 ) {
								for (m=1;m<=_tf;m++) {
									if ( $i == ff[m] ) { _cm++ }
								}
								if ( _cm == _tf && _fe == 1 ) { _fet=1 ; _of=_ofc ; break }
							} else { 
								if ( _fe == 1 ) { _fet=1 ; _of=_ofc ; break }
							}
						}
						if ( _fet == 1 ) { 
							split(_of,dat," ") ;
							if ( dat[1] ~ "%" ) { gsub("%", "", dat[1]) } ; 
							if ( dat[2] ~ "%" ) { gsub("%", "", dat[2]) } ; 
							if ( dat[2] ~ "d$" ) { gsub("d", "", dat[2]) ; if ( _tc != "min" || _tc != "max" ) { _tc="max" } } ;

							if ( dat[2] ~ "^[0-9]+$" ) { 
								_fld=dat[2] ; 
							} else {
								if ( dat[1] ~ "^[0-9]+$" ) { 
									_fld=dat[1] ;	
								} else {
									if ( dat[2] ~ "/" ) {
										split(dat[2],io,"/") ;
										_tc="io" ;
									} else {
										_fld=0
									}
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
							if ( _tc == "io" ) {
								if ( _to != _time ) {
									if ( _mod == "avg" || _mod == "per" ) { print _to"="int(_in/a)"/"int(_ou/a) } 
									if ( _mod == "max" || _mod == "min" || _mod == "acu" ) { print _to"="_in"/"_ou }
									_to=_time ;
									_in=io[1] ;
									_ou=io[2] ;
									a=1 ;
								} else { 
									if ( _mod == "avg" || _mod == "per" || _mod == "acu" ) {
										_in=_in+io[1] ;
										_ou=_ou+io[2] ;
										a++ ;
									}
									if ( _mod == "max" ) { 
										if ( _in <= io[1] ) { _in=io[1] }
										if ( _ou <= io[2] ) { _ou=io[2] }
									}
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
							}
							_reg_c="yes" ;
						} ;
                                        } END { 
                                                if ( _reg_c == "yes" ) { 
							if ( _tc == "io" ) { 
								print _to"="int(_in/a)"/"int(_ou/a)
							} else {
								print _to"="t/a ; 
							}
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

		_tml=$( echo "${_log_stats_data}" | awk -F\; '
			BEGIN { 
				_tml=0 
			} { 
				split($2,a,"=") ; 
				if ( a[2] ~ "/" ) { 
					split(a[2],b,"/") ; 
					if ( b[1] >= b[2] ) { 
						_tst=b[1] 
					} else { 
						_tst=b[2] 
					} 
				} else {
					_tst=a[2]
				} 
			}  _tml <= _tst { 
				_tml=_tst 
			} END { 
				print _tml 
			}' )
		[ -z "$_tml" ] && echo "no data" && exit 0 
                echo "${_log_stats_data}" | 
                                awk -F\; -v _ss="$( tput cols )" -v _tl="$_tml"  -v _g="$_sh_color_green" -v _r="$_sh_color_red" -v _y="$_sh_color_yellow" -v _n="$_sh_color_nformat"  -v _tc="$_par_typ" -v _vr="$_par_ref" '
					BEGIN { 
						if ( _tl > 100 || _ss < 100 ) { _lng=_ss-40 } else { _lng=100 ; _tl=100 } ;
					} {
                                                split($2,a,"=") ; 
						if ( a[2] ~ "/" ) {
							split(a[2],io,"/")
							if ( io[1] > io[2] ) {
								_dat=int((io[1]*_lng)/_tl)
								_rdat=int(io[1])
								if ( io[2] <= 1  ) { _gr=2 } else { _gr=io[2] }
								hp=_g""a[1]""_n
								_rr=1
							} else {
								_dat=int((io[2]*_lng)/_tl)
								_rdat=int(io[2])
								if ( io[1] <= 1 ) { _rr=1 } else { _rr=io[1] }
								hp=_r""a[1]""_n
								_gr=1
							}
							_tp=io[1]"%/"io[2]"%"
						} else { 
							_gr=1
							_dat=int((a[2]*_lng)/_tl)
							_rdat=int(a[2])
							if ( _dat > 30 ) {
								_yr=int(_dat/1.5)
								_rr=int(_dat/1.02)
							} else {
								_yr=20
								_rr=40
							}
							if ( _tc == "per" && _vr ~ "[0-9]+" ) { _ref=(_rdat*_vr)/100 ; _ref="["_ref"]" } else { _ref="" };
							if ( _dat <= 50 ) { _fnc=_g ; hp=a[1] } ;
							if ( _dat > 50 ) {  _fnc=_y ; hp=a[1] } ; 
							if ( _dat > 75 ) {  _fnc=_r ; hp=_r""a[1]_n } ; 
						}
                                                for (i=1;i<=_lng;i++) { 
                                                        if ( i == _gr ) { _t=_t""_n""_g } ;
                                                        if ( i == _yr ) { _t=_t""_n""_y } ;
                                                        if ( i == _rr ) { _t=_t""_n""_r } ;
                                                        _t=_t"|" ;  
                                                        if ( i >= _dat ) { _t=_t""_n ; break } ;
                                                        } ; 
                                                if ( _do != $1 ) { _do=$1 ; _pdo=_do } else { _pdo=" " } ; 
                                                printf "%-12s %-3s::%-s %s%'"'"'.0f%s %s\n",_pdo, hp, _t, _fnc, _rdat, _n, _ref; 
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
                                awk -F\; -v _vr="$_par_ref" '
                                        { 
                                                split($2,a,"=") ; 
						gsub("^.*-", "", $1) ;
                                                if ( _do != $1 ) { _do=$1 ; _pdo=_do"_" } else { _pdo=" " } ; 
						if ( _vr ~ "[0-9]+" ) { a[2]=(a[2]*_vr)/100 } ;
                                                split(a[2],b,".") ; 
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

check_items()
{
	
	case "$_par_src" in 
	dashboard)
		_sensor_help=$(	awk -F " : " -v _tsb="$_date_tsb" -v _tse="$_date_tse" '
					$1 > _tsb && $1 < _tse { 
						_type="unknown"
						for (i=4;i<=NF;i++) { 
							split($i,f,"=") ; 
							if ( f[2] ~ "^[0-9]+" ) { 
								if ( f[2] ~ "^[0-9]+$" ) { field[f[1]]="numeric:acumulative/maximun values/average" }
								if ( f[2] ~ "[0+9]+%$" ) { field[f[1]]="percent:percent average" }
								if ( f[2] ~ "^[0-9]+[.][0-9]+$" ) { field[f[1]]="decimals:acumalative/maximun values/average" }
								if ( f[2] ~ "^[0-9]+w$" ) { field[f[1]]="watts:watts" }
								if ( f[2] ~ "/" ) { field[f[1]]="percent:input/output values" }
							} else {
								if ( field[f[1]] != "" ) { filter[f[1]]="corrupt:any bad data on this field" } else { filter[f[1]]="char:field only for filter" }
							}
						} 
					} END {
						for ( a in field ) {
							if ( field[a] != "" ) { printf "[ %-12s ]:%s\n", a, field[a] } 
						}
						for ( b in filter ) {
							if ( filter[b] != "" ) { printf "[ %-12s ]:%s\n", b, filter[b] } 
						}
					}' $_log_file )
	;;
	slurm|quota)
		_sensor_help=$(	awk -F " : " -v _tsb="$_date_tsb" -v _tse="$_date_tse" '
					$1 > _tsb && $1 < _tse {
						_type="unknown"
						for (i=5;i<=NF;i++) { 
							split($i,f,"=") ; 
							if ( f[2] ~ "^[0-9]+" ) { 
								if ( f[2] ~ "^[0-9]+$" ) { field[f[1]]="numeric:acumulative/maximun values/average" }
								if ( f[2] ~ "[0-9]+%$" ) { field[f[1]]="percent:percent average" }
								if ( f[2] ~ "^[0-9]+[.][0-9]+$" ) { field[f[1]]="decimals:acumalative/maximun values/average" }
								if ( f[2] ~ "^[0-9]+w$" ) { field[f[1]]="watts:watts" }
								if ( f[2] ~ "/" ) { field[f[1]]="percent:input/output values" }
							} else {
								if ( field[f[1]] != "" ) { filter[f[1]]="corrupt:any bad data on this field" } else { filter[f[1]]="char:field only for filter" }
							}
						}
					} END {
						for ( a in field ) {
							if ( field[a] != "" ) { printf "[ %-12s ]:%s\n", a, field[a] } 
						}
						for ( b in filter ) {
							if ( filter[b] != "" ) { printf "[ %-12s ]:%s\n", b, filter[b] } 
						}
					}' $_log_file )
	;;
	*)
		_sensor_help=$(	awk -F " : " -v _tsb="$_date_tsb" -v _tse="$_date_tse" '
					$1 > _tsb && $1 < _tse { 
						_type="unknown"
						for (i=4;i<=NF;i++) { 
							split($i,f,"=") ; 
							split(f[2],d," ") ; 
							if ( d[2] ~ "^[0-9]+" || d[2] == "" ) { 
								if ( d[2] ~ "^[0-9]+$" ) { filter[f[1]]="numeric:acumulative/maximun values/average" }
								if ( d[2] ~ "[0-9]+%$" ) { filter[f[1]]="percent:percent average" }
								if ( d[2] ~ "^[0-9]+[.][0-9]+$" ) { filter[f[1]]="decimals:acumalative/maximun values/average" }
								if ( d[2] ~ "^[0-9]+w$" ) { filter[f[1]]="watts:watts" }
								if ( d[2] ~ "/" ) { field[f[1]]="percent:input/output values" }
							} else {
								if ( field[f[1]] != "" ) { filter[f[1]]="corrupt:any bad data on this field" } else { filter[f[1]]="char:field only for filter" }
							}
						}
					} END {
						for ( a in field ) {
							if ( field[a] != "" ) { printf "[ %-12s ]:%s\n", a, field[a] } 
						}
						for ( b in filter ) {
							if ( filter[b] != "" ) { printf "[ %-12s ]:%s\n", b, filter[b] } 
						}
					}' $_log_file )
	;;
	esac

	_sensor_help=$( echo -e "${_sensor_help}" | sort -t\: -k2 )

	echo
	echo -e "Available Sensors\n"
	echo -e "Name:Data Type:Avaliable Processing Data\n-------------:---------:--------------------------\n${_sensor_help}" | column -t -s\:
	echo

}

###########################################
#               MAIN EXEC                 #
###########################################

	############### HA CHECK ##################

	[ "$_cyclops_ha" == "ENABLED" ] && ha_check $_command

	### LOOP LAUNCH ###

	if [ "$_opt_loop" == "yes" ]
	then
		_sh_opt=$( echo "$_sh_opt" )
		_me=$( basename "$0" )
		_end_message="Push Ctrl+C to End Loop"

		while true 
		do
			clear
			echo -e "$( date +%FT%T )\nLOOP $_me\nWITH OPTIONS : $_sh_opt\n"
			_output=$( eval exec $_me $_sh_opt )
			echo "${_output}"
			echo -e "\n$_end_message"
			sleep 3m

		done
			
	else
		### INIT DEFAULT OPTIONS ####

		case "$_par_nod" in
		cyclops)
			echo "Not Available yet"
			exit 41
		;;
		dashboard)
			_par_src=$_par_nod

		;;
		"")
			echo -e "\nNeed Log "$_par_src"name\nUse -h for help\n" 
			exit 42 
		;;
		esac 

		case "$_par_src" in
		dashboard)
			_log_file=$_pg_dashboard_log
		;;
		slurm)
			_log_file=$_srv_slurm_logs"/"$_par_nod".sl.mon.log"
		;;
		quota)
			_quota_srv=$( echo $_par_nod | cut -d'.' -f1 )
			_par_nod=$( echo $_par_nod | cut -d'.' -f2 )
			_log_file=$_srv_quota_logs"/"$_par_nod".qt.mon.log"
		;;	
		node|env)
			_log_file=$_mon_log_path"/"$_par_nod".pg.mon.log"
		;;
		*)
			_log_file=$_mon_log_path"/"$_par_nod".pg.mon.log"
			#_log_file=$( node_ungroup $_par_nod | tr ' ' '\n' | awk -v _p="$_mon_log_path" -v _s=".pg.mon.log" '{ print _p"/"$0 _s }' )
		;;
		esac

		if [ ! -f "$_log_file" ]
		then
			echo "ERR: No exist data source!"
			echo "	source type: [$_par_src]"
			echo "	source item: [$_par_nod]"
			echo
			echo "Please use -h for help"
			exit 1
		fi

		[ -z "$_par_itm" ] && echo -e "\nNeed Log Item\nUse -h for help\n" && exit 43 
		[ -z "$_par_date_start" ]  && _par_date_start="day" && unset _par_date_end
		[ -z "$_par_show" ] && _par_show="graph"

		[ -z "$_par_typ" ] && _par_typ="per"
		#[ "$_par_typ" == "avg" ] && [ "$_par_show" == "graph" ] && _par_show="commas"
		#[ "$_par_typ" == "acu" ] && [ "$_par_show" == "graph" ] && _par_show="commas"

		if [ "$_par_date_start" == "report" ] 
		then
			_par_date_start="hour\nday\nmonth\nyear" 
			_opt_report="yes" 
		fi

		for _par_date_start in $( echo -e "$_par_date_start" ) 
		do

			init_date $_par_date_start $_par_date_end 

			### LAUNCH ###

			#if [ -f "$_log_file" ] 
			#then
				if [ "$_par_itm" == "help" ]
				then
					check_items
				else
					calc_data
					format_output
				fi
			#else
			#	echo "Log File not exits, check $_par_nod log"
			#	exit 1
			#fi
			
			[ "$_opt_debug" == "yes" ] && debug

		done
	fi

exit 0
