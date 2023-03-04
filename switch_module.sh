#!/bin/bash
# -*- ENCODING: UTF-8 -*-

if lsmod | grep -q $1; then
  sudo modprobe -vr $1 && echo "$1 desactivado"
else
  sudo modprobe -v $1 && echo "$1 activado"
fi
exit
