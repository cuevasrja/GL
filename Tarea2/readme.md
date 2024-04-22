# Scripts Tarea 2 - Grupo Linux

En este directorio se encuentran los scripts de la tarea 2 del grupo Linux. Son 2 scripts progamados en bash con la finalidad de automatizar y ayudar en ciertas tareas repetitivas que se puedan presentar en el MAC.

## Scripts

### 1. `pathChecker.sh`

Este script se encarga de verificar si un directorio existe en el PATH del sistema. Si el directorio existe en el PATH, el script imprime un mensaje indicando que el directorio existe en el PATH. Si el directorio no existe en el PATH, el script imprime un mensaje indicando que el directorio no existe en el PATH. Ademas, tambien lista todos los directorios o archivos que estan en el PATH.

> [!NOTE] Consideraciones:
> Se asume que el PATH esta definido en la variable de entorno PATH.
>
> Verifica los directorios que estan en la variable de entorno PATH unicamente del usuario que ejecuta el script

#### Uso

```bash
./pathChecker.sh -c <directorio> # Verifica si el directorio existe en el PATH

./pathChecker.sh -l # Lista todos los directorios o archivos que estan en el PATH

./pathChecker.sh -h # Muestra la ayuda
```

#### Funcionamiento

##### Chequeo

Para verificar si un directorio existe en el PATH, se ejecuta el script con la opcion `-c` seguido del directorio que se desea verificar. El script recorre cada directorio del PATH y compara si el directorio que se desea verificar es igual a alguno de los directorios del PATH. Si el directorio existe en el PATH, el script imprime un mensaje indicando que el directorio existe en el PATH. Si el directorio no existe en el PATH, el script imprime un mensaje indicando que el directorio no existe en el PATH.

##### Listado

Para listar todos los directorios o archivos que estan en el PATH, se ejecuta el script con la opcion `-l`. El script imprime cada directorio o archivo que esta en el PATH en una linea diferente. Para esto, se utiliza el comando `echo $PATH` para obtener el PATH y se utiliza el comando `tr` para reemplazar los `:` por saltos de linea.


### 2. `salaAdmin.sh`

Este script administra los paquetes de una sala de computadoras. El script permite instalar y desinstalar paquetes en las computadoras de la sala. Ademas, tambien permite listar los paquetes instalados en las computadoras de la sala.

#### Uso

```bash
./salaAdmin.sh -i <paquete> # Instala un paquete en todas las computadoras de la sala

./salaAdmin.sh -r <paquete> # Desinstala un paquete en todas las computadoras de la sala

./salaAdmin.sh -l <IP/hostname> # Lista los paquetes instalados en una computadora de la sala

./salaAdmin.sh -c <paquete> # Chequea si un paquete esta instalado en todas las computadoras de la sala

./salaAdmin.sh -I <archivo> # Instala paquetes en todas las computadoras de la sala desde un archivo

./salaAdmin.sh -R <archivo> # Desinstala paquetes en todas las computadoras de la sala desde un archivo

./salaAdmin.sh -h # Muestra la ayuda
```

#### Funcionamiento

##### Instalacion

Para instalar un paquete en todas las computadoras de la sala, se ejecuta el script con la opcion `-i` seguido del paquete que se desea instalar. El script recorre cada computadora de la sala y ejecuta el comando `ssh` para instalar el paquete en la computadora. Para esto, se utiliza el comando `apt-get install -y` para instalar el paquete en la computadora.

##### Desinstalacion

Para desinstalar un paquete en todas las computadoras de la sala, se ejecuta el script con la opcion `-r` seguido del paquete que se desea desinstalar. El script recorre cada computadora de la sala y ejecuta el comando `ssh` para desinstalar el paquete en la computadora. Para esto, se utiliza el comando `apt-get remove -y` para desinstalar el paquete en la computadora.

##### Listado

Para listar los paquetes instalados en una computadora de la sala, se ejecuta el script con la opcion `-l` seguido de la IP o hostname de la computadora que se desea listar. El script ejecuta el comando `ssh` para listar los paquetes instalados en la computadora. Para esto, se utiliza el comando `dpkg -l` para listar los paquetes instalados en la computadora.

##### Chequeo

Para chequear si un paquete esta instalado en todas las computadoras de la sala, se ejecuta el script con la opcion `-c` seguido del paquete que se desea chequear. El script recorre cada computadora de la sala y ejecuta el comando `ssh` para chequear si el paquete esta instalado en la computadora. Para esto, se utiliza el comando `dpkg -l` para listar los paquetes instalados en la computadora y se utiliza el comando `grep` para buscar el paquete en la lista de paquetes instalados.

##

Hecho por: **Juan Cuevas**