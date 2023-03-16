#!/bin/bash
# -*- ENCODING: UTF-8 -*-
if [ $# -eq 0 ]; then
  echo "Comando invalido: Por favor escriba correctamente."
  echo "En caso de necesitar ayuda escriba: switch_module help o switch_module -h"
  exit
elif [ $1 = "help" ] || [ $1 = "-h" ]; then
  echo "Este script permite activar o desactivar un modulo del kernel. \nswitch_module [nombre_modulo]"
elif [ $# -eq 1 ]; then
  if lsmod | grep -q $1; then
    sudo modprobe -vr $1 && echo "$1 desactivado"
  else
    sudo modprobe -v $1 && echo "$1 activado"
  fi
else
  echo "Comando invalido: Por favor escriba correctamente.\nEn caso de necesitar ayuda escriba: switch_module help o switch_module -h"
fi

