#!/bin/bash

IFS="
"

_node_prefix="hostname" ## hostname prefix 
_tool_log="/root/cyclops/monitor/tools/cg_state/cgstate.log"
_old_check="/root/cyclops/monitor/tools/cg_state/old_check.txt"
_new_check="/root/cyclops/monitor/tools/cg_state/new_check.txt"
_error_output="/root/cyclops/monitor/tools/cg_state/error.output"

if [ -f $_old_check ]
then
        touch $_old_check
fi

echo -e "\n=========================================================" >> $_tool_log
echo -e "SLURM CG TRIGGER ON: `date +%Y-%m-%dT%H:%M:%S` BEGGING CHECK" >> $_tool_log

        for _nodo in $(cat /etc/cyclops/node.type.cfg | grep ';compute;' | cut -d ';' -f2)
        do
                squeue -w $_nodo -o "%P;$_nodo;%A;%.8j;%u;%D;%M;%t;%r" | grep -v "^PARTITION"
        done > $_new_check

        for _register in `cat $_new_check`
        do

                if [ -z $_register ]
                then
                        echo "CHECK: `date +%Y-%m-%dT%H:%M:%S` NO RUNNING JOBS" >> $_tool_log
                fi

                _partition=`echo $_register | cut -d';' -f1`
                _node=`echo $_register | cut -d';' -f2`
                _job_id=`echo $_register | cut -d';' -f3`
                _job_name=`echo $_register | cut -d';' -f4`
                _user=`echo $_register | cut -d';' -f5`
                _nnodes=`echo $_register | cut -d';' -f6`
                _time_elapsed=`echo $_register | cut -d';' -f7`
                _state=`echo $_register | cut -d';' -f8`
                _reason=`echo $_register | cut -d';' -f9`

                if [ "$_state" == "CG" ]
                then
                        _cg_state=`awk -F\; -v _job=$_job_id '$3 == _job && $8 == "CG" { print $0 }' $_old_check | wc -l`
                        if [ $_cg_state -eq 0 ]
                        then
                                echo "CHECK: CG DETECTADO EN $_node NO PROBLEMA (PRIMERA DETECCION EN JOB $_job_id )" >> $_tool_log
                        else
                                echo -e "\n ALERT: `date +%Y-%m-%dT%H:%M:%S` PERSISTENT CG STATE DETECTED\n NODO: "$_node"\n JOB NAME: "$_job_name"\n JOB ID: "$_job_id"\n STATUS: "$_state"\n JOB ELAPSED TIME: "$_time_elapsed"\n OLD STATE: "$_cg_state"\n" >> $_tool_log
                                echo -e "ALERTA: `date +%Y-%m-%dT%H:%M:%S` ESTADO DE JOB CG PERSISTENTE DETECTADO\n ACCION: $_node SE LE ACTIVA PURGA CON RUNLEVEL 1\n - 10 Minutos" | mail -s "ALERTA OPERATIVA EN $_node_prefix" -S smtp="zabbix.aemet.es:25" admonunix@aemet.es,rcorredora@aemet.es,aalvarezg@aemet.es,tshpc2@aemet.es,tshpc1@aemet.es

                                echo -e "\n ACCION: $_node Lanzando Runlevel 1 > Esperando 10 minutos > Lanzando Runlevel 3\n" >> $_tool_log
				let "_mesg_death=$( date +%s ) + 3600"
				_mesg_death=$( date -d @$_mesg_death +%Y%m%d\ %H%M )
				/opt/cyclops/scripts/cyclops.sh -m "WARNING: CG DETECTADO POR HERRAMIENTA DE AUTO-REPARACION, SOLUCIONANDO EL PROBLEMA EN: $_node : IGNORAR LAS ALERTAS VINCULADAS A DICHO NODO DURANTE 15-30 MIN" -p medium -d $_mesg_death -l
				/opt/cyclops/scripts/audit.nod.sh -e event -e ALERT -s FAIL -n $_node -m "TOOL DETECT CG: user $_user job_id $_job_id partition $_partition"
                                ssh $_node "init 1; sleep 10m ; init 3" 2>&1 >> $_tool_log &
                                echo -e "\n" >> $_tool_log

                                #### ACCIONES A REALIZAR #####
                        fi
                else
                        echo "CHECK: JOB $_job_id in $_node NO CG STATE DETECTED" >> $_tool_log
                fi
        done

        cp $_new_check $_old_check 2>/dev/null

echo -e "END TRIGGER PROCESING: `date +%Y-%m-%dT%H:%M:%S`" >> $_tool_log
echo -e "=========================================================\n" >> $_tool_log
