#!/bin/bash
  
if [ -f ~/.log_usb.txt ]; then
  touch -a ~/.log_usb.txt
else
  touch ~/.log_usb.txt
fi

if [ -f ~/.temp ]; then
  rm -f ~/.temp
fi

if [ $# -eq 0 ]; then
  echo -e "Comando invalido: Por favor escriba correctamente.\nEn caso de necesitar ayuda escriba: usb_log --help o usb_log -h"
elif [ "$1" = "--run" -o "$1" = "-r" ]; then
  while [ true ]; do
    if [ $(wc -l ~/.log_usb.txt | cut -d " " -f 1) -eq 0 ]; then
        lsusb | while read line; do
            echo $line > ~/.log_usb.temp
            ID=$(cut -d " " -f 6 ~/.log_usb.temp)
            DATE=$(date +'%d/%m/%Y %H:%M:%S')
            echo "$ID | $DATE | Conectado" >> ~/.log_usb.txt
            echo -e "\nSe conecto $ID"
        done
    elif [ $(($(wc -l ~/.log_usb.txt | cut -d " " -f 1))) -lt $(($(lsusb | wc -l))) ]; then
        lsusb | while read line; do
            echo $line > ~/.log_usb.temp
            ID=$(cut -d " " -f 6 ~/.log_usb.temp)
            if $(grep -q "$ID" ~/.log_usb.txt); then
                continue
            else
                DATE=$(date +'%d/%m/%Y %H:%M:%S')
                echo "$ID | $DATE | Conectado" >> ~/.log_usb.txt
                echo -e "\nSe conecto $ID"
            fi
        done
    else
        cat ~/.log_usb.txt | while read line; do
            echo $line > ~/.log_usb.temp
            ID=$(cut -d " " -f 1 ~/.log_usb.temp)
            ESTADO=$(cut -d " " -f 6 ~/.log_usb.temp)
            if $(lsusb | grep -q "$ID"); then
                if [ "$ESTADO" = "Desconectado" ]; then
                    DATE=$(date +'%d/%m/%Y %H:%M:%S')
                    LINE=$(grep -n "$ID" ~/.log_usb.txt | cut -d ":" -f 1)
                    sed -i "${LINE}d" ~/.log_usb.txt
                    echo "$ID | $DATE | Conectado" >> ~/.log_usb.txt
                    echo -e "\nSe conecto $ID"
                fi
            else
                if [ "$ESTADO" = "Conectado" ]; then
                    DATE=$(date +'%d/%m/%Y %H:%M:%S')
                    LINE=$(grep -n "$ID" ~/.log_usb.txt | cut -d ":" -f 1)
                    sed -i "${LINE}d" ~/.log_usb.txt
                    echo "$ID | $DATE | Desconectado" >> ~/.log_usb.txt
                    echo -e "\nSe desconecto $ID"
                fi
            fi
        done
    fi
  done
  rm -f ~/.log_usb.temp
elif [ "$1" = "--kill" -o "$1" = "-k" ]; then
    ps | grep -e "usb_log.sh" > ~/.temp
    ID=$(grep -v "$$" ~/.temp | cut -d " " -f 1)
    kill $ID && echo "Se detuvo el proceso de log de puertos USB"
    exit
elif [ "$1" = "--show" -o "$1" = "-s" ]; then
    echo "############################################################################################"
    echo -e "\033[33m    ID    | FECHA/HORA CONEXION | ESTADO\033[0m"
    cat ~/.log_usb.txt
    LINES=$(wc -l ~/.log_usb.txt | cut -d " " -f 1)
    echo -e "\n\033[33mTotal de registros: $LINES\033[0m"
    echo -e "\033[33mUltima actualizacion: $(date +'%d/%m/%Y %H:%M:%S')\033[0m"
    echo "El listado de puertos se encuentra en ~/.log_usb.txt"
elif [ "$1" = "--delete" -o "$1" = "-d" ]; then
    rm -f ~/.log_usb.txt && echo "Se reinicio el log de puertos USB"
elif [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo "Este script registra los puertos USB que se conectan y desconectan
    [--run/-r]        Inicia el proceso de log. Ej: usb_log -r
    [--kill/-k]       Detiene el proceso de log. Ej: usb_log -k
    [--show/-s]       Muestra el log de puertos USB. Ej: usb_log -s
    [--delete/-d]     Reinicia el log de puertos USB. Ej: usb_log -d
    [--help/-h]       Muestra los comandos del script. Ej: usb_log help o usb_log -h

    El listado de puertos se encuentra en ~/.log_usb.txt"
    exit
else
    echo -e "Comando invalido: Por favor escriba correctamente. \nEn caso de necesitar ayuda escriba: usb_log help o usb_log -h"
    exit
fi
