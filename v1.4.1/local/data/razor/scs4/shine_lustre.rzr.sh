#!/bin/bash
##### RAZOR RESOURCE CTRL CONFIG FILE ####

_rsc_rzr_nam="shine_lustre"
_rsc_rzr_des="Cyclops Local Shine Lustre Client Mounts Ctrl Razor"
_rsc_rzr_cmd="/usr/sbin/shine"
_rsc_rzr_dae=""
_rsc_rzr_cfg=""
_rsc_rzr_out_cod="119"
_rsc_rzr_hostname=$( hostname -s )

[ ! -f "$_rsc_rzr_cmd" ] && exit $_rsc_rzr_out_cod

case "$1" in
	check)
		_rsc_rzr_lustre_MDT=$( 
			$_rsc_rzr_cmd -O %type";"%servers config | 
			grep MDT | 
			cut -d';' -f2 | 
			head -n1 
			)
		_rsc_rzr_lustre_OST=$( 
			$_rsc_rzr_cmd -O %type";"%servers config | 
			grep OST | 
			cut -d';' -f2 |
			head -n1 
			)
		_rsc_rzr_out_cod=$( 
			$_rsc_rzr_cmd  -O %type";"%servers";"%status -H status -n $_rsc_rzr_lustre_MDT 2>/dev/null | 
			awk -F\; 'BEGIN { _fail="11" } $1 ~ "MDT" && $3 == "online" { _fail="0" } END { print _fail }' ) 
		[ "$_rsc_rzr_out_cod" == "0" ] && _rsc_rzr_out_cod=$( 
			$_rsc_rzr_cmd  -O %type";"%servers";"%status -H status -n $_rsc_rzr_lustre_OST 2>/dev/null | 
			awk -F\; 'BEGIN { _fail="12" } $1 ~ "OST" && $3 == "online" { _fail="0" } END { print _fail }' )
		[ "$_rsc_rzr_out_cod" == "0" ] && _rsc_rzr_out_cod=$(
			$_rsc_rzr_cmd -O %fsname";"%status -H status -n $_rsc_rzr_hostname 2>/dev/null |
			sed '/^$/d' |
			grep ";" |
			awk -F\; 'BEGIN { _fail="0" } $2 != "mounted" { _fail="13" } END { print _fail }'
			)
	;;
	start|link|up|repair)
		sleep 5s
		_rsc_rzr_out_cod=$(
			$_rsc_rzr_cmd -O %fsname";"%status -H mount -n $_rsc_rzr_hostname 2>/dev/null | 
			sed '/^$/d' | 
			grep ";" | 
			awk -F\; 'BEGIN { _fail="0" } $2 != "mounted" { _fail="1" }  END { print _fail }'
			)
	;;
	stop|unlink)
                _rsc_rzr_out_cod=$(
                        $_rsc_rzr_cmd -O %fsname";"%status -H umount -n $_rsc_rzr_hostname 2>/dev/null | 
                        sed '/^$/d' | 
                        grep ";" | 
                        awk -F\; 'BEGIN { _fail="1" } $2 != "mounted" { _fail="0" } END { print _fail }'
                        )
	;;
	drain|diagnose|boot|init|info|reset|reboot|content)
		_rsc_rzr_out_cod="21"
	;;
esac

[ -z "$_rsc_rzr_out_cod" ] && _rsc_rzr_out_cod="19"

exit $_rsc_rzr_out_cod
