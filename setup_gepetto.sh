#!/bin/bash

# Mettre à jour les paquets
apt-get update

# Installer les dépendances nécessaires
apt-get install -y curl build-essential python3-pip

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

echo "Installation terminée avec succès."

# Demarrer Ollama
ollama serve
