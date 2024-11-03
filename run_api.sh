#!/bin/bash
# Télécharger le modèle nemotron
ollama pull nemotron
# Démarrer l'API FastAPI sur le port 5000
uvicorn main:app --host 0.0.0.0 --port 5000
