from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import httpx
import json

app = FastAPI(
    title="Gepetto API",
    description="API pour interagir avec Gepetto",
    version="1.0.0"
)

# Modèles de données
class GenerateRequest(BaseModel):
    model: str
    prompt: str

class PullRequest(BaseModel):
    model: str

class DeleteRequest(BaseModel):
    model: str

# Endpoints

@app.post("/generate", summary="Générer du texte avec un modèle")
async def generate_text(request: GenerateRequest):
    try:
        async with httpx.AsyncClient(timeout=360.0) as client:
            response = await client.post(
                "http://localhost:11434/api/generate",
                json=request.dict()
            )
            response.raise_for_status()

            # Traiter la réponse brute ligne par ligne
            try:
                response_lines = response.text.splitlines()
                json_responses = [json.loads(line) for line in response_lines]
                response_text = ''.join([obj['response'] for obj in json_responses])
                return {"model": request.model, "response": response_text}
            except json.decoder.JSONDecodeError as e:
                raise HTTPException(status_code=500, detail=f"Erreur de décodage JSON : {str(e)}")
    except httpx.HTTPError as exc:
        raise HTTPException(status_code=exc.response.status_code if exc.response else 500, detail=str(exc))

@app.get("/models", summary="Lister les modèles disponibles")
async def list_models():
    try:
        async with httpx.AsyncClient(timeout=360.0) as client:
            response = await client.get("http://localhost:11434/api/models")
            response.raise_for_status()
            return response.json()
    except httpx.HTTPError as exc:
        raise HTTPException(status_code=exc.response.status_code if exc.response else 500, detail=str(exc))

@app.post("/pull", summary="Télécharger un modèle")
async def pull_model(request: PullRequest):
    try:
        async with httpx.AsyncClient(timeout=360.0) as client:
            response = await client.post(
                "http://localhost:11434/api/pull",
                json={"model": request.model}
            )
            response.raise_for_status()
            return {"detail": f"Modèle {request.model} téléchargé avec succès"}
    except httpx.HTTPError as exc:
        raise HTTPException(status_code=exc.response.status_code if exc.response else 500, detail=str(exc))

@app.delete("/delete", summary="Supprimer un modèle")
async def delete_model(request: DeleteRequest):
    try:
        async with httpx.AsyncClient(timeout=360.0) as client:
            response = await client.delete(
                f"http://localhost:11434/api/models/{request.model}"
            )
            response.raise_for_status()
            return {"detail": f"Modèle {request.model} supprimé avec succès"}
    except httpx.HTTPError as exc:
        raise HTTPException(status_code=exc.response.status_code if exc.response else 500, detail=str(exc))

@app.post("/stop", summary="Arrêter une génération en cours")
async def stop_generation():
    try:
        async with httpx.AsyncClient(timeout=360.0) as client:
            response = await client.post("http://localhost:11434/api/stop")
            response.raise_for_status()
            return {"detail": "Génération arrêtée"}
    except httpx.HTTPError as exc:
        raise HTTPException(status_code=exc.response.status_code if exc.response else 500, detail=str(exc))
