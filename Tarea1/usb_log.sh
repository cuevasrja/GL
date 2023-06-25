#!/bin/bash

# Se usa este script mediante una regla de udev que se encuentra en /etc/udev/rules.d/usb-change.rules
# La regla es la siguiente:
# ACTION=="add", SUBSYSTEM=="usb", RUN+="/home/cuevasrja/usb_log.sh --run"
# ACTION=="remove", SUBSYSTEM=="usb", RUN+="/home/cuevasrja/usb_log.sh --run"

FILE="/home/cuevasrja/.log_usb.txt"
TEMP="/home/cuevasrja/.log_usb.temp"
TEMP2="/home/cuevasrja/.temp"
UDEV="/etc/udev/rules.d/usb-change.rules"

if [ -f $FILE ]; then
  touch -a /tmp/.log_usb.txt
else
  touch $FILE
fi

if [ -f $TEMP2 ]; then
  rm -f $TEMP2
fi

if [ "$1" = "--run" -o "$1" = "-r" -o $# -eq 0 ]; then
    if [ $(wc -l $FILE | cut -d " " -f 1) -eq 0 ]; then
        lsusb | while read line; do
        echo $line > $TEMP
        ID=$(cut -d " " -f 6 $TEMP)
        DATE=$(date +'%d/%m/%Y %H:%M:%S')
        echo "$ID | $DATE | Conectado" >> $FILE
    done
    elif [ $(($(wc -l $FILE | cut -d " " -f 1))) -lt $(($(lsusb | wc -l))) ]; then
        lsusb | while read line; do
            echo $line > $TEMP
            ID=$(cut -d " " -f 6 $TEMP)
            if $(grep -q "$ID" $FILE); then
                continue
            else
                DATE=$(date +'%d/%m/%Y %H:%M:%S')
                echo "$ID | $DATE | Conectado" >> $FILE
            fi
        done
    else
        cat $FILE | while read line; do
            echo $line > $TEMP
            ID=$(cut -d " " -f 1 $TEMP)
            ESTADO=$(cut -d " " -f 6 $TEMP)
            if $(lsusb | grep -q "$ID"); then
                if [ "$ESTADO" = "Desconectado" ]; then
                    DATE=$(date +'%d/%m/%Y %H:%M:%S')
                    LINE=$(grep -n "$ID" $FILE | cut -d ":" -f 1)
                    sed -i "${LINE}d" $FILE
                    echo "$ID | $DATE | Conectado" >> $FILE
                fi
            else
                if [ "$ESTADO" = "Conectado" ]; then
                    DATE=$(date +'%d/%m/%Y %H:%M:%S')
                    LINE=$(grep -n "$ID" $FILE | cut -d ":" -f 1)
                    sed -i "${LINE}d" $FILE
                    echo "$ID | $DATE | Desconectado" >> $FILE
                fi
            fi
        done
    fi
    rm -f $TEMP
elif [ "$1" = "--show" -o "$1" = "-s" ]; then
    echo "############################################################################################"
    echo -e "\033[33m    ID    | FECHA/HORA CONEXION | ESTADO\033[0m"
    cat $FILE
    LINES=$(wc -l $FILE | cut -d " " -f 1)
    echo -e "\n\033[33mTotal de registros: $LINES\033[0m"
    echo -e "\033[33mUltima actualizacion: $(date +'%d/%m/%Y %H:%M:%S')\033[0m"
    echo "El listado de puertos se encuentra en $FILE"
elif [ "$1" = "--delete" -o "$1" = "-d" ]; then
    ps | grep -e "usb_log.sh" > $TEMP2
    if $(grep -qv "$$" $TEMP2); then
        echo "Advertencia: Hay que detener el proceso primero"
    else
        rm -f $FILE && echo "Se reinicio el log de puertos USB"
    fi
    rm $TEMP2
elif [ "$1" = "--udev" -o "$1" = "-u" ]; then
    echo -e "La configuracion de udev es la siguiente: \n"
    cat $UDEV
    echo -e "\nEl listado de puertos se encuentra en $UDEV"
elif [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo "Este script registra los puertos USB que se conectan y desconectan
    [--run/-r]        Inicia el proceso de log. Ej: usb_log -r
    [--show/-s]       Muestra el log de puertos USB. Ej: usb_log -s
    [--delete/-d]     Reinicia el log de puertos USB. Ej: usb_log -d
    [--udev/-u]       Muestra la configuracion de udev. Ej: usb_log -u
    [--help/-h]       Muestra los comandos del script. Ej: usb_log help o usb_log -h

    El listado de puertos se encuentra en $FILE"
    exit
else
    echo -e "Comando invalido: Por favor escriba correctamente. \nEn caso de necesitar ayuda escriba: usb_log help o usb_log -h"
    exit
fi
