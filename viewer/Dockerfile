# Étape 1 : Build de l'app avec Node.js 20
FROM node:20 AS build

RUN apt-get update && apt-get install -y git

WORKDIR /app

# Copier les fichiers package.json et package-lock.json
COPY package*.json ./

# Installer les dépendances
RUN npm install

# Copier tout le projet
COPY rss-viewer/ .
RUN rm -rf .git
RUN rm .gitignore

# Build de l'app React pour production
RUN npm run build

# Étape 2 : Serveur Nginx pour héberger l'app
FROM nginx:alpine

# Supprimer la config par défaut et ajouter la tienne si besoin
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d

# Copier les fichiers build dans le dossier Nginx
COPY --from=build /app/build /usr/share/nginx/html

# Exposer le port 80
EXPOSE 80

# Lancer Nginx
CMD ["nginx", "-g", "daemon off;"]
