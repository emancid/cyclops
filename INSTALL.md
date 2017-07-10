CYCLOPS 1.4.1v INSTALL
==============================================================================================================


    1.PREPARE NECESSARY ENVIRONMENT
    ----------------------------------------------------------------------------------------------------------

    - install -> git
	- yum install git
    - install -> apache + php + php_gd
        - yum install httpd php php-gd
    - install -> dokuwiki
         [ REDHAT/CENTOS ] - https://www.dokuwiki.org/install:centos
        * Configure symbolic link or right path for apache access to cyclops web interface ( default /opt/cyclops/www )
	* You have in /opt/cyclops/docs a file template ( redhat ) for configurate apache site (is usesfull with other distros)    
	* You can use cyclops default certificates for apache if you want https cryp acces
	* IMPORTANT: disable selinux for right apache behaviour
        * in centOS/redhat6 (optional):
                /var/www/html/ln -s /opt/cyclops/www cyclops 
	* Web access credentials:
		User: admin
		Pass: cyclops
    
    - Recomended packages:
        [ REDHAT/CENTOS ]
            - pdsh
            - sysstat
            - rsync

    2. INSTALL CYCLOPS
    ----------------------------------------------------------------------------------------------------------

    a.FROM TAR:

    - copy cyclops.[version].tgz and untar in /opt
    - untar /opt/cyclops/monitor/packs/*.tar from root directory

    b.FROM GITHUB: 

    - create dir /opt/git
    - cd /opt/git/
    - git clone https://github.com/ikseth/cyclops.git
    - create link in /opt/ 
    - ln -s /opt/git/cyclops/[version] cyclops
    
    3.Create Base Dirs&Files
    ----------------------------------------------------------------------------------------------------------

        groupadd -g 900 cyclops
        useradd -g 900 -b /opt/cyclops/local -u 900 cyclops
        cd /etc ; ln -s /opt/cyclops/etc/cyclops/
  
    4.Configure permissions
    ----------------------------------------------------------------------------------------------------------

        chown -R cyclops:cyclops /opt/cyclops
        chown -R apache /opt/cyclops/www   ## REDHAT DEFAULT APACHE USER , CHANGE IT IF YOU HAS DIFERENT DISTRO OR USER
        
        chmod -R g+w,o-rwx /opt/cyclops/www/

        chmod -R 750 /opt/cyclops/scripts/
        chmod -R 750 /opt/cyclops/tools/
        chmod -R 750 /opt/cyclops/statistics/scripts/
      
    5.Add cyclops PATH to root profile file
    ----------------------------------------------------------------------------------------------------------

        export PATH=$PATH":/opt/cyclops/scripts"        #### CYC MAIN  PATH
        export PATH=$PATH":/opt/cyclops/tools/approved" #### CYC TOOLS PATH

    6.Configurate Cyclops
    ----------------------------------------------------------------------------------------------------------

        1. check /etc/global.cfg.template and after that rename to /etc/global.cfg
        2. check /etc/cyclops/nodes/node.type.cfg.template and rename it to same path with template at end of file.
        3. check /etc/cyclops/nodes/critical.res.cfg.template and rename it to same path without template at end of the file/
    
	4. You can use a cyclops prototipe option for configurate several items of it:
		cyclops -y config
	5. You have the next files for configure cyclops

        /etc/cyclops/
                global.cfg.template *               ## MAIN CFG ( RECOMMENDED NOT CHANGE IF NOT NECESARY) - RENAME IT TO global.cfg 
            ./system
                wiki.cfg.template *                  ## APACHE USR&GRP
                cyclopsrc.template                  ## CYCLOPS profile customize option ( optional )
            ./nodes
                bios.mng.cfg.template               ## IPMITOOL CREDENTIALS
                critical.res.cfg.template           ## CYCLOPS Critical resources monitor option ( optional ) [[BUG - IF NO DATA SHOW NO DATA]]
                name.mon.cfg.template               ## Define monitor sensors groups
                    [CHANGE name with group name], you need create one file per group
                node.type.cfg.template *            ## Define node list and settings [[BUG - IF NO NODES SHOW TOTAL=0]]
            ./environment
                env.devices.cfg.template            ## List of IPMITOOL hardware devices for monitor
                name.env.cfg.template               ## Define monitori sensors groups
                    [CHANGE name with group name], you need create one file per group
            ./monitor
                alert.email.cfg.template            ## Configure non-auth email server and mails for alerts
                monitor.cfg.template *              ## DEFINE MODULES AND GROUPS FOR MONITOR
                plugin.users.ctrl.cfg.template      ## Define support and admin users for monitoring them with this plugin
                procedure.ia.codes.cfg.template     ## NOT TOUCH IF NOT NECESARY - PROCEDURES CODES AND NAMES
            ./security
                login.node.list.cfg.template        ## Define nodes to monitor users in them
            ./services
                name.slurm.cfg.template             ## Define slurm service settings
                    [CHANGE name with slurm environment name], you need create one file per environment
            ./statistics
                main.ext.cfg.template               ## Define slurm stats config file ( )
                main.slurm.ext.cfg.template         ## The name of this file is defined in previous cfg file - Here define slurm env dabase(s)
            ./tools
                tool.b7xx.upgrade.fw.cfg.template   ## ONLY FOR B7xx HARDWARE - Firmware definitions profiles files

	3. Other Important dir&files:
		3.1. Nodes items:
			/opt/cyclops/monitor/sensors/status
				./scripts		## [SENSORS COMPILANCE]/SENSORS FILES ## NECESARY IF YOU WANT TO CREATE NEW ONES OR MODIFY THEM, see .template file for help
				./ia			## IA RULES FILES, see .template file for help
		3.2. Environment items:
			/opt/cyclops/monitor/sensors/environment
				./scripts		## [SENSORS COMPILANCE]/SENSORS FILES ## NECESARY IF YOU WANT TO CREATE NEW ONES OR MODIFY THEM, see .template file for help
				./ia			## IA RULES FILES, see .template file for help
		3.3. Slurm items:
			/opt/cyclops/monitor/sensors/squeue
				./ia			## EXPERIMENTAL, RULE LIST
				./scripts		## RULES FILES, see template for hel
		3.4. Audit items:
			/opt/cyclops/audit
				./scripts/[OS COMPILANCE]	## AUDIT EXTRACTION FILES, edit one of them for help
		3.5. Cyclops items:
			/opt/cyclops
				./logs			## CYCLOPS LOGS STORAGE
				./www			## DOKUWIKI WEB INTERAFACE, MOVE OR LINK APACHE SITE DEFINITION FOR USE WEB INTERFACE
		3.6. Tools items:
			/opt/cyclops/tools
				./approved		## OFFICIAL CYCLOPS TOOLS
				./preops		## PRE-OFFICIAL CYCLOPS TOOLS
				./testing		## TESTING CYCLOPS TOOLS AND YOUR OWN CYC TOOLS
				./deprecated		## OLD CYCLOPS TOOLS
				./cg_state		## OLD FIRST TOOL IN CYCLOPS... YOU WOULD DELETE IT

       	- WARNING: Rename .template for each one it change
	- WARNING: Files with * is mandatory to be configurated previously to run cyclops 

    7.HA CYCLOPS environment NOTES
    ----------------------------------------------------------------------------------------------------------

        - Sync /opt/cyclops with ha mirror node
        - Repeat step 1. and 2.
        - Configure ssh keys for no auth ssh connections
        - Define settings in ha config file
            ./system
                ha.cfg.template
        - Cyclops needs ha software like heartbeat or peacemaker to control ha resources
        - Cyclops needs floating ip to refer master node

    8.MONITORING NODES CONFIG
    ----------------------------------------------------------------------------------------------------------

        - Configure ssh keys for no auth ssh connections
	- Create cyc working dirs
		1. Copy from cyc server /opt/cyclops/local to all cyc monitor hosts
		2. Default path: /opt/cyclops/local/data/sensors
		- if you want to change:
			1. Edit /opt/cyclops/monitor/sensors/status/conf/sensor.var.cfg file and change: _sensor_remote_path variable
			2. Edit /etc/cyclops/global.cfg file and change: _sensor_remote_path variable
	- If you want to enable management integration with cyc client hosts enable host control razor on clients
		1. Create this entry in the client host cron
			*/2 * * * * /opt/cyclops/local/scripts/cyc.host.ctrl.sh -a daemon 2>>/opt/cyclops/local/log/hctrl.err.log
		2. Create this entry in the /etc/rc.local
			/opt/cyclops/local/scripts/cyc.host.ctrl.sh -a boot 2>>/opt/cyclops/local/log/hctrl.err.log
		3. You need to create razor list in cyc server
		- Available razors in /opt/cyclops/local/data/razor/[STOCK/OS]/
		4. Create family file with selected razors in /etc/cyclops/nodes/[FAMILY NAME].rzr.lst
		- The order of razors is Hierarchical, from up ( first to do action ) to down ( last to do action )

    9.TEST AND ENABLE CYCLOPS
    ----------------------------------------------------------------------------------------------------------
    
	1. See available options with:
		cyclops.sh -h
        2. Check Status with:
		cyclops.sh -y status
		
        3. Generate monitoring entries with cyclops.sh -y config ( option 19 ) or editing /etc/cyclops/monitor/monitor.cfg.template and rename it to monitor.cfg
        
	4. Add Cron Entries like this redhat example:

		13 4 * * * /opt/cyclops/scripts/backup.cyc.sh -t all &>>/opt/cyclops/logs/[MAIN CYC NODE].bkp.log                                          #### OPTIONAL FOR BACKUP PROUPOSES
		*/3 * * * * /opt/cyclops/scripts/monitoring.sh -d 2>>/opt/cyclops/logs/[MAIN CYC NODE].mon.err.log                                         #### MANDATORY - MAIN CYCLOPS MONITOR ENTRY
		36 * * * * /opt/cyclops/scripts/audit.nod.sh -d  2>&1 >>/opt/cyclops/logs/audit.err.log                                                    #### OPTIONAL - IF YOU WANT TO USE AUDIT MODULE
		59 * * * * /opt/cyclops/scripts/historic.mon.sh  -d 2>>/opt/cyclops/logs/historic.err.log                                                  #### RECOMENDED - FOR SHOW HISTORIC MONITORING
		20 * * * * /opt/cyclops/scripts/procedures.sh -t node -v wiki >/opt/cyclops/www/data/pages/documentation/procedures/node_status.txt        #### OPTIONAL - UPDATE PROCEDURE STATUS
		21 * * * * /opt/cyclops/scripts/procedures.sh -t env -v wiki >/opt/cyclops/www/data/pages/documentation/procedures/env_status.txt          #### OPTIONAL - UPDATE PROCEDURE STATUS
		42 * * * * /opt/cyclops/scripts/cyc.stats.sh -t daemon >/dev/null 2>/opt/cyclops/logs/cyc.stats.err.log					   #### OPTIONAL BUT MANDATORY IF YOU ENABLE AUDIT MODULE
		17 * * * * /opt/cyclops/statistics/scripts/extract.main.slurm.sh -d 2>&1 >/opt/cyclops/logs/[HOSTNAME].slurm.extract.log                      #### OPTIONAL - SLURM STATISTICS
	
	5. Enable Cyclops in testing mode with:
		cyclops.sh -y testing -m '[MESSAGE]' -c
	6. Enable Cyclops in operative mode with:
		cyclops.sh -y up -c

	- Use cyclops.sh -h for see other optional features and activate them.
	
	7. For cyclops RC module add to /etc/profile this line
	
            [ -f "/etc/cyclops/system/cyclopsrc" ] && /etc/cyclops/system/cyclopsrc
            
            change permissions from /etc/cyclops/system/cyclopsrc to 750 
            configure /etc/cyclops/monitor/plugin.users.ctrl.cfg with users to ctrl
    
    
    


    

