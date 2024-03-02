# !/bin/bash
# Script que chequea y lista los directorios del PATH
# -l, --list: lista los directorios del PATH
# -c, --check: chequea si un directorio está en el PATH (Acepta rutas absolutas y relativas)
# -h, --help: muestra la ayuda

# Función que muestra el mensaje de uso incorrecto del script
function usoIncorrecto {
    echo -e "\033[91;1mUso incorrecto del script.\033[0m"
    echo -e "Para ver la ayuda, ejecute: \033[93m$0 -h\033[0m o \033[93m$0 --help\033[0m"
    exit 1
}

# Si el usuario no pasa argumentos, se avisa el mal uso del script y se muestra el comando de ayuda
if [ $# -eq 0 ]; then
    usoIncorrecto
# Si el usuario pasa un argumento, se evalúa el argumento
elif [ $# -eq 1 ]; then
    case $1 in
        -l|--list)
            echo -e "Los directorios del PATH son:"
            echo -e $PATH | tr ':' '\n'
            ;;
        -h|--help)
            echo -e "Script que chequea y lista los directorios del \033[93;1mPATH\033[0m"
            echo -e "\033[93m-l, --list\033[0m: lista los directorios del PATH"
            echo -e "\033[93m-c, --check\033[0m: chequea si un directorio está en el PATH"
            echo -e "\033[93m-h, --help\033[0m: muestra la ayuda"
            ;;
        *)
            usoIncorrecto
            ;;
    esac
# Si el usuario pasa dos argumentos, se evalúa el segundo argumento
elif [ $# -eq 2 ]; then
    case $1 in
        -c|--check)
            # Revisamos si el directorio existe
            if [ ! -d $2 ]; then
                echo -e "\033[91;1mError:\033[0m El directorio \033[93m$2\033[0m no existe o no es un directorio."
                exit 1
            fi
            # Se obtiene la ruta absoluta del directorio
            R=$(realpath $2)
            echo -e "El directorio \033[94m$2\033[0m es: \033[93m$R\033[0m"
            if [[ $PATH == *$R* ]]; then
                echo -e "Estado: \033[92;1mSí\033[0m, el directorio \033[94m$2\033[0m está en el PATH"
            else
                echo -e "Estado: \033[91;1mNo\033[0m, el directorio \033[94m$2\033[0m no está en el PATH"
            fi
            ;;
        *)
            usoIncorrecto
            ;;
    esac
# Si el usuario pasa más de dos argumentos, se avisa el mal uso del script y se muestra el comando de ayuda
else
    usoIncorrecto
fi