#!/bin/bash

# Mettre à jour les paquets
apt-get update

# Installer les dépendances nécessaires
apt-get install -y curl build-essential python3-pip supervisor

# Installer Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Vérifier l'installation d'Ollama
if ! command -v ollama &> /dev/null
then
    echo "Ollama n'est pas installé correctement."
    exit 1
fi

# Installer les dépendances Python pour l'API
pip3 install fastapi uvicorn pydantic httpx

# Configurer supervisord pour Ollama
mkdir -p /etc/supervisor/conf.d

cat <<EOF > /etc/supervisor/conf.d/ollama.conf
[program:ollama]
command=$(which ollama) serve
autorestart=true
stderr_logfile=/var/log/ollama.err.log
stdout_logfile=/var/log/ollama.out.log
EOF

# Démarrer supervisord en arrière-plan
supervisord -c /etc/supervisor/supervisord.conf
