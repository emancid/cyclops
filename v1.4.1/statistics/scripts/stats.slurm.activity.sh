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
        [ -f "$_libs_path/node_group.sh" ] && source $_libs_path/node_group.sh || _exit_code="116"
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
        11[3-4])
                echo "Necesary libs files doesn't exits, please revise your cyclops installation"
                exit $_exit_code
        ;;
        esac

_cyclops_ha=$( awk -F\; '$1 == "CYC" && $2 == "0006" { print $4}' $_sensors_sot )

_stat_slurm_data=$( cat $_stat_main_cfg_file | awk -F\; '$2 == "slurm" { print $0 }' | head -n 1 )
_stat_slurm_cfg_file=$_config_path_sta"/"$( echo $_stat_slurm_data | cut -d';' -f3 )
_stat_slurm_data_dir=$_stat_data_path"/"$( echo $_stat_slurm_data | cut -d';' -f4 )

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
		"d")
			_opt_date_start="yes"
			_par_date_start=$OPTARG
		;;
		"e")
			_opt_date_end="yes"
			_par_date_end=$OPTARG
		;;
		"j")
			_opt_job="yes"
			_par_job=$OPTARG
		;;
		"m")
			_opt_nam="yes"
			_par_nam=$OPTARG
		;;
		"f")
			_opt_fil="yes"
			_par_fil=$OPTARG
		;;
		"s")
			_opt_src="yes"
			_par_src=$OPTARG
		;;
                ":")
                        if [ "$OPTARG" == "h" ]
                        then
                                echo 
				echo "CYCLOPS STATISTICS: CYC SLURM DATA ACCESS"
				echo
				echo "MAIN:"
				echo
				echo "	-s [slurm cluster source], name of data source"
				echo
				echo "FILTER:"
				echo "	-n [nodename|node range], by node or node range" 
				echo "	-j [slurm num job], by slurm number job"
				echo "	-m [slurm job name], by slurm job name" 
                                echo "  -d [date format], start date or range to filter by date:"
                                echo "          [YYYY]: ask for complete year"
                                echo "          [Mmm-YYYY]: ask for concrete month"
                                echo "          [1-9*]year: ask for last [n] year"
                                echo "          [1-9*]month: ask for last [n] month"
                                echo "          week: ask for last week"
                                echo "          [1-9*]day: ask for last [n] days ( sort by 24h format )"
                                echo "          [1-9*]hour: ask for last [n] hours ( sort by hour format )"
                                echo "          [YYYY-MM-DD]T[HH:MM:SS]: Implies data from date to now if you dont use -e, optional start time can be added"
                                echo "  -e [YYYY-MM-DD]T[HH:MM:SS], end date for concrete start date, optional end time can be added" 
                                echo "          mandatory use the same format with -d parameter"
				echo "SHOW:"
				echo
				echo "	-f [field1,field2,field3,...], output selected fields"
                                echo "  -v [graph|human|wiki|commas] optional, commas default."
                                echo "          graph, show console graph, only for percent processing sensors"
                                echo "          human, show command output human friendly"
                                echo "          commas, show command output with ;"	
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

search_jobs()
{

	awk -F\; -v _tsdatei="$_date_tse" -v _tsdatef="$_date_tsb" '
		{ 
			_ts=strftime("%FT%T",$1) ; 
			gsub(/:/," ",$13) ; 
			_tsplus=mktime( "1970 01 01 "$13 ) ; 
			_tsrange=$1+_tsplus  
		} ( $1 < _tsdatei && _tsrange > _tsdatef ) || ( $1 < _tsdatef && _tsrange > _tsdatef ) || ( $1 > _tsdatei && _tsrange < _tsdatef )  { 
			print _ts";"$2";"$14";"$3";"$5";"$13";"$15 
		}' $1
}

format_output_data()
{
	echo -e "${1}"
}

debug()
{
        echo
        echo "DEBUG:"
        set | grep "^_"
        echo "-----"
}

###########################################
#               MAIN EXEC                 #
###########################################


	## DATE INIT

	case "$_par_date_start" in 
	*year|*month|week|*day|*hour|[A-Z][a-z][a-z]"-"[0-9][0-9][0-9][0-9])
	;;
	"")
		_par_date_start="day"
	;;
	"*")
		[ -z "$_par_date_end" ] && _par_date_end=$( date +%Y-%m-%d ) && _par_date_time=$( date +%H:%M:%S )
	;;
	esac
	 

	init_date $_par_date_start $_par_date_end

	## DATA FILES SELECTION

	_files=$( ls -1 $_stat_slurm_data_dir/$_par_src/*.txt | awk -F\/ -v _ds="$_date_tsb" -v _de="$_date_tse" '
	{
		split ($NF,a,".") ;
		if ( a[2] != "12" ) {
			_next_m=a[2]+1 ;
			_next_date=mktime(" "a[1]" "_next_m" 1 0 0 0" ) ;
			_last_day=_next_date-3600 ;
			_last_day=strftime("%d",_last_day) ;
		} else {
			_last_day="31" ;
		}
		_date_s=mktime(" "a[1]" "a[2]" "_last_day" 0 0 0") ;
		_date_e=mktime(" "a[1]" "a[2]" 1 0 0 0") ;
		if ( _date_s >= _ds && _date_e <= _de ) { print $0 }
	}' ) 

	## PROCESSING

	for _file in $( echo "${_files}" )
	do
		_data_output=$_date_output"\n"$( search_jobs $_file )	
	done

	## FORMATING

	format_output_data "$_data_output"
	#echo "${_data_output}"

exit 0
