# !/bin/bash
# Script que administra los paquetes de una sala de computadoras
# -i, --install: instala un paquete de todos los equipos de la sala. Parámetros: nombre del paquete
# -r, --remove: desinstala un paquete de todos los equipos de la sala. Parámetros: nombre del paquete
# -I, --install-list: instala una lista de paquetes de todos los equipos de la sala. Parámetros: archivo con la lista de paquetes
# -R, --remove-list: desinstala una lista de paquetes de todos los equipos de la sala. Parámetros: archivo con la lista de paquetes
# -c, --check: verifica si un paquete está instalado en todos los equipos de la sala. Parámetros: nombre del paquete
# -l, --list: lista todos los paquetes instalados en un equipo de la sala y los guarda en un archivo. Parámetros: nombre/IP del equipo
# -h, --help: muestra la ayuda del script

# TODO: Crear un archivo con los nombres/IP de los equipos de la sala
EQUIPOS=equipos.txt

# Para que el script funcione correctamente, es necesario tener previamente configurada la autenticación SSH sin contraseña entre la máquina 
# local y la máquina remota. Para hacerlo, sigue estos pasos:
# 1. Genera un par de claves SSH en tu máquina local (si aún no lo has hecho). Puedes hacerlo con el siguiente comando:
# ssh-keygen -t rsa
# 2. Copia la clave pública a la máquina remota. Puedes hacerlo con el siguiente comando:
# ssh-copy-id xxxxxxx@xx
# 3. Ahora puedes iniciar sesión en la máquina remota sin contraseña. Si aún necesitas proporcionar una contraseña, es posible que debas 
# cambiar la configuración de SSH en la máquina remota para permitir la autenticación basada en claves.
# 4. Para verificar que la autenticación SSH sin contraseña está configurada correctamente, intenta conectarte a la máquina remota con el
# siguiente comando:
# ssh xxxxxxx@xx
# 5. (Opcional) Si deseas que la conexión SSH sea más segura, puedes deshabilitar la autenticación basada en contraseña en la máquina remota.
# Para hacerlo, sigue estos pasos:
# 5.1. Conéctate a la máquina remota con SSH.
# 5.2. Abre el archivo de configuración de SSH con un editor de texto. Por ejemplo, puedes usar vim:
# sudo vim /etc/ssh/sshd_config
# 5.3. Busca la línea que contiene la directiva PasswordAuthentication y cámbiala a no.
# PasswordAuthentication no
# 5.4. Guarda y cierra el archivo.
# 5.5. Reinicia el servicio SSH para aplicar los cambios:
# sudo systemctl restart sshd

# Función que muestra un mensaje de error y la ayuda del script
function show_error {
    echo -e "\033[91;1mError: $1\033[0m"
    echo -e "Ejecuta \033[93;1msalaAdmin.sh -h\033[0m para mostrar la ayuda del script"
}

# Verificamos que se haya pasado al menos un parámetro
if [ $# -eq 0 ]; then
    show_error "Se requiere al menos un parámetro"
    exit 1
fi
# Revisamos si el archivo con los nombres/IP de los equipos de la sala existe
if [ ! -f $EQUIPOS ]; then
    show_error "El archivo $EQUIPOS no existe"
    exit 1
fi

if [ !( $# -eq 1 && ($1 == "-h" || $1 == "--help") ) ]; then
    # Verificamos que el usuario haya configurado la autenticación SSH sin contraseña
    ssh -o BatchMode=yes $USUARIO@$(head -n 1 $EQUIPOS) exit > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        show_error "No se ha configurado la autenticación SSH sin contraseña"
        exit 1
    fi
    # Pedimos el usuario para la conexión SSH
    read -p "Usuario: " USUARIO
fi

# Función que muestra la ayuda del script
function show_help {
    echo -e "Script que administra los paquetes de una sala de computadoras"
    echo -e "Uso: \033[93;1msalaAdmin.sh [opciones] [parámetros]\033[0m"
    echo -e "Opciones:"
    echo -e "  \033[93;1m-i, --install\033[0m: instala un paquete de todos los equipos de la sala. Parámetros: nombre del paquete"
    echo -e "  \033[93;1m-r, --remove\033[0m: desinstala un paquete de todos los equipos de la sala. Parámetros: nombre del paquete"
    echo -e "  \033[93;1m-I, --install-list\033[0m: instala una lista de paquetes de todos los equipos de la sala. Parámetros: archivo con la lista de paquetes"
    echo -e "  \033[93;1m-R, --remove-list\033[0m: desinstala una lista de paquetes de todos los equipos de la sala. Parámetros: archivo con la lista de paquetes"
    echo -e "  \033[93;1m-c, --check\033[0m: verifica si un paquete está instalado en todos los equipos de la sala. Parámetros: nombre del paquete"
    echo -e "  \033[93;1m-l, --list\033[0m: lista todos los paquetes instalados en un equipo de la sala y los guarda en un archivo. Parámetros: nombre/IP del equipo"
    echo -e "  \033[93;1m-h, --help\033[0m: muestra la ayuda del script"
    echo 
    echo -e "\033[92;1mNota:\033[0m Para que el script funcione correctamente, se debe tener un archivo con los nombres/IP de los equipos de la sala llamado \033[93;1m$EQUIPOS\033[0m"
}

# Función que instala un paquete en todos los equipos de la sala
function install_package {
    for i in $(cat $EQUIPOS); do
        # Verificamos la conexión con el equipo (Si no hay conexión, se avisará y se pasará al siguiente equipo)
        if [ ! $(ping -c 1 $i) ]; then
            echo -e "\033[91;1mNo se pudo conectar con el equipo $i\033[0m"
            continue
        fi
        if [ $? -ne 0 ]; then
            echo -e "\033[91;1mNo se pudo conectar con el equipo $i\033[0m"
            continue
        fi
        # Revisamos si el paquete ya está instalado
        ssh "$USUARIO@$i" "dpkg -l | grep $1" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "\033[93;1mEl paquete $1 ya está instalado en el equipo $i\033[0m"
            continue
        fi
        # Instalamos el paquete
        echo -e "\033[93;1mInstalando paquete $1 en el equipo $i\033[0m"
        ssh "$USUARIO@$i" "sudo apt-get install -y $1"
    done
}

# Función que desinstala un paquete en todos los equipos de la sala
function remove_package {
    for i in $(cat $EQUIPOS); do
        # Verificamos la conexión con el equipo (Si no hay conexión, se avisará y se pasará al siguiente equipo)
        if [ ! $(ping -c 1 $i) ]; then
            echo -e "\033[91;1mNo se pudo conectar con el equipo $i\033[0m"
            continue
        fi
        if [ $? -ne 0 ]; then
            echo -e "\033[91;1mNo se pudo conectar con el equipo $i\033[0m"
            continue
        fi
        # Revisamos si el paquete ya está instalado
        ssh "$USUARIO@$i" "dpkg -l | grep $1" > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo -e "\033[93;1mEl paquete $1 no está instalado en el equipo $i\033[0m"
            continue
        fi
        # Desinstalamos el paquete
        echo -e "\033[93;1mDesinstalando paquete $1 en el equipo $i\033[0m"
        ssh "$USUARIO@$i" "sudo apt-get remove -y $1"
    done
}

# Función que instala una lista de paquetes en todos los equipos de la sala
function install_list {
    # Verificamos que el archivo exista
    if [ ! -f $1 ]; then
        show_error "El archivo $1 no existe"
        exit 1
    fi
    # Instalamos los paquetes
    for i in $(cat $1); do
        install_package $i
    done
}

# Función que desinstala una lista de paquetes en todos los equipos de la sala
function remove_list {
    # Verificamos que el archivo exista
    if [ ! -f $1 ]; then
        show_error "El archivo $1 no existe"
        exit 1
    fi
    # Desinstalamos los paquetes
    for i in $(cat $1); do
        remove_package $i
    done
}

# Función que verifica si un paquete está instalado en todos los equipos de la sala
function check_package {
    for i in $(cat $EQUIPOS); do
        # Verificamos la conexión con el equipo (Si no hay conexión, se avisará y se pasará al siguiente equipo)
        if [ ! $(ping -c 1 $i) ]; then
            echo -e "\033[91;1mNo se pudo conectar con el equipo $i\033[0m"
            continue
        fi
        if [ $? -ne 0 ]; then
            echo -e "\033[91;1mNo se pudo conectar con el equipo $i\033[0m"
            continue
        fi
        # Revisamos si el paquete ya está instalado
        ssh "$USUARIO@$i" "dpkg -l | grep $1" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "\033[93;1mEl paquete $1 está instalado en el equipo $i\033[0m"
        else
            echo -e "\033[93;1mEl paquete $1 no está instalado en el equipo $i\033[0m"
        fi
    done
}

# Función que lista todos los paquetes instalados en un equipo de la sala y los guarda en un archivo
function list_packages {
    # Verificamos la conexión con el equipo (Si no hay conexión, se avisará y se pasará al siguiente equipo)
    if [ ! $(ping -c 1 $1) ]; then
        echo -e "\033[91;1mNo se pudo conectar con el equipo $1\033[0m"
        return
    fi
    if [ $? -ne 0 ]; then
        echo -e "\033[91;1mNo se pudo conectar con el equipo $1\033[0m"
        return
    fi
    # Listamos los paquetes instalados
    ssh $1 "dpkg -l" > paquetes_$1.txt
    echo -e "\033[93;1mPaquetes instalados en el equipo $1 guardados en el archivo paquetes_$1.txt\033[0m"
}

# Verificamos las opciones
case $1 in
    -i|--install)
        # Si no se pasaron los parámetros requeridos, se muestra un error
        if [ $# -ne 2 ]; then
            show_error "Se requiere el nombre del paquete"
            exit 1
        # Si se pasaron mas de dos parámetros, se muestra un error
        elif [ $# -gt 2 ]; then
            show_error "Demasiados parámetros"
            exit 1
        fi
        install_package $2
        ;;
    -r|--remove)
        if [ $# -ne 2 ]; then
            show_error "Se requiere el nombre del paquete"
            exit 1
        elif [ $# -gt 2 ]; then
            show_error "Demasiados parámetros"
            exit 1
        fi
        remove_package $2
        ;;
    -I|--install-list)
        if [ $# -ne 2 ]; then
            show_error "Se requiere el archivo con la lista de paquetes"
            exit 1
        elif [ $# -gt 2 ]; then
            show_error "Demasiados parámetros"
            exit 1
        fi
        install_list $2
        ;;
    -R|--remove-list)
        if [ $# -ne 2 ]; then
            show_error "Se requiere el archivo con la lista de paquetes"
            exit 1
        elif [ $# -gt 2 ]; then
            show_error "Demasiados parámetros"
            exit 1
        fi
        remove_list $2
        ;;
    -c|--check)
        if [ $# -ne 2 ]; then
            show_error "Se requiere el nombre del paquete"
            exit 1
        elif [ $# -gt 2 ]; then
            show_error "Demasiados parámetros"
            exit 1
        fi
        check_package $2
        ;;
    -l|--list)
        if [ $# -ne 2 ]; then
            show_error "Se requiere el nombre/IP del equipo"
            exit 1
        elif [ $# -gt 2 ]; then
            show_error "Demasiados parámetros"
            exit 1
        fi
        list_packages $2
        ;;
    -h|--help)
        show_help
        ;;
    *)
        show_error "Opción no válida"
        exit 1
        ;;
esac

exit 0