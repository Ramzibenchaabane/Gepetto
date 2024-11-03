import React, { useState } from 'react';
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Loader2, Send, RotateCcw } from "lucide-react";
import { Alert, AlertTitle, AlertDescription } from "@/components/ui/alert";

const API_URL = 'http://66.114.112.70:17539/generate';

const GepettoInterface = () => {
  const [input, setInput] = useState('');
  const [response, setResponse] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [model, setModel] = useState('default');

  const handleSubmit = async () => {
    setLoading(true);
    setError('');
    
    try {
      const response = await fetch(API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: model,
          prompt: input
        })
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.detail?.[0]?.msg || 'Une erreur est survenue');
      }

      const data = await response.json();
      setResponse(data);
    } catch (err) {
      setError(err.message || 'Une erreur est survenue lors de la communication avec le serveur');
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setInput('');
    setResponse('');
    setError('');
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-900 to-gray-800">
      {/* Header avec logo Accenture */}
      <div className="bg-black p-4">
        <div className="max-w-7xl mx-auto flex justify-between items-center">
          <div className="flex items-center gap-8">
            {/* Placeholder pour le logo Accenture - à remplacer par votre vrai logo */}
            <div className="w-32 h-8 bg-purple-500 flex items-center justify-center text-white font-bold">
              ACCENTURE
            </div>
            <div className="h-8 w-px bg-gray-700" /> {/* Séparateur vertical */}
            <div>
              <h1 className="text-2xl font-bold text-white">Gepetto</h1>
              <p className="text-sm text-gray-400">Powered by Accenture Technology</p>
            </div>
          </div>
          <Select value={model} onValueChange={setModel}>
            <SelectTrigger className="w-[180px] bg-gray-800 text-white border-purple-500">
              <SelectValue placeholder="Sélectionner un modèle" />
            </SelectTrigger>
            <SelectContent className="bg-gray-800 text-white border-purple-500">
              <SelectItem value="default">Modèle par défaut</SelectItem>
              <SelectItem value="fast">Mode rapide</SelectItem>
              <SelectItem value="precise">Mode précis</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto p-8 flex gap-6">
        {/* Input Section */}
        <div className="w-1/2 space-y-6">
          <Card className="bg-gray-800 border-purple-500 border">
            <CardHeader>
              <CardTitle className="text-white">Prompt</CardTitle>
            </CardHeader>
            <CardContent>
              <Textarea
                value={input}
                onChange={(e) => setInput(e.target.value)}
                placeholder="Entrez votre prompt ici..."
                className="min-h-[400px] bg-gray-700 text-white border-purple-500 focus:border-purple-400"
              />
              
              {/* Error Alert */}
              {error && (
                <Alert variant="destructive" className="mt-4 bg-red-900 border-red-500">
                  <AlertTitle>Erreur</AlertTitle>
                  <AlertDescription>{error}</AlertDescription>
                </Alert>
              )}

              {/* Button Group */}
              <div className="flex justify-end gap-4 mt-4">
                <Button 
                  variant="outline" 
                  onClick={handleReset}
                  className="bg-transparent border-purple-500 text-purple-500 hover:bg-purple-500 hover:text-white">
                  <RotateCcw className="mr-2 h-4 w-4" />
                  Réinitialiser
                </Button>
                <Button 
                  onClick={handleSubmit}
                  disabled={loading || !input}
                  className="bg-purple-500 text-white hover:bg-purple-600">
                  {loading ? (
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  ) : (
                    <Send className="mr-2 h-4 w-4" />
                  )}
                  Envoyer
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Output Section */}
        <div className="w-1/2">
          <Card className="bg-gray-800 border-purple-500 border h-full">
            <CardHeader>
              <CardTitle className="text-white">Réponse</CardTitle>
            </CardHeader>
            <CardContent>
              {loading ? (
                <div className="flex items-center justify-center h-[400px]">
                  <Loader2 className="h-8 w-8 animate-spin text-purple-500" />
                </div>
              ) : response ? (
                <div className="bg-gray-700 p-4 rounded-lg border border-purple-500 min-h-[400px]">
                  <p className="text-white whitespace-pre-wrap">{response}</p>
                </div>
              ) : (
                <div className="flex items-center justify-center h-[400px] text-gray-500">
                  En attente d'un prompt...
                </div>
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
};

export default GepettoInterface;