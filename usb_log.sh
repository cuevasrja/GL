#!/bin/bash
  
if [ -f ~/.log_usb.txt ]; then
  touch -a ~/.log_usb.txt
else
  touch ~/.log_usb.txt
fi

if [ $1 = "start" ]; then
  while [ true ]; do
    lsusb | while read line; do
        echo $line > ~/.log_usb.temp
        PUERTO=$(cut -d " " -f 6 ~/.log_usb.temp)
        if $(grep -q $PUERTO ~/.log_usb.txt); then
            if $(grep -q "DESCONECTADO" ~/.log_usb.temp); then
                FECHA=$(date +"%d/%m/%Y %H:%M:%S")
                NUM=$(grep -n "$PUERTO" ~/.log_usb.txt | cut -d ":" -f 1)
                sed -i "${NUM}d" ~/.log_usb.txt
                echo "$PUERTO | $FECHA | CONECTADO" >> ~/.log_usb.txt
            else
                continue
            fi
        else
            FECHA=$(date +"%d/%m/%Y %H:%M:%S")
            echo "$PUERTO | $FECHA | CONECTADO" >> ~/.log_usb.txt
        fi
    done
  done
  rm -f ~/.log_usb.temp
elif [ "$1" = "stop" ]; then
    ID=$(jobs -l | grep "usb_log.sh" | cut -d " " -f 2)
    kill $ID
    echo "Se detuvo el proceso de log"
elif [ "$1" = "show" ]; then
    echo "############################################################################################"
    echo "PUERTO |  FECHA/HORA CONEXION | ESTADO"
    cat ~/.log_usb.txt
elif [ "$1" = "help" ]; then
    echo "Este script registra los puertos USB que se conectan y desconectan
    [start]         Inicia el proceso de log. Ej: usb_log start
    [stop]          Detiene el proceso de log. Ej: usb_log stop
    [show]          Muestra el log de puertos USB. Ej: usb_log show
    [help]          Muestra los comandos del script. Ej: usb_log help"
else
    echo "Comando invalido: Por favor escriba correctamente.
    En caso de necesitar ayuda escriba: usb_log help"
fi

