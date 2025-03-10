# HomeFlix

Dans le but d’élargir mes compétences, j’ai développé HomeFlix, une application complète permettant de télécharger et de visionner du contenu vidéo (films, séries, documentaires) à partir d’une source distante. L’objectif est d’offrir une expérience utilisateur fluide, moderne et intuitive.

![plot](./githubRes/presv1.webp)

## Architecture du système

### Le système est divisé en trois parties distinctes :

(A) L’application mobile
Une application cross-platform développée avec Flutter. Elle permet d’accéder à toute la bibliothèque disponible sur la source, d’effectuer des téléchargements et de visionner les contenus, que ce soit en ligne ou hors ligne.

(B) L’API serveur
Développée avec Node.js / Express, elle communique avec l’application pour :
- Gérer les téléchargements,
- Organiser la bibliothèque de contenu,
- Transmettre le flux vidéo en streaming,
- Fournir des informations sur l’état du serveur.

(C) L’API source
Cette API est conçue pour récupérer et formater les informations issues de la source distante avant de les transmettre aux autres composants du système. Étant adaptable à différentes sources de contenu, elle n’est pas fournie dans ce projet, laissant ainsi chacun libre de l’implémenter selon ses besoins.

⚠️ Responsabilité : Ce projet est fourni à des fins éducatives et son utilisation doit respecter les lois en vigueur. Je décline toute responsabilité quant à l’usage qui en est fait.

## APIs et technologies utilisées

### APIs mobilisées :
- TMDB API : pour obtenir les informations sur les films et séries,
- API source : à implémenter selon la source choisie,
- API serveur (B) : gestion des téléchargements et du streaming,
- API intermédiaire (C) : traitement et mise en forme des données provenant de la source.

### Technologies principales :
- Flutter : développement de l’application mobile,
- Node.js / Express : gestion du backend et des requêtes API.
	
## Installation et mise en route (version sans auth)

### Serveur et API

- Il vous faudra installer Linux sur une machine.

- Installer qbittorrent.

- Activer l'interface WEBAPI de qbittorrent dans les paramètres (Web user interface ...) et cocher 'bypass authentication for clients on localhost'.

- Ouvrir le port 4000 avec 'ufw allow 4000' sur votre machine.

- (Optionnel) ouvrir les ports 4000, 20 et 21 sur votre box pour que le serveur fonctionne en dehors de votre réseau.

- Copier le fichier API dans votre home
  
- Créer un fichier contentData.json à la racine de l'api

- écrir : {"tv" : {}, "movie": {}, "queue":{}} dans le fichier contentData.json

- Créer un fichier .env à la racine du dossier API.

- Ajouter [API_KEY="ce que vous voulez"] à votre .env.

- Ajouter [TORRENT_FOLDER="le chemin d'accès de vos fichier .torrent"] à votre .env

- Ajouter [CONTENT_FOLDER="le chemin d'accès de vos films et serie"] à votre .env

### (optionnel mais fortement recommandé) VPN

- Installer votre VPN favori avec un fichier de configuration openVPN (openvpn.udp) (car celui-ci ne réécrit pas systématiquement les priorités des interfaces réseaux).

- Modifier sa priorité réseau avec : sudo nmcli connection modify "nom du fichier openvpn.udp" ipv4.route-metric 200

- Lancer le vpn avec : sudo nmcli connection up "nom du fichier openvpn.udp" --ask (il faudra saisir la clef trouvable sur le site du vpn choisi)

- ajouter [VPN_PASS="votre clef vpn"] à votre .env (coté serveur).

- Enfin, aller dans qbittorrent et dans les paramètres avancés, sélectionner tun0 dans Network interface.

### App mobile

- Vous devrez ajouter un fichier .env à la racine du dossier de l'application.

- Ajouter votre clé API https://themoviedb.org/ (TMDB_KEY=...).

- Ajouter la clé API du serveur (NIGHTCENTER_KEY=...) (celle que vous avez choisie précédemment).
  
- Ajouter l'ip du serveur (NIGHTCENTER_IP=...) (votre ip public en cas d'ouverture ou privé sur votre réseau local)

- Enfin il ne vous reste plus qu'à build l'application pour l'os souhaité (il vous faudra une licence payante pour iOS).

### En cas de besoin ou de suggestion

Vous pouvez trouver de quoi me contacter sur mon site internet (il est joint à ce GitHub).
