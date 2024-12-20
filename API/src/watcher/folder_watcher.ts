import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';
import FormData from 'form-data';
import { qbittorrentAPI } from '../tools';

dotenv.config();
const DIRECTORY_TO_WATCH = process.env.TORRENT_FOLDER ?? "";

/////////////////////////////////////////////////////////////////////////////////
// Fonction pour ouvrir le fichier après l'écriture complète
function openFileWhenComplete(filepath: string): void {
	let lastSize = -1;

	const checkFileComplete = setInterval(() => {
		const currentSize = fs.statSync(filepath).size;

		if (currentSize === lastSize) {
			clearInterval(checkFileComplete);
			console.log(`Fichier complet : ${filepath}`);

			const formData = new FormData();
			formData.append('torrents', fs.createReadStream(filepath));

			qbittorrentAPI
				.post('/torrents/add', formData, {
					headers: formData.getHeaders(),
				})
				.then(() => {
					console.log(`Torrent ajouté avec succès : ${path.basename(filepath)}`);
				})
				.catch((error) => {
					console.error(
						`Erreur lors de l'ajout du torrent : ${
							error.response?.data || error.message
						}`
					);
				});
		} else {
			lastSize = currentSize;
		}
	}, 1000);
}

/////////////////////////////////////////////////////////////////////////////////
// Fonction pour commencer à surveiller le dossier
export function startFolderWatcher(): void {
	fs.watch(DIRECTORY_TO_WATCH, (eventType, filename) => {
		if (eventType === 'rename' && filename) {
			const filepath = path.join(DIRECTORY_TO_WATCH, filename);

			if (fs.existsSync(filepath) && !fs.lstatSync(filepath).isDirectory()) {
				console.log(`Fichier détecté : ${filepath}`);
				openFileWhenComplete(filepath);
			}
		}
	});

    console.log(`Surveillance du dossier : ${DIRECTORY_TO_WATCH}`);
}