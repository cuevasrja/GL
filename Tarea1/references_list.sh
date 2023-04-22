#!/bin/bash

if [ -d ~/.refs ]; then
  if [ -f ~/.refs/referencias.txt ]; then
    touch -a ~/.refs/referencias.txt
  else
    touch ~/.refs/referencias.txt
  fi
else
  mkdir ~/.refs
  if [ -f ~/.refs/referencias.txt ]; then
    touch -a ~/.refs/referencias.txt
  else
    touch ~/.refs/referencias.txt
  fi
fi

if [ $# -eq 0 ]; then
  echo -e "Comando invalido: Por favor escriba correctamente.\nEn caso de necesitar ayuda escriba: references_list help o references_list -h"
elif [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  echo "Este script lee la lista de referencias
    [--add/-a]          Agrega una nueva referencia. Ej: references_list -a [Referencia]
    [--delete/d]        Elimina una referencia. Ej: references_list -d [Referencia]
    [--delete-all/-D]   Elimina todas las referencias. Ej: references_list -D
    [--show/-s]         Muestra todas las referencias almacenadas en referencias.txt. Ej: references_list -s
    [--change/-c]       Cambia el permiso de una referencia. Ej: references_list -c [Mod] [Referencia]
    [--change-all/-C]   Cambia el permiso de todas las referencias registradas. references_list -C [Mod]
    [--help/-h]         Muestra los comandos del script. Ej: references_list --help o references_list -h

    Las referencias y su listado se guardan en la carpeta ~/.refs"
elif [ "$1" == "--show" ] || [ "$1" == "-s" ]; then
  echo -e "REFERENCIAS \nLas refrencias existentes van a parecer \033[34masi\033[0m y las que no existen \033[41masi\033[0m"
  lines=$(wc -l ~/.refs/referencias.txt | cut -d " " -f 1)
  if [ $lines -eq 0 ]; then
    echo "No hay referencias guardadas"
  else
    cat ~/.refs/referencias.txt | while read line; do
      echo $line > ~/.refs/temp
      REF=$(cut -d " " -f 1 ~/.refs/temp)
      DIR=$(cut -d " " -f 3 ~/.refs/temp)
      if [ -e "$DIR" ]; then
        echo -e "\033[34m${line}\033[0m"
      else
        echo -e "\033[41m${REF}\033[0m --> \033[41m${DIR}\033[0m"
      fi
    done
    rm ~/.refs/temp
  fi
  echo -e "\nLas referencias y su listado se guardan en la carpeta ~/.refs"
elif [ "--delete-all" == "$1" ] || [ "$1" == "-D" ]; then
  find ~/.refs/ -mindepth 1 -true -delete && echo "Se eliminaron todas las referencias"
elif [ "--add" == "$1" -a -n $2 ] || [ "$1" == "-a" -a -n $2 ]; then
  echo $2 > ~/.refs/temp
  ARCH=$(cut -d "/" -f 1-2 ~/.refs/temp)
  R=$(realpath $2)
  if [ $2 = "/" -o $2 = "/boot" ]; then
    echo "No podemos referencias esta ruta por seguridad"
  elif $(grep -q "$R$" ~/.refs/referencias.txt); then
    echo "Advertencia: Esta referencia ya existe"
  elif [ "/media" = $ARCH ]; then
    echo "Advertencia: No puede referenciar un dispositivo"
  else
    REF=$(uuidgen)
    if [ -e $R ]; then
      ln -s $2 ~/.refs/$REF && echo "Se guardo la referencia a $R/$REST" && echo "$REF --> $R" >> ~/.refs/referencias.txt
    else
      ln -s $2 ~/.refs/$REF && echo "Advertencia: $2 no existe este archivo" && echo "Se agrego $2" && echo "$REF --> $2" >> ~/.refs/referencias.txt
    fi
  fi
  rm -f ~.refs/temp
elif [ "--delete" == "$1" -a -n "$2" ] || [ "$1" == "-d" -a -n "$2" ]; then
  R=$(realpath $2)
  P=$(grep -e "$R$" ~/.refs/referencias.txt)
  echo $P > ~/.refs/temp
  REF=$(cut -d " " -f 1 ~/.refs/temp)
  NUM=$(grep -n "$P" ~/.refs/referencias.txt | cut -d ":" -f 1)
  if $(grep -qe  "$REF" ~/.refs/referencias.txt); then
    if $(ls ~/.refs/ | grep -q $REF); then
      unlink ~/.refs/$REF && echo "Se eliminó la referencia a $2" && sed -i "${NUM}d" ~/.refs/referencias.txt
    else
      sed -i "${NUM}d" ~/.refs/referencias.txt && echo "Advertencia: La referencia de $2 no existe, por lo que va a ser eliminada de la lista"
    fi
  else
    echo "Advertencia: $2 no existe"
  fi
  rm -f ~/.refs/temp
elif [ "--change-all" == "$1" -a -n $2 ] || [ "$1" == "-C" -a -n $2 ]; then
  cat ~/.refs/referencias.txt | while read line; do
    echo $line > ~/.refs/temp
    R=$(cat ~/.refs/temp | cut -d " " -f 3)
    chmod $2 $R
  done
  rm -f ~/.refs/temp
  echo "Se cambiaron los permisos de todas las referencias"
elif [ "--change" = "$1" -a -n "$2" -a -n "$3" ] || [ "$1" == "-c" -a -n "$2" -a -n "$3" ]; then
  R=$(realpath $3)
  REF=$(grep $R ~/.refs/referencias.txt | cut -d " " -f 1)
  chmod $2 $R && echo "Se cambio el permiso de $R"
else
  echo -e "Comando invalido: Por favor escriba correctamente.\nEn caso de necesitar ayuda, escriba: references_list --help o references_list -h"
fi
