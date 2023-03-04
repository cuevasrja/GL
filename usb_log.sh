#!/bin/bash

echo "############################################################################################" >> ~/log_usb.txt
echo "PUERTO |  FECHA/HORA CONEXION | FECHA/HORA DESCONEXION" >> ~/log_usb.txt 
date >> ~/log_usb.txt; echo ""  >> ~/log_usb.txt; ls -lhA --time-style=+%d-%m-%Y-%T | grep usb | awk '{print $9,$6,$7}'>> ~/log_usb.txt; echo ""  >> ~/log_usb.txt

#No se que hacer aqui xDDDD
