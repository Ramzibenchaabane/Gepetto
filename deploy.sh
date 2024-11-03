#!/bin/bash

# Script de déploiement pour Gepetto Frontend
echo "🔄 Mise à jour du système..."
sudo apt-get update
sudo apt-get upgrade -y

# Installation des dépendances
echo "📦 Installation des dépendances système..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs nginx

# Installation des outils globaux
echo "📦 Installation des outils globaux..."
sudo npm install -g pm2

# Création du projet Next.js
echo "🏗️ Création du projet Next.js..."
cd /home/ubuntu
npx create-next-app@latest gepetto-frontend --typescript --tailwind --eslint
cd gepetto-frontend

# Installation des dépendances additionnelles
echo "📦 Installation des dépendances du projet..."
npm install lucide-react @radix-ui/react-select @radix-ui/react-slot class-variance-authority clsx tailwind-merge

# Installation de shadcn/ui
echo "📦 Installation de shadcn/ui..."
npx shadcn-ui@latest init -y

# Installation des composants shadcn/ui nécessaires
echo "📦 Installation des composants shadcn/ui..."
npx shadcn-ui@latest add card
npx shadcn-ui@latest add button
npx shadcn-ui@latest add textarea
npx shadcn-ui@latest add select
npx shadcn-ui@latest add alert

# Récupération du composant GepettoInterface depuis GitHub
echo "📥 Récupération du composant depuis GitHub..."
cd /home/ubuntu
rm -rf Gepetto
git clone https://github.com/Ramzibenchaabane/Gepetto.git
mkdir -p gepetto-frontend/components
cp Gepetto/GepettoInterface.tsx gepetto-frontend/components/
rm -rf Gepetto

# Configuration de la page principale
echo "🔧 Configuration de la page principale..."
cd gepetto-frontend
cat > app/page.tsx << 'EOL'
import GepettoInterface from '../components/GepettoInterface';

export default function Home() {
  return <GepettoInterface />;
}
EOL

# Ajout de styles globaux
echo "🎨 Ajout des styles globaux..."
cat > app/globals.css << 'EOL'
@tailwind base;
@tailwind components;
@tailwind utilities;
 
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
 
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
 
    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;
 
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
 
    --secondary: 210 40% 96.1%;
    --secondary-foreground: 222.2 47.4% 11.2%;
 
    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;
 
    --accent: 210 40% 96.1%;
    --accent-foreground: 222.2 47.4% 11.2%;
 
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
 
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 222.2 84% 4.9%;
 
    --radius: 0.5rem;
  }
 
  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
 
    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;
 
    --popover: 222.2 84% 4.9%;
    --popover-foreground: 210 40% 98%;
 
    --primary: 210 40% 98%;
    --primary-foreground: 222.2 47.4% 11.2%;
 
    --secondary: 217.2 32.6% 17.5%;
    --secondary-foreground: 210 40% 98%;
 
    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;
 
    --accent: 217.2 32.6% 17.5%;
    --accent-foreground: 210 40% 98%;
 
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 210 40% 98%;
 
    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;
    --ring: 212.7 26.8% 83.9%;
  }
}
 
@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}
EOL

# Configuration Nginx
echo "🔧 Configuration de Nginx..."
sudo tee /etc/nginx/sites-available/gepetto << 'EOL'
server {
    listen 80;
    server_name $host;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOL

# Activation de la configuration Nginx
sudo ln -sf /etc/nginx/sites-available/gepetto /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx

# Build et démarrage
echo "🏗️ Build de l'application..."
npm run build

echo "🚀 Démarrage de l'application..."
pm2 start npm --name "gepetto" -- start

# Configuration du démarrage automatique
echo "⚙️ Configuration du démarrage automatique..."
pm2 save
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu

echo "✅ Déploiement terminé!"
echo "🌍 L'application devrait être accessible à l'adresse: http://$(curl -s ipinfo.io/ip)"
echo "⚠️ N'oubliez pas d'ouvrir le port 80 dans le groupe de sécurité de votre instance EC2!"