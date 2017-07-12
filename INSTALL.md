CYCLOPS 1.4.1v INSTALL
==============================================================================================================


    1. PREPARE NECESSARY ENVIRONMENT
    ----------------------------------------------------------------------------------------------------------

    - install -> git
	- yum install git 			## REDHAT/CENTOS PACKAGE INSTALL 
	- apt-get install git			## DEBIAN
    - install -> apache + php + php gd + ssl module
        - yum install httpd php php-gd mod_ssl 	## REDHAT/CENTOS PACKAGE INSTALL
	- apt-get install apache2 php php-gd	## DEBIAN
    
    - Other Linux Recomended packages:
            - pdsh
            - sysstat
            - rsync

    - Apache customization
	1. You can use cyclops default certificates for apache if you want https cryp acces
	2. [ONLY REDHAT USERS] you can use cyclops site template in /opt/cyclops/docs/apache.cyclops.conf
		- [OTHER DISTROS] can use or adapt this template with right paths
		- Use,create or change paths for ssl certs if use own certs or copy /opt/cyclops/docs certs to the right paths
	3. IMPORTANT: disable selinux for right apache behaviour

    - You have in /opt/cyclops/docs a file template ( redhat ) for configurate apache site (is usesfull with other distros)    

    2. INSTALL CYCLOPS
    ----------------------------------------------------------------------------------------------------------

	1. FROM TAR:

	- copy cyclops.[version].tgz and untar in /opt
	- untar /opt/cyclops/monitor/packs/*.tar from root directory

	2. FROM GITHUB: 

	- create dir /opt/git
	- cd /opt/git/
	- git clone https://github.com/ikseth/cyclops.git
	- create link in /opt/ 
	- EXPERIMENTAL: ln -s /opt/git/cyclops/[version] cyclops ## EXPERIMENTAL, BETTER USE NEXT OPTION
	- STABLE OPTION: copy /opt/git/cyclops/[version] in /opt/cyclops 

	3. CREATE necesary directories
		cd /opt/cyclops/www/data
		mkdir attic cache index locks media_attic media_meta meta tmp
		cd /opt/cyclops
		mkdir logs lock temp

	4. INSTALL SENSORS, IA RULES AND NODE RAZOR
	- Decompress /opt/cyclops/monitor/packs for optain necesary sensors, rules and razors files
		from root directory ( cd / )
		tar xvf /opt/cyclops/monitor/packs/*.tar
		OR
		for _file in $( ls -1 /opt/cyclops/monitor/packs/* ) ; do tar xvf $_file ; done ## IF *.tar does not works 

	5. CREATE SYMLINKS

	- Configuration path
		cd /etc
		ln -s /opt/cyclops/etc/cyclops

	- Web Data
                cd /var/www/html/ 		## REDHAT WEB PATH ( Use the right path if you have other distro or other www configuration )
		ln -s /opt/cyclops/www cyclops 
		cp -p /etc/cyclops/system/wiki.cfg.template /etc/cyclops/system/wiki.cfg
		
		- Edit wiki.cfg file and change default user and group if is necesary:
			[REDHAT/CENTOS]	-> 	_apache_usr="apache"
			[DEBIAN] 	->	_apache_usr="www-data"
			[ALL DISTROS]	->	_apache_grp="cyclops"	## RECOMMENDED


	6. UPDATE CYCLOPS:

	- BEFORE UPDATE/UPGRADE BEWARE WITH THIS:
		- DO BACKUP FROM root cyclops directoty 
		- WITH rsync USE --exclude="[FILE|DIR|STRING]" with any customization that you change in www cyclops web directory

	- UPDATE IS EXPERIMENTAL YET

	- MORE SAFETY, WITH STABLE GITHUB OPTION:
		- from /opt/git/cyclops
			git pull
		- after git update, use:
			rsync -vrltDuc /opt/git/cyclops/[version]/ /opt/cyclops/

	- LESS SAFETY BUT MORE CONFORTABLE  
		- use GITHUB EXPERIMENTAL OPTION INSTALL FOR CYCLOPS
		- from /opt/git/cyclops
			fit pull

	- WITHOUT GITHUB
		- download zip from github
		- descompress file in temp dir
		- rsync with -vrltDuc optins from temp dir to cyclops dir ( BEWARE use --dry-run rsync option to verify right update before do it )

	NOTE: beware with update, sometimes owner or permissions could change, use chown or/and chmod commands to recovery right file and directory status, next step detail actions.

    
    3. CREATE AND CONFIGURE PERMISSIONS AND OWNERS
    ----------------------------------------------------------------------------------------------------------

        groupadd -g 900 cyclops					## CHANGE GID IF YOUR DISTRO OR SYSTEM HAS 900 IN USE
        useradd -g 900 -b /opt/cyclops/local -u 900 cyclops     ## CHANGE UID IF YOUR DISTRO OR SYSMTE HAS 900 IN USE
  
        chown -R cyclops:cyclops /opt/cyclops
        chown -R apache /opt/cyclops/www 			## REDHAT DEFAULT APACHE USER , CHANGE IT IF YOU HAS DIFERENT DISTRO OR USER
	chown -R www-data /opt/cyclops/www			## DEBIAN DEFAULT APACHE USER , CHANGE 
        
        chmod -R g+w,o-rwx /opt/cyclops/www/

        chmod -R 750 /opt/cyclops/scripts/
        chmod -R 750 /opt/cyclops/tools/
        chmod -R 750 /opt/cyclops/statistics/scripts/
      
    4. PROFILING USERS ENVIRONMENT
    ----------------------------------------------------------------------------------------------------------

	- For cyclops RC module link cyclopsrc in /etc/profile.d  ## [ REDHAT/CENTOS ] use the right way in other distro
	
		copy /etc/cyclops/monitor/plugin.users.ctrl.cfg.template to /etc/cyclops/monitor/plugin.users.ctrl.cfg
		cd /etc/profile.d 
		ln -s /etc/cyclops/system/cyclopsrc cyclopsrc.sh
            
		RECOMENDED: change permissions from /etc/cyclops/system/cyclopsrc to 750 

    5. INSTALL WEB INTERFACE ( DOKUWIKI BASED )
    ----------------------------------------------------------------------------------------------------------

 	- [OPTIONAL INSTALL] If you want you can install dokuwiki base from original source, and update it before with cyclops customization
		- [REDHAT/CENTOS] - https://www.dokuwiki.org/install:centos
		- Install necesary dokuwiki plugins
		- REMEMBER: overwrite cyclops files over dokuwiki install (at least /opt/cyclops/www/data/pages and /opt/cyclops/www/data/media) 
		- use rsync and customice it for update what ever you want

	- [RECOMMENDED INSTALL] use cyclops dokuwiki customization
		1. Configure symbolic link or right path for apache access to cyclops web interface ( default /opt/cyclops/www )
		- [REDHAT/CENTOS] can use this commands: 
			cd /var/www/html
			ln -s /opt/cyclops/www cyclops

	- If you use cyclops apache templates you can access:
		https://[IP/DOMAIN NAME]/doku.php

	* Web access credentials:
		User: admin
		Pass: cyclops

    6. CONFIGURE CYCLOPS
    ----------------------------------------------------------------------------------------------------------

	1. check /etc/global.cfg.template and after that rename to /etc/global.cfg
	2. check /etc/cyclops/nodes/node.type.cfg.template and rename it to same path with template at end of file.
	3. check /etc/cyclops/nodes/critical.res.cfg.template and rename it to same path without template at end of the file/
	4. You can use a cyclops prototipe option for configurate several items of it:
		cyclops -y config  ## USE IT SPECIALLY FOR NODE,FAMILY,GROUP AND MONITORING ITEMS
	5. You have the next files for configure cyclops

        /etc/cyclops/
                global.cfg.template *               ## MAIN CFG ( RECOMMENDED NOT CHANGE IF NOT NECESARY) - RENAME IT TO global.cfg 
            ./system
                wiki.cfg.template *                 ## APACHE USR&GRP
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

	6. Other Important dir&files:
		- Nodes items:
			/opt/cyclops/monitor/sensors/status
				./scripts		## [SENSORS COMPILANCE]/SENSORS FILES ## NECESARY IF YOU WANT TO CREATE NEW ONES OR MODIFY THEM, see .template file for help
				./ia			## IA RULES FILES, see .template file for help
		- Environment items:
			/opt/cyclops/monitor/sensors/environment
				./scripts		## [SENSORS COMPILANCE]/SENSORS FILES ## NECESARY IF YOU WANT TO CREATE NEW ONES OR MODIFY THEM, see .template file for help
				./ia			## IA RULES FILES, see .template file for help
		- Slurm items:
			/opt/cyclops/monitor/sensors/squeue
				./ia			## EXPERIMENTAL, RULE LIST
				./scripts		## RULES FILES, see template for hel
		- Audit items:
			/opt/cyclops/audit
				./scripts/[OS|STOCK COMPILANCE]	## AUDIT EXTRACTION FILES, edit one of them for help
		- Cyclops items:
			/opt/cyclops
				./logs			## CYCLOPS LOGS STORAGE
				./www			## DOKUWIKI WEB INTERAFACE, MOVE OR LINK APACHE SITE DEFINITION FOR USE WEB INTERFACE
		- Tools items:
			/opt/cyclops/tools
				./approved		## OFFICIAL CYCLOPS TOOLS
				./preops		## PRE-OFFICIAL CYCLOPS TOOLS
				./testing		## TESTING CYCLOPS TOOLS AND YOUR OWN CYC TOOLS

       	- WARNING: Rename .template for each one it change , best practice is copy the file without .template and change new file.
	- WARNING: Files with * is mandatory to be configurated previously to run cyclops 

    6. HA CYCLOPS ENVIRONMENT NOTES [OPTIONAL]
    ----------------------------------------------------------------------------------------------------------

        - Repeat step 1. and 2.
        - Configure ssh keys for no auth ssh connections
        - Sync /opt/cyclops with ha mirror node
	- Copy file /etc/cyclops/system/ha.cfg.template with same name in same place without ".template" and change it
        - Define settings in ha config file
        - Cyclops needs ha software like heartbeat or peacemaker to control ha resources
        - Cyclops needs floating ip to refer master node

    7. NODES CONFIG
    ----------------------------------------------------------------------------------------------------------

        - Configure ssh keys for no auth ssh connections
	- Create cyc working dirs
		1. Copy from cyc server /opt/cyclops/local to all cyc monitor hosts
		2. Default path: /opt/cyclops/local/data/sensors
		- if you want to change [ NOT RECOMMENDED ] :
			1. Edit /opt/cyclops/monitor/sensors/status/conf/sensor.var.cfg file and change: _sensor_remote_path variable
			2. Edit /etc/cyclops/global.cfg file and change: _sensor_remote_path variable
	- If you want to enable management integration with cyc client hosts enable host control razor on clients
		1. Create this entry in the client host cron
			*/2 * * * * /opt/cyclops/local/scripts/cyc.host.ctrl.sh -a daemon 2>>/opt/cyclops/local/log/hctrl.err.log
		2. Create this entry in the /etc/rc.local
			/opt/cyclops/local/scripts/cyc.host.ctrl.sh -a boot 2>>/opt/cyclops/local/log/hctrl.err.log
		3. You need to create razor list in cyclops server
		- Available razors in /opt/cyclops/local/data/razor/[STOCK/OS]/
		4. Create family file with selected razors in /etc/cyclops/nodes/[FAMILY NAME].rzr.lst
		- The order of razors is Hierarchical, from up ( first to do action ) to down ( last to do action )
		- [ RECOMMENDED ] first insert razor with host pasive checks and last instert razor with host dramatical actions like shutdown/reboot

    8. TEST AND ENABLE CYCLOPS
    ----------------------------------------------------------------------------------------------------------
    
	1. See available options with:
		cyclops.sh -h

	2. Check Status with:
		cyc.stats.sh -a cyclops ## FOR CYCLOPS OPTIONS STATUS
		cyc.stats.sh -a node  ## FOR NODE STATUS
		
	3. Generate monitoring entries with cyclops.sh -y config ( option 19 ) or editing /etc/cyclops/monitor/monitor.cfg.template and rename it to monitor.cfg
        
	4. Add Cron Entries like this redhat example:

		13 4 * * * /opt/cyclops/scripts/backup.cyc.sh -t all &>>/opt/cyclops/logs/[MAIN CYC NODE].bkp.log                                          #### OPTIONAL FOR BACKUP PROUPOSES
		*/3 * * * * /opt/cyclops/scripts/monitoring.sh -d 2>>/opt/cyclops/logs/[MAIN CYC NODE].mon.err.log                                         #### MANDATORY - MAIN CYCLOPS MONITOR ENTRY
		36 * * * * /opt/cyclops/scripts/audit.nod.sh -d  2>&1 >>/opt/cyclops/logs/audit.err.log                                                    #### OPTIONAL - IF YOU WANT TO USE AUDIT MODULE
		59 * * * * /opt/cyclops/scripts/historic.mon.sh  -d 2>>/opt/cyclops/logs/historic.err.log                                                  #### RECOMENDED - FOR SHOW HISTORIC MONITORING
		20 * * * * /opt/cyclops/scripts/procedures.sh -t node -v wiki >/opt/cyclops/www/data/pages/documentation/procedures/node_status.txt        #### OPTIONAL - UPDATE PROCEDURE STATUS
		21 * * * * /opt/cyclops/scripts/procedures.sh -t env -v wiki >/opt/cyclops/www/data/pages/documentation/procedures/env_status.txt          #### OPTIONAL - UPDATE PROCEDURE STATUS
		42 * * * * /opt/cyclops/scripts/cyc.stats.sh -t daemon >/dev/null 2>/opt/cyclops/logs/cyc.stats.err.log					   #### OPTIONAL BUT MANDATORY IF YOU ENABLE AUDIT MODULE
		17 * * * * /opt/cyclops/statistics/scripts/extract.main.slurm.sh -d 2>&1 >/opt/cyclops/logs/[HOSTNAME].slurm.extract.log                   #### OPTIONAL - SLURM STATISTICS
	
	5. Enable Cyclops in testing mode with:
		cyclops.sh -y testing -m '[MESSAGE]' -c

	6. Enable Cyclops in operative mode with:
		cyclops.sh -y enable -c

