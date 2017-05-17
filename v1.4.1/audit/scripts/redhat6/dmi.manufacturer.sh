#!/bin/bash

_prefix="10;dmi manufacturer"
_order="10"
_dmi_manufacturer=$( dmidecode  | grep -A 4 "^System Information$" | sed 's/^ *//' | awk '{ if ( NR == 1 ) { _seccion=$0 } else { print _seccion";"$0 }}' | tr -d '\t'  | sed -e 's/: /;/' )

if [ ! -z "$_dmi_manufacturer" ] 
then
	echo "${_dmi_manufacturer}" | sed -e "s/^/$_prefix;$_order;/"
fi
