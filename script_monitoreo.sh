#!/bin/bash

# Archivos a monitorear (puedes agregar más separados por espacio)
FILES_TO_MONITOR=("/etc/shadow")
HASH_DIR="/var/lib/integrity_hashes"
LOG_FILE="/var/log/monitor_integridad.log"
EMAIL="tu_correo@example.com"


function log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

function verificar_archivo() {
    local file="$1"
    local filename=$(basename "$file")
    local hash_file="$HASH_DIR/${filename}.sha256"
    local temp_hash=$(mktemp)

    if [ ! -r "$file" ]; then
        log "ERROR: No se puede leer $file. ¿Tienes permisos de root?"
        return 1
    fi

    sha256sum "$file" | awk '{print $1}' > "$temp_hash"

    if [ -f "$hash_file" ]; then
        if cmp -s "$hash_file" "$temp_hash"; then
            log "[OK] Sin cambios en $file"
        else
            log "[ALERTA] Cambios detectados en $file"
            echo "⚠️ Se detectaron cambios en $file a las $(date)" | mail -s "ALERTA de integridad: $file modificado" "$EMAIL"
            cp "$temp_hash" "$hash_file"
        fi
    else
        log "[INFO] Hash inicial generado para $file"
        mkdir -p "$HASH_DIR"
        cp "$temp_hash" "$hash_file"
    fi

    rm -f "$temp_hash"
}

log "=== Iniciando monitoreo de integridad ==="
for file in "${FILES_TO_MONITOR[@]}"; do
    verificar_archivo "$file"
done
log "=== Monitoreo finalizado ==="
