#!/bin/bash

# Archivo a monitorear
FILE="/etc/shadow"
# Ruta donde se guarda el hash previo
HASH_FILE="/var/log/shadow_hash.txt"
# Archivo temporal
TEMP_HASH="/tmp/shadow_hash.tmp"

# Comando de correo
EMAIL="esteban.carlos2122@gmail.com"

# Calcular nuevo hash
sha256sum "$FILE" | awk '{print $1}' > "$TEMP_HASH"

# Verificar si ya existe hash previo
if [ -f "$HASH_FILE" ]; then
    if cmp -s "$HASH_FILE" "$TEMP_HASH"; then
        echo "[INFO] Sin cambios detectados en $FILE."
    else
        echo "[ALERTA] Se detectaron cambios en $FILE."
        echo "[ALERTA] Se detectaron cambios en $FILE a las $(date)" | mail -s "Alerta de integridad: $FILE modificado" "$EMAIL"
        cat "$TEMP_HASH" > "$HASH_FILE"
    fi
else
    echo "[INFO] Creando hash inicial de $FILE."
    cp "$TEMP_HASH" "$HASH_FILE"
fi

# Limpiar temporal
rm -f "$TEMP_HASH"

