#!/bin/bash
# Ruta: /usr/lib/nagios/plugins/check_clustat.sh

CLUSTAT_OUTPUT=$(pcs status 2>/dev/null)

if echo "$CLUSTAT_OUTPUT" | grep -q "Online:" && echo "$CLUSTAT_OUTPUT" | grep -q "Started"; then
    echo "OK - Clúster activo y recursos iniciados"
    exit 0
else
    echo "CRITICAL - Fallo en el clúster o recursos detenidos"
    exit 2
fi

