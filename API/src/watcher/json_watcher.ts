import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';
import { qbittorrentAPI, searchTorrent } from '../tools';

dotenv.config();
const DIRECTORY_TO_WATCH = process.env.CONTENT_FOLDER ?? "";
const JSON_CONTENT_PATH = path.join(__dirname, '../../contentData.json');

/////////////////////////////////////////////////////////////////////////////////
// interface  pour faciliter la lisibilité
interface MediaItem {
	title: string;
	originalTitle: string;
	name: string;
	media: boolean;
	percent:number;
}

interface DataStructure {
	tv: Record<string, MediaItem>;
	movie: Record<string, MediaItem>;
	queue: Record<string, MediaItem>;
}

/////////////////////////////////////////////////////////////////////////////////
// fonction pour récupérer toutes les infos d'un torrent
async function getTorrentProgress(torrentName: string,): Promise<number | undefined> {
	try {
		const torrentHash = await searchTorrent(torrentName);
		if (torrentHash == "")
			return undefined;
		await qbittorrentAPI.post('/auth/login');
		const response = await qbittorrentAPI.get(`/torrents/properties`, {
			params: { hash: torrentHash }
		});
		if (response.data) {
			console.log(`\x1b[0mTorrent trouvé : ${response.data}\x1b[0m`);
			return parseFloat((response.data.total_downloaded * 100 / response.data.total_size).toFixed(2));
		} else {
			console.error(`\x1b[31mTorrent "${torrentName}" non trouvé.\x1b[0m`);
		}
	} catch (error) {
		console.error(`\x1b[31mErreur lors de la récupération de l\'état du torrent : ${error}\x1b[0m`);
	}
	return undefined; 
}

/////////////////////////////////////////////////////////////////////////////////
// fonction pour vérifer l'état des films dans la queu, l'enregistrer et déplacer si besoin les contenu  terminés
async function checkAndProcessQueue() {
	try {
		const data = await fs.promises.readFile(JSON_CONTENT_PATH, 'utf8');
		const jsonData: DataStructure = JSON.parse(data);
		if (Object.keys(jsonData.queue).length === 0) return;

		for (const key in jsonData.queue) {
			const item = jsonData.queue[key];
			const percent = await getTorrentProgress(item.name);
			if (percent !== undefined) {
				item.percent = percent;
				jsonData.queue[key].percent = percent;
			}

			if (item.percent >= 99.5) { 
				if (item.media) {
					jsonData.movie[key] = item;
				} else {
					jsonData.tv[key] = item;
				}
				delete jsonData.queue[key];
			} else {
				console.log(`\x1b[33mEncore du boulot : ${percent}\x1b[0m`);
			}
		}

		try {
			await fs.promises.writeFile(JSON_CONTENT_PATH, JSON.stringify(jsonData, null, 2), 'utf8');
			console.log('\x1b[32mFichier JSON mis à jour avec succès\x1b[0m');
		} catch (err) {
			console.error(`\x1b[31mErreur lors de l\'écriture du fichier JSON : ${err}\x1b[0m`);
		}
	} catch (err) {
		console.error(`\x1b[31mErreur lors de la lecture du fichier JSON : ${err}\x1b[0m`);
	}
}

/////////////////////////////////////////////////////////////////////////////////
// lancement du listener
export function startJsonWatcher(): void {
	setInterval(checkAndProcessQueue, 4000);
	console.log(`Surveillance du dossier : ${DIRECTORY_TO_WATCH}`);
}
