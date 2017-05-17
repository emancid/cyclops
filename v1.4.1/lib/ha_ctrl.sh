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


ha_check()
{

	_hostname=$( hostname -s )
	_parent_cmd=$@

        _ha_master_host=$( cat $_sensors_sot | grep "^CYC;0006;HA" | cut -d';' -f5 )
        _ha_slave_host=$( cat $_ha_cfg_file | awk -F\; -v _m="$_ha_master_host" '$1 == "ND" && $2 != _m { print $2 }' )
        _ha_role_me=$( cat $_ha_role_file )

        if [ "$_hostname" != "$_ha_master_host" ]
        then
                if [ "$_ha_role_me" == "SLAVE" ]
                then
                        if [ "$_sh_action" == "daemon" ]
                        then
                                exit 0
                        else
				echo "HA CHECK: ENABLED : MASTER CYCLOPS: [$_ha_master_host] : BACKUP : [$_ha_slave_host] : ME=[$_hostname] ROL : [$_ha_role_me] : TRYING REMOTE EXEC : [$_ha_master_host]" 

                                ssh $_ha_master_host $_parent_cmd
                                _exit_code=$?
                                [ "$_exit_code" != "0" ] && echo "ERROR ($_exit_code): please connect to $_ha_master_host to exec the command"
                                exit $?
                        fi
		else
			echo -e "HA CHECK: ENABLED : MASTER CYCLOPS: [$_ha_master_host] : BACKUP : [$_ha_slave_host] : ME=[$_hostname] ROL : [$_ha_role_me] : ABORT EXEC, POSIBLE SPLIT BRAIN"
			exit 1
                fi
        else
                if [ "$_ha_role_me" == "SLAVE" ]
                then
                        [ "$_sh_action" != "daemon" ] && echo -e "WARNING: HA CONFIG ON POSIBLE SPLIT BRAIN SITUATION force MASTER on UPDATER node" 
                        exit 1
		else 
			echo -e "HA CHECK: ENABLED : MASTER CYCLOPS: [$_ha_master_host] : BACKUP : [$_ha_slave_host] : ME=[$_hostname] ROL : [$_ha_role_me] : LOCAL EXEC : [$_hostname]"
                fi
        fi
}
