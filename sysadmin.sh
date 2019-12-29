#!/bin/bash

###Sysadmin es una herramienta que facilita el trabajo a los administradores de sistemas
cat /home/manu/tools/sysadmin/banner.txt
echo " "
echo " "
#####################
#    Color Vars     #
#####################
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
PURPLE='\033[0;34m'
CYAN='\033[0;35m'
LIGHTGRAY='\033[0;36m'
NC='\033[0m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
LIGHTORANGE='\033[1;33m'
LIGHTPURPLE='\033[1;34m'
LIGHTCYAN='\033[1;35m'


#####################
#       Vars		#
#####################
nProcRunning=`echo "scale=2; $(top -b -n1 | grep "R" | wc -l) -1" |bc`
nProcSleeping=`echo "scale=2; $(top -b -n1 | grep "S" | wc -l) -1" |bc`
nProcZombie=`echo "scale=2; $(top -b -n1 | grep "Z" | wc -l) -1" |bc`

#####################
#    functions      #
#####################

function usage(){
echo "-m 	-		La opción -m nos permite entrar en las subopciones de monitorización"
echo "-u 	-		La opción -u nos permite actualizar a la última versión nuestro programa"
echo "-h 	-		La opción -h nos permite visualizar la ayuda"
echo "-a    -		La opción -a nos permite realizar acciones determinadas"

}
##df -kh | grep "[0-9]G" | awk {'print $1" --> "$5" --> " $6'}
while getopts ":m:u:a:h:" opt; do
  case $opt in

  	m)
	    OPTION="${OPTARG}"
		if [[ $OPTION == "espacio" ]];then
		porcentaje=`df -kh | awk {'print $5'} | cut -d "%" -f1 | grep -vi "uso"`
			for lines in $(echo $porcentaje);do
				if [[ $lines -gt 75 ]];then
					echo "=========================================================="
					echo "La partición/partiones con un uso mayor al 75% es/son"
					echo -e "==========================================================\n"
					df -kh | grep "$lines" | awk {'print $1" --> "$5" --> " $6'}
		#Añadir colores en esta muestra
				fi
			done

		elif [[ $OPTION == "procesos" ]];then
			echo "Hay un total de: "
			echo -e "  - $nProcRunning procesos en ${GREEN}running${NC}"
			echo -e "  - $nProcSleeping procesos en ${ORANGE}sleeping${NC}"
			echo -e "  - $nProcZombie procesos en ${RED}zombie state${NC}"

			read -p "¿Cuál de todos los estados quieres visualizar? (r) Running; (s) sleeping; (z) zombie: " estado

			if [[ $estado == "r" ]];then
				top -b -n1 -c | grep "R"
			elif [[ $estado == "s" ]];then
				top -b -n1 -c | grep "S"
		    elif [[ $estado == "z" ]];then
		    	top -b -n1 -c | grep "Z"
		    fi

		elif [[ $OPTION == "servicios" ]]; then
			mysqlStatus=`/etc/init.d/mysql status | grep -i active | cut -d ":" -f2 | cut -d "(" -f1`
			apacheStatus=`/etc/init.d/apache2 status | grep -i active | cut -d ":" -f2 | cut -d "(" -f1`
			echo 'MySQL is : ' $mysqlStatus
			echo 'Apache2 is:' $apacheStatus
        fi
			;;

	u)
		#upgrade option
				curl https://github.com/hippi3c0w/sysadmin/blob/master/version | grep -i "lc1" > /root/version.txt
		lastUpdate=`cat /root/version.txt | cut -d ">" -f2 | cut -d "<" -f1 | cut -d "-" -f1`
		currentVersion=`cat version.txt| cut -d "-" -f1`
		if [[ "$lastUpdate" == "$currentVersion"  ]];then

			echo  -e "[${GREEN}+${NC}]Software actualizado. No te hace falta actualizar"
		else
			echo  -e "[${RED}+${NC}]Software NO actualizado."
			cd /root/
			git clone https://github.com/hippi3c0w/sysadmin.git
			cd sysadmin
			mv sysadmin.sh sysadmin 
			mv sysadmin /usr/bin/
		fi
		    ;;

    a)

		OPCION="${OPTARG}"
		if [[ $OPCION == "crontab" ]];then
			read -p "Minuto: " minuto
			read -p "Hora: " hora
			read -p "Día del mes: " dom
			read -p "Mes: " mes
			read -p "Día de la semana: " dow
			read -p "Comando: " cmd

			echo "$minuto $hora $dom $mes $dow $cmd" >> /var/spool/cron/crontabs/root

		fi
		;;

	h)
		usage
		;;
	\?)
		echo -e "[${RED}!${NC}] Opción incorrecta, por favor escoga una válida"
		sleep 2
		usage
		;;
	:)
		echo -e "[${GREEN}?${NC}] Hey, este programa necesita al menos una opción"
		sleep 2
		usage
		;;
	esac
  done
  exit 0
