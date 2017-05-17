#!/bin/bash

### FIRTS CYCLOPS FUNCTION LIBRARY #### 2016-11-03
### NODE GRUPING - GIVE LIST OF NODES COMMA SEPARATED

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

### FUNCTION ####


node_ungroup()
{
	_node_u_prefix=$( echo $1 | cut -d'[' -f1 | sed 's/[0-9]*$//' )
	_node_u_range=$( echo $1 | sed -e "s/$_node_u_prefix\[/{/" -e 's/\([0-9]*\)\-\([0-9]*\)/\{\1\.\.\2\}/g' -e 's/\]$/\}/' -e "s/$_node_u_prefix\([0-9]*\)/\1/"  )
	_node_u_values=$( eval echo $_node_u_range | tr -d '{' | tr -d '}' )

	 echo "${_node_u_values}" | tr ' ' '\n' | sed "s/^/$_node_u_prefix/"
}

