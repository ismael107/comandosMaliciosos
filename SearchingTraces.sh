#!/bin/bash

# Lista de comandos peligrosos
comandos=("arp" "base64" "crontab" "curl" "groups" "host" "insmod" "lsmod" "modprobe" "netstat" "systemctl")

# Archivos y directorios predefinidos a revisar
archivos=("$HOME/.bashrc" "$HOME/.profile" "/etc/crontab" "/etc/rc.local" "/etc/init.d/*" "/etc/systemd/system/*")

# Función para buscar comandos en archivos
buscar_comandos() {
    local archivo="$1"
    for cmd in "${comandos[@]}"; do
        if grep -q "$cmd" "$archivo"; then
            echo "El comando $cmd se encontró en el archivo $archivo"
        fi
    done
}

# Función para buscar cadenas en archivos
buscar_cadenas() {
    local archivo="$1"
    shift
    for cadena in "$@"; do
        if grep -q "$cadena" "$archivo"; then
            echo "La cadena '$cadena' se encontró en el archivo $archivo"
        fi
    done
}

# Recorrer y revisar cada archivo en los archivos predefinidos
revisar_archivos_predefinidos() {
    for archivo in "${archivos[@]}"; do
        if [ -f "$archivo" ]; then
            buscar_comandos "$archivo"
        elif [ -d "$archivo" ]; then
            for file in "$archivo"/*; do
                [ -f "$file" ] && buscar_comandos "$file"
            done
        fi
    done
}

# Recorrer y revisar cada archivo en la ruta especificada
revisar_archivos_personalizados() {
    local ruta="$1"
    shift
    if [ -f "$ruta" ]; then
        buscar_cadenas "$ruta" "$@"
    elif [ -d "$ruta" ]; then
        for file in $(find "$ruta" -type f); do
            buscar_cadenas "$file" "$@"
        done
    else
        echo "La ruta $ruta no es válida."
    fi
}

# Código de escape ANSI para color verde y fin de color
verde='\e[32m'
fin_color='\e[0m'

# Imprimir el rótulo con el color verde
echo -e "${verde}************************************"
echo "*          Searching for traces     *"
echo "************************************"
echo

# Imprimir la explicación en verde
echo -e "${verde}Este script busca comandos peligrosos y cadenas específicas en archivos predefinidos o en una ruta personalizada.${fin_color}"
echo

# Menú para seleccionar el modo de operación
echo "Seleccione el modo de operación:"
echo "1. Forma preestablecida (buscar comandos peligrosos en archivos específicos)"
echo "2. Forma personalizada (buscar cadenas específicas en una ruta proporcionada)"

read -p "Ingrese 1 o 2: " modo

if [ "$modo" == "1" ]; then
    revisar_archivos_predefinidos
elif [ "$modo" == "2" ]; then
    read -p "Ingrese la ruta a revisar: " ruta
    read -p "Ingrese las cadenas a buscar, separadas por espacio: " -a cadenas

    if [ -z "$ruta" ] || [ ${#cadenas[@]} -eq 0 ]; then
        echo "Debe proporcionar una ruta y al menos una cadena de búsqueda."
        exit 1
    fi

    revisar_archivos_personalizados "$ruta" "${cadenas[@]}"
else
    echo "Opción no válida. Por favor, ingrese 1 o 2."
    exit 1
fi
