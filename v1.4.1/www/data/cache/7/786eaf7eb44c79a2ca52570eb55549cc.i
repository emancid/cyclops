a:297:{i:0;a:3:{i:0;s:14:"document_start";i:1;a:0:{}i:2;i:0;}i:1;a:3:{i:0;s:6:"header";i:1;a:3:{i:0;s:14:"Configuración";i:1;i:1;i:2;i:1;}i:2;i:1;}i:2;a:3:{i:0;s:12:"section_open";i:1;a:1:{i:0;i:1;}i:2;i:1;}i:3;a:3:{i:0;s:13:"section_close";i:1;a:0:{}i:2;i:31;}i:4;a:3:{i:0;s:6:"header";i:1;a:3:{i:0;s:16:"Instalar Cyclops";i:1;i:2;i:2;i:31;}i:2;i:31;}i:5;a:3:{i:0;s:12:"section_open";i:1;a:1:{i:0;i:2;}i:2;i:31;}i:6;a:3:{i:0;s:10:"listo_open";i:1;a:0:{}i:2;i:60;}i:7;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:60;}i:8;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:60;}i:9;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:36:" Copiar la ultima version de cyclops";}i:2;i:64;}i:10;a:3:{i:0;s:4:"code";i:1;a:3:{i:0;s:36:"
scp -r [dir_last_vers_cyclops] /opt";i:1;N;i:2;N;}i:2;i:105;}i:11;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:149;}i:12;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:149;}i:13;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:149;}i:14;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:149;}i:15;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:43:" Crear los enlaces simbolicos en el sistema";}i:2;i:153;}i:16;a:3:{i:0;s:4:"code";i:1;a:3:{i:0;s:112:"
ln -s /opt/[dir_vers_update_cyclops] /opt/cyclops
ln -s /opt/[dir_vers_update_cyclops]/etc/cyclops /etc/cyclops";i:1;N;i:2;N;}i:2;i:201;}i:17;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:321;}i:18;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:321;}i:19;a:3:{i:0;s:11:"listo_close";i:1;a:0:{}i:2;i:321;}i:20;a:3:{i:0;s:13:"section_close";i:1;a:0:{}i:2;i:323;}i:21;a:3:{i:0;s:6:"header";i:1;a:3:{i:0;s:17:"Instalar Dokuwiki";i:1;i:2;i:2;i:323;}i:2;i:323;}i:22;a:3:{i:0;s:12:"section_open";i:1;a:1:{i:0;i:2;}i:2;i:323;}i:23;a:3:{i:0;s:10:"listo_open";i:1;a:0:{}i:2;i:353;}i:24;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:353;}i:25;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:353;}i:26;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:59:" Copiar la ultima version de la dokuwiki adaptada a cyclops";}i:2;i:357;}i:27;a:3:{i:0;s:4:"code";i:1;a:3:{i:0;s:61:"
scp -R [dir_doku_last_ver_cyclops] /[apache web dir]/cyclops";i:1;N;i:2;N;}i:2;i:421;}i:28;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:490;}i:29;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:490;}i:30;a:3:{i:0;s:11:"listo_close";i:1;a:0:{}i:2;i:490;}i:31;a:3:{i:0;s:13:"section_close";i:1;a:0:{}i:2;i:492;}i:32;a:3:{i:0;s:6:"header";i:1;a:3:{i:0;s:18:"Configurar Cyclops";i:1;i:2;i:2;i:492;}i:2;i:492;}i:33;a:3:{i:0;s:12:"section_open";i:1;a:1:{i:0;i:2;}i:2;i:492;}i:34;a:3:{i:0;s:10:"listo_open";i:1;a:0:{}i:2;i:523;}i:35;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:523;}i:36;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:523;}i:37;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:12:" Cambiar en ";}i:2;i:527;}i:38;a:3:{i:0;s:11:"strong_open";i:1;a:0:{}i:2;i:539;}i:39;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:12:" monitor.sh ";}i:2;i:541;}i:40;a:3:{i:0;s:12:"strong_close";i:1;a:0:{}i:2;i:553;}i:41;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:12:" el usuario ";}i:2;i:555;}i:42;a:3:{i:0;s:13:"emphasis_open";i:1;a:0:{}i:2;i:567;}i:43;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:13:"apache:apache";}i:2;i:569;}i:44;a:3:{i:0;s:14:"emphasis_close";i:1;a:0:{}i:2;i:582;}i:45;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:56:" por el que corresponda en la distro de la instalación.";}i:2;i:584;}i:46;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:640;}i:47;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:640;}i:48;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:640;}i:49;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:640;}i:50;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:20:" Crear los nodos en ";}i:2;i:644;}i:51;a:3:{i:0;s:11:"strong_open";i:1;a:0:{}i:2;i:664;}i:52;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:15:" node.type.cfg ";}i:2;i:666;}i:53;a:3:{i:0;s:12:"strong_close";i:1;a:0:{}i:2;i:681;}i:54;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:24:" y sus características.";}i:2;i:683;}i:55;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:707;}i:56;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:707;}i:57;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:707;}i:58;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:707;}i:59;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:85:" Crear los sensores activos por los grupos creados en el anterior fichero. (ficheros ";}i:2;i:711;}i:60;a:3:{i:0;s:11:"strong_open";i:1;a:0:{}i:2;i:796;}i:61;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:25:" [grupo/familia].mon.cfg ";}i:2;i:798;}i:62;a:3:{i:0;s:12:"strong_close";i:1;a:0:{}i:2;i:823;}i:63;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:2:" )";}i:2;i:825;}i:64;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:827;}i:65;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:827;}i:66;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:827;}i:67;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:827;}i:68;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:38:" Crear los nodos de acceso externo en ";}i:2;i:831;}i:69;a:3:{i:0;s:11:"strong_open";i:1;a:0:{}i:2;i:869;}i:70;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:17:" login.node.list ";}i:2;i:871;}i:71;a:3:{i:0;s:12:"strong_close";i:1;a:0:{}i:2;i:888;}i:72;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:890;}i:73;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:890;}i:74;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:890;}i:75;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:890;}i:76;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:43:" Activar los módulos a monitorización en ";}i:2;i:894;}i:77;a:3:{i:0;s:11:"strong_open";i:1;a:0:{}i:2;i:937;}i:78;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:16:" monitoring.cfg ";}i:2;i:939;}i:79;a:3:{i:0;s:12:"strong_close";i:1;a:0:{}i:2;i:955;}i:80;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:957;}i:81;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:957;}i:82;a:3:{i:0;s:11:"listo_close";i:1;a:0:{}i:2;i:957;}i:83;a:3:{i:0;s:13:"section_close";i:1;a:0:{}i:2;i:959;}i:84;a:3:{i:0;s:6:"header";i:1;a:3:{i:0;s:27:"Configuraciones opcionales.";i:1;i:3;i:2;i:959;}i:2;i:959;}i:85;a:3:{i:0;s:12:"section_open";i:1;a:1:{i:0;i:3;}i:2;i:959;}i:86;a:3:{i:0;s:10:"listo_open";i:1;a:0:{}i:2;i:997;}i:87;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:997;}i:88;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:997;}i:89;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:88:" Crear las credenciales y nombres de las consolas ipmi si fuese necesario en el fichero ";}i:2;i:1001;}i:90;a:3:{i:0;s:11:"strong_open";i:1;a:0:{}i:2;i:1089;}i:91;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:14:" bios.mng.cfg ";}i:2;i:1091;}i:92;a:3:{i:0;s:12:"strong_close";i:1;a:0:{}i:2;i:1105;}i:93;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:1107;}i:94;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:1107;}i:95;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:1107;}i:96;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:1107;}i:97;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:50:" Crear los dispositivos de entorno y activarlos ( ";}i:2;i:1111;}i:98;a:3:{i:0;s:11:"strong_open";i:1;a:0:{}i:2;i:1161;}i:99;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:13:" env.mon.cfg ";}i:2;i:1163;}i:100;a:3:{i:0;s:12:"strong_close";i:1;a:0:{}i:2;i:1176;}i:101;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:3:" y ";}i:2;i:1178;}i:102;a:3:{i:0;s:11:"strong_open";i:1;a:0:{}i:2;i:1181;}i:103;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:13:" monitor.cfg ";}i:2;i:1183;}i:104;a:3:{i:0;s:12:"strong_close";i:1;a:0:{}i:2;i:1196;}i:105;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:2:" )";}i:2;i:1198;}i:106;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:1200;}i:107;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:1200;}i:108;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:1200;}i:109;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:1200;}i:110;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:50:" Configurar las alertas de correo electrónico en ";}i:2;i:1204;}i:111;a:3:{i:0;s:11:"strong_open";i:1;a:0:{}i:2;i:1254;}i:112;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:17:" alert.email.cfg ";}i:2;i:1256;}i:113;a:3:{i:0;s:12:"strong_close";i:1;a:0:{}i:2;i:1273;}i:114;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:1275;}i:115;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:1275;}i:116;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:1275;}i:117;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:1275;}i:118;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:143:" Configurar los usuarios administradores y de soporte para el plugin de control de usuarios, este plugin es dependiente del modulo de usuarios ";}i:2;i:1279;}i:119;a:3:{i:0;s:13:"emphasis_open";i:1;a:0:{}i:2;i:1422;}i:120;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:20:"sensors.users.mon.sh";}i:2;i:1424;}i:121;a:3:{i:0;s:14:"emphasis_close";i:1;a:0:{}i:2;i:1444;}i:122;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:60:" . El fichero de configuracion se encuentra por defecto en: ";}i:2;i:1446;}i:123;a:3:{i:0;s:11:"strong_open";i:1;a:0:{}i:2;i:1506;}i:124;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:42:"/etc/cyclops/monitor/plugin.users.ctrl.cfg";}i:2;i:1508;}i:125;a:3:{i:0;s:12:"strong_close";i:1;a:0:{}i:2;i:1550;}i:126;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:1552;}i:127;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:1552;}i:128;a:3:{i:0;s:11:"listo_close";i:1;a:0:{}i:2;i:1552;}i:129;a:3:{i:0;s:13:"section_close";i:1;a:0:{}i:2;i:1554;}i:130;a:3:{i:0;s:6:"header";i:1;a:3:{i:0;s:13:"Pasos Finales";i:1;i:3;i:2;i:1554;}i:2;i:1554;}i:131;a:3:{i:0;s:12:"section_open";i:1;a:1:{i:0;i:3;}i:2;i:1554;}i:132;a:3:{i:0;s:10:"listo_open";i:1;a:0:{}i:2;i:1578;}i:133;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:1578;}i:134;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:1578;}i:135;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:69:" Crear e inicializar los valores de la monitorizacion en el fichero: ";}i:2;i:1582;}i:136;a:3:{i:0;s:4:"code";i:1;a:3:{i:0;s:531:"
/opt/cyclops/monitor/sensors/data/status/stateofthings.cyc 

#### CYCLOPS MON STATUS HISTORIC ####
# TAG;NAME;[VARIABLE FIELDS]
## --  TAG >> INFO;[NAME];[TIME START];[TIME END];DESCRIPTION
## --  TAG >> ALERT;[NODE/DEVICE/SERVICE];[SENSOR];[TIME START];[TIME END];[STATE]
## --  TAG >> CYC;[NUM CYCLES];[STATUS]
## 
CYC;0001;0;DISABLED
CYC;0002;[node name];1;UPTIME_RECORD
CYC;0003;AUDIT;[ENABLED|DISABLED]
CYC;0004;MAIL;[ENABLED|DISABLED]
CYC;0005;SOUND;[ENABLED|DISABLED]
CYC;0006;HA;[ENABLED|DISABLED];[main cyclops hostname]
";i:1;N;i:2;N;}i:2;i:1656;}i:137;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:2195;}i:138;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:2195;}i:139;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:2195;}i:140;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:2195;}i:141;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:70:" Crear el directorio en todos los nodos configurados para monitorizar.";}i:2;i:2199;}i:142;a:3:{i:0;s:4:"code";i:1;a:3:{i:0;s:22:"
/root/cyclops/sensors";i:1;N;i:2;N;}i:2;i:2274;}i:143;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:2304;}i:144;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:2304;}i:145;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:2304;}i:146;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:2304;}i:147;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:46:" Lanzar el comando para crear la programacion.";}i:2;i:2308;}i:148;a:3:{i:0;s:4:"code";i:1;a:3:{i:0;s:40:"
/opt/cyclops/scripts/cyclops.sh -y cron";i:1;N;i:2;N;}i:2;i:2359;}i:149;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:2407;}i:150;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:2407;}i:151;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:2407;}i:152;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:2407;}i:153;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:50:" Lanzar el comando para activar la monitorizacion.";}i:2;i:2411;}i:154;a:3:{i:0;s:4:"code";i:1;a:3:{i:0;s:46:"
/opt/cyclops/scripts/cyclops.sh -y enable -c ";i:1;N;i:2;N;}i:2;i:2466;}i:155;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:2520;}i:156;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:2520;}i:157;a:3:{i:0;s:11:"listo_close";i:1;a:0:{}i:2;i:2520;}i:158;a:3:{i:0;s:10:"listu_open";i:1;a:0:{}i:2;i:2521;}i:159;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:2521;}i:160;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:2521;}i:161;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:48:" Los codigos actualmente disponibles en cyclops:";}i:2;i:2525;}i:162;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:2573;}i:163;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:2573;}i:164;a:3:{i:0;s:11:"listu_close";i:1;a:0:{}i:2;i:2573;}i:165;a:3:{i:0;s:6:"plugin";i:1;a:4:{i:0;s:6:"hidden";i:1;a:11:{s:6:"active";s:4:"true";s:7:"element";a:0:{}s:8:"onHidden";s:9:"CYC CODES";s:9:"onVisible";s:9:"CYC CODES";s:12:"initialState";s:6:"hidden";s:5:"state";i:1;s:9:"printHead";b:1;s:13:"bytepos_start";i:2574;s:4:"edit";b:0;s:8:"editText";s:19:"Edit hidden section";s:11:"onExportPdf";s:9:"CYC CODES";}i:2;i:1;i:3;s:18:"<hidden CYC CODES>";}i:2;i:2574;}i:166;a:3:{i:0;s:10:"listu_open";i:1;a:0:{}i:2;i:2592;}i:167;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:2592;}i:168;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:2592;}i:169;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:32:" 0001: Cyclops Monitoring Status";}i:2;i:2596;}i:170;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:2628;}i:171;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:2628;}i:172;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:2628;}i:173;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:2628;}i:174;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:33:" 0002: Host Uptime Control Status";}i:2;i:2632;}i:175;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:2665;}i:176;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:2665;}i:177;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:2665;}i:178;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:2665;}i:179;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:34:" 0003: Cyclops Audit System Status";}i:2;i:2669;}i:180;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:2703;}i:181;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:2703;}i:182;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:2703;}i:183;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:2703;}i:184;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:33:" 0004: Cyclops Mail Alerts Status";}i:2;i:2707;}i:185;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:2740;}i:186;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:2740;}i:187;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:2740;}i:188;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:2740;}i:189;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:40:" 0005: Cyclops Web Interfaz Sound Status";}i:2;i:2744;}i:190;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:2784;}i:191;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:2784;}i:192;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:2784;}i:193;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:2784;}i:194;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:32:" 0006: Cyclops HA Control Status";}i:2;i:2788;}i:195;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:2820;}i:196;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:2820;}i:197;a:3:{i:0;s:11:"listu_close";i:1;a:0:{}i:2;i:2820;}i:198;a:3:{i:0;s:6:"plugin";i:1;a:4:{i:0;s:6:"hidden";i:1;a:2:{s:5:"state";i:4;s:11:"bytepos_end";i:2830;}i:2;i:4;i:3;s:9:"</hidden>";}i:2;i:2821;}i:199;a:3:{i:0;s:13:"section_close";i:1;a:0:{}i:2;i:2834;}i:200;a:3:{i:0;s:6:"header";i:1;a:3:{i:0;s:19:"Acciones Especiales";i:1;i:2;i:2;i:2834;}i:2;i:2834;}i:201;a:3:{i:0;s:12:"section_open";i:1;a:1:{i:0;i:2;}i:2;i:2834;}i:202;a:3:{i:0;s:10:"listo_open";i:1;a:0:{}i:2;i:2866;}i:203;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:2866;}i:204;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:2866;}i:205;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:83:" Crear si no existe el directorio siguiente en el nodo principal de monitorización";}i:2;i:2871;}i:206;a:3:{i:0;s:4:"code";i:1;a:3:{i:0;s:18:"
/opt/cyclops/temp";i:1;N;i:2;N;}i:2;i:2959;}i:207;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:2985;}i:208;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:2985;}i:209;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:2985;}i:210;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:2985;}i:211;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:67:" Verificar la existencia y correcta configuración de los Ficheros ";}i:2;i:2989;}i:212;a:3:{i:0;s:13:"emphasis_open";i:1;a:0:{}i:2;i:3056;}i:213;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:4:".cfg";}i:2;i:3058;}i:214;a:3:{i:0;s:14:"emphasis_close";i:1;a:0:{}i:2;i:3062;}i:215;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:66:" dentro de la configuración controlar la existencia del fichero: ";}i:2;i:3064;}i:216;a:3:{i:0;s:18:"doublequoteopening";i:1;a:0:{}i:2;i:3130;}i:217;a:3:{i:0;s:13:"emphasis_open";i:1;a:0:{}i:2;i:3131;}i:218;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:14:"sensor.var.cfg";}i:2;i:3133;}i:219;a:3:{i:0;s:14:"emphasis_close";i:1;a:0:{}i:2;i:3147;}i:220;a:3:{i:0;s:18:"doublequoteclosing";i:1;a:0:{}i:2;i:3149;}i:221;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:3150;}i:222;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:3150;}i:223;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:3150;}i:224;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:3150;}i:225;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:21:" Crear el directorio ";}i:2;i:3154;}i:226;a:3:{i:0;s:4:"code";i:1;a:3:{i:0;s:71:"
/var/www/html/cyclops/data/pages/operation/monitoring/history/noindex/";i:1;N;i:2;N;}i:2;i:3180;}i:227;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:3259;}i:228;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:3259;}i:229;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:3259;}i:230;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:3259;}i:231;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:20:" Crear el directorio";}i:2;i:3263;}i:232;a:3:{i:0;s:4:"code";i:1;a:3:{i:0;s:34:"
/opt/cyclops/monitor/sensors/temp";i:1;N;i:2;N;}i:2;i:3288;}i:233;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:3330;}i:234;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:3330;}i:235;a:3:{i:0;s:11:"listo_close";i:1;a:0:{}i:2;i:3330;}i:236;a:3:{i:0;s:13:"section_close";i:1;a:0:{}i:2;i:3332;}i:237;a:3:{i:0;s:6:"header";i:1;a:3:{i:0;s:29:"Problemas para su depuración";i:1;i:2;i:2;i:3332;}i:2;i:3332;}i:238;a:3:{i:0;s:12:"section_open";i:1;a:1:{i:0;i:2;}i:2;i:3332;}i:239;a:3:{i:0;s:10:"listo_open";i:1;a:0:{}i:2;i:3374;}i:240;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:3374;}i:241;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:3374;}i:242;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:38:" Cambiar la linea 134 de audit.sh por:";}i:2;i:3378;}i:243;a:3:{i:0;s:4:"code";i:1;a:3:{i:0;s:75:"
for _host_data in $( cat $_type | egrep -v "^$|^#" | grep $_par_node"\;" )";i:1;N;i:2;N;}i:2;i:3421;}i:244;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:3504;}i:245;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:3504;}i:246;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:3504;}i:247;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:3504;}i:248;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:50:" Cambiar en la doku el enlace de la auditoria por ";}i:2;i:3508;}i:249;a:3:{i:0;s:13:"emphasis_open";i:1;a:0:{}i:2;i:3558;}i:250;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:5:"start";}i:2;i:3560;}i:251;a:3:{i:0;s:14:"emphasis_close";i:1;a:0:{}i:2;i:3565;}i:252;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:3567;}i:253;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:3567;}i:254;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:3567;}i:255;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:3567;}i:256;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:19:" Revisar el plugin ";}i:2;i:3571;}i:257;a:3:{i:0;s:11:"strong_open";i:1;a:0:{}i:2;i:3590;}i:258;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:8:" uptime ";}i:2;i:3592;}i:259;a:3:{i:0;s:12:"strong_close";i:1;a:0:{}i:2;i:3600;}i:260;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:1:" ";}i:2;i:3602;}i:261;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:3603;}i:262;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:3603;}i:263;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:3603;}i:264;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:3603;}i:265;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:16:" Revisar plugin ";}i:2;i:3607;}i:266;a:3:{i:0;s:11:"strong_open";i:1;a:0:{}i:2;i:3623;}i:267;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:22:" Full operative nodes ";}i:2;i:3625;}i:268;a:3:{i:0;s:12:"strong_close";i:1;a:0:{}i:2;i:3647;}i:269;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:3:" y ";}i:2;i:3649;}i:270;a:3:{i:0;s:11:"strong_open";i:1;a:0:{}i:2;i:3652;}i:271;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:8:" UPTIME ";}i:2;i:3654;}i:272;a:3:{i:0;s:12:"strong_close";i:1;a:0:{}i:2;i:3662;}i:273;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:3664;}i:274;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:3664;}i:275;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:3664;}i:276;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:3664;}i:277;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:48:" Añadir iconos que faltan iconos en la dokuwiki";}i:2;i:3668;}i:278;a:3:{i:0;s:4:"code";i:1;a:3:{i:0;s:40:"
{{ :wiki:hb-alert-orange.gif?nolink |}}";i:1;N;i:2;N;}i:2;i:3721;}i:279;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:3769;}i:280;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:3769;}i:281;a:3:{i:0;s:11:"listo_close";i:1;a:0:{}i:2;i:3769;}i:282;a:3:{i:0;s:13:"section_close";i:1;a:0:{}i:2;i:3771;}i:283;a:3:{i:0;s:6:"header";i:1;a:3:{i:0;s:41:"Otras configuraciones o Personalizaciones";i:1;i:2;i:2;i:3771;}i:2;i:3771;}i:284;a:3:{i:0;s:12:"section_open";i:1;a:1:{i:0;i:2;}i:2;i:3771;}i:285;a:3:{i:0;s:10:"listu_open";i:1;a:0:{}i:2;i:3825;}i:286;a:3:{i:0;s:13:"listitem_open";i:1;a:1:{i:0;i:1;}i:2;i:3825;}i:287;a:3:{i:0;s:16:"listcontent_open";i:1;a:0:{}i:2;i:3825;}i:288;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:87:" Configurar los usuarios cyclops para que tengan informacion en la carga de su profile:";}i:2;i:3829;}i:289;a:3:{i:0;s:17:"listcontent_close";i:1;a:0:{}i:2;i:3916;}i:290;a:3:{i:0;s:14:"listitem_close";i:1;a:0:{}i:2;i:3916;}i:291;a:3:{i:0;s:11:"listu_close";i:1;a:0:{}i:2;i:3916;}i:292;a:3:{i:0;s:6:"plugin";i:1;a:4:{i:0;s:6:"hidden";i:1;a:11:{s:6:"active";s:4:"true";s:7:"element";a:0:{}s:8:"onHidden";s:22:"/etc/profile customize";s:9:"onVisible";s:22:"/etc/profile customize";s:12:"initialState";s:6:"hidden";s:5:"state";i:1;s:9:"printHead";b:1;s:13:"bytepos_start";i:3918;s:4:"edit";b:0;s:8:"editText";s:19:"Edit hidden section";s:11:"onExportPdf";s:22:"/etc/profile customize";}i:2;i:1;i:3;s:31:"<hidden /etc/profile customize>";}i:2;i:3918;}i:293;a:3:{i:0;s:4:"code";i:1;a:3:{i:0;s:1578:"
# CYCLOPS PROFILE

if [ -f /etc/cyclops/monitor/plugin.users.ctrl.cfg ]
then
        source /etc/cyclops/monitor/plugin.users.ctrl.cfg

        _cyc_user_ctrl=$( echo "$_pg_usr_ctrl_admin,$_pg_usr_ctrl_l1_support,$_pg_usr_ctrl_l2_support,$_pg_usr_ctrl_l3_support,$_pg_usr_ctrl_other" | tr ',' '\n' | awk -v _u="$USER" '{ if ( $1 == _u ) { print "OK" }}' )

        if [ "$_cyc_user_ctrl" == "OK" ]
        then
                source /etc/cyclops/global.cfg
                PATH="${PATH}:/opt/cyclops/scripts:/opt/cyclops/tools/approved"
                export PATH

                echo "CYCLOPS: OPERATIVE ENVIRONMENT STATUS"
                test.productive.env.sh -t pasive -v human 2>/dev/null
                echo "============================="

                echo
                echo "CYCLOPS: HELP INFO"
                echo "-----------------------------"
                echo "Use Next commands for maintenance correct link between system and monitoring team"
                echo "  cyclops.sh: manage monitoring or get info about system status"
                echo "  audit.nod.sh: get info about node(s) status or main bitacora data"
                echo "  test.productive.env.sh: known environment productive status"
                echo 
                echo "Use -h for help in those commands"
                echo "Maybe you need root permissions to manage cyclops, use su or sudo commands"
                echo            
                echo "Please connect to https://cyclops.aemet.es to get info about cyclops"
                echo
        fi
fi

fi
";i:1;s:4:"bash";i:2;N;}i:2;i:3955;}i:294;a:3:{i:0;s:6:"plugin";i:1;a:4:{i:0;s:6:"hidden";i:1;a:2:{s:5:"state";i:4;s:11:"bytepos_end";i:5556;}i:2;i:4;i:3;s:9:"</hidden>";}i:2;i:5547;}i:295;a:3:{i:0;s:13:"section_close";i:1;a:0:{}i:2;i:5557;}i:296;a:3:{i:0;s:12:"document_end";i:1;a:0:{}i:2;i:5557;}}