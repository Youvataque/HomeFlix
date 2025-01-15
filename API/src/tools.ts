import axios from "axios";
import { exec } from "child_process";
import fs from 'fs';
import Levenshtein from "levenshtein";
import path from 'path';
import util from "util";
import dotenv from "dotenv";

interface FileSystemItem {
    name: string;
    type: 'file' | 'directory';
}

dotenv.config();

/////////////////////////////////////////////////////////////////////////////////
// déclaration de l'api qbittorrent
export const qbittorrentAPI = axios.create({
	baseURL: 'http://localhost:8080/api/v2',
	timeout: 3700,
});
  
/////////////////////////////////////////////////////////////////////////////////
// fonction pour retirer les accents des titres avant comparaison
export function removeAccents(str: string): string {
	return str.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
}

/////////////////////////////////////////////////////////////////////////////////
// normalise une str
function cleanName(name: string): string {
	return removeAccents(name.toLowerCase().replace('&', "and").replace(/[\s._\-:(),]+/g, ' ').trim());
}

/////////////////////////////////////////////////////////////////////////////////
// fonction pour supprimer un torrent
export async function deleteOneTorrent(torrentHash: string): Promise<boolean> {
	try {
		if (torrentHash != "") {
			console.log(`\x1b[33mTrying to delete torrent with hash : ${torrentHash}\x1b[0m`);
			await qbittorrentAPI.post('/torrents/delete', 
				new URLSearchParams({
				  hashes: torrentHash,
				  deleteFiles: "true"
				}), 
				{
				  headers: {
					'Content-Type': 'application/x-www-form-urlencoded'
				  }
				}
			  );
			console.log(`\x1b[32m${torrentHash} has been deleted with success.\x1b[0m`);
			return true;
		}  else {
			console.error('\x1b[31mNo torrent has been found !\x1b[0m');
			return false;
		}
	} catch (error) {
		console.error(`\x1b[31mError during deleting : ${error}\x1b[0m`);
		return false;
	}
}

/////////////////////////////////////////////////////////////////////////////////
// fonction pour supprimer chaques torrent d'une série
export async function deleteAllTorrent(newData: any) : Promise<boolean>{
	try {
		const seasons = newData['seasons'];
		for (const key in seasons) {
			if (seasons[key]["episode"].length == 1) {
				const torrentHash = await searchTorrent(seasons[key]["title"]);
				await deleteOneTorrent(torrentHash);
			} else {
				if (seasons[key]["episode"].length > 1) {
					const titles = seasons[key]["titles"];
					for (let x = 0; x < titles.length; x++) {
						const torrenthash = await searchTorrent(titles[x]);
						await deleteOneTorrent(torrenthash);
					}
				}
			}
		}
		return true;
	} catch (error) {
		console.error(`\x1b[31mAn error has occured : ${error}\x1b[0m`);
		return false;
	}
}

/////////////////////////////////////////////////////////////////////////////////
// supprimer les données d'une oeuvre de l'api
export async function removeFromJson(where:string, id:string):Promise<boolean> {
	const filePath = path.join(__dirname, '../contentData.json');
	fs.readFile(
		filePath, 'utf8', (err, data) => {
			if (err) console.error(`\x1b[31mCan't read json : ${err}\x1b[0m`);
			const jsonData = JSON.parse(data);
			if (jsonData[where] && jsonData[where][id]) {
				delete jsonData[where][id];
				fs.writeFile(filePath, JSON.stringify(jsonData, null, 2), 'utf8', (err) => {
					if (err) {
						console.error(`\x1b[31mError during writing json : ${err}\x1b[0m`);
						return false;
					} else {
						console.log(`\x1b[32m${id} has been deleted from ${where} with success.\x1b[0m`);
						return true;
					}
				});
			} else {
				console.error(`\x1b[31m${id} not found in ${where}.\x1b[0m`);
				return false;
			}
		}
	);
	return false;
}

/////////////////////////////////////////////////////////////////////////////////
// vérifie qu'un fichier json est  valide avant d'écrire dessus
export function isValidJson(jsonString: string): boolean {
	try {
		JSON.parse(jsonString);
		return true;
	} catch (e) {
		return false;
	}
}

/////////////////////////////////////////////////////////////////////////////////
// Calcule la similarité entre deux noms avec pondération pour titre et métadonnées
function calculateWordSimilarity2(name: string, comparedName: string): number {
	const targetInfo = extractInfo(name).split(" ");
	const comparedInfo = extractInfo(comparedName).split(" ");
	let matchScore = 0;
	let totalScore = 0;

	targetInfo.forEach((word, index) => {
		let weight = 1;
		if (index === 0) {
			weight = 5;
		} 
		if (word.match(/^s\d{2}$/i)) {
			weight = 4;
		}
		if (word.match(/^e\d{2}$/i)) {
			weight = 3;
		}
		totalScore += weight;
		if (comparedInfo.includes(word)) {
			matchScore += weight;
		}
	});
	const titleSimilarity = calculateWordSimilarity(cleanName(name), cleanName(comparedName));
	const finalScore = (matchScore / totalScore) * 100;
	return 0.7 * finalScore + 0.3 * titleSimilarity;
}

/////////////////////////////////////////////////////////////////////////////////
// calclue la probabilité que le nom corresponde au torrent en cours
function calculateWordSimilarity(str1: string, str2: string): number {
	const distance = new Levenshtein(str1, str2);
	const maxLength = Math.max(str1.length, str2.length);
	return ((maxLength - distance.distance) / maxLength) * 100;
}

/////////////////////////////////////////////////////////////////////////////////
// vérifie si le titre est un film
function isMovie(title: string): boolean {
	const seasonPattern = /S\d{2}/i;
	const episodePattern = /E\d{2}/i;
	if (seasonPattern.test(title) || episodePattern.test(title)) {
		return false;
	}
	return true;
}

/////////////////////////////////////////////////////////////////////////////////
// extrait les informations d'un nom de fichier
function extractInfo(name: string): string {
	const match = name.match(/s\d{2}e\d{2}|s\d{2}/i);

	let season = "";
	let episode = "";
	let title = "";

	if (match) {
		const seasonEpisode = match[0].toLowerCase();
		season = seasonEpisode.startsWith("s") ? seasonEpisode.slice(0, 3) : "";
		episode = seasonEpisode.includes("e") ? seasonEpisode.slice(3) : "";
		title = name.split(match[0])[0].trim();
	} else {
		title = name.trim();
	}
	return `${title} ${season} ${episode}`.trim();
}

/////////////////////////////////////////////////////////////////////////////////
// recherche un torrent dans qbittorrent à partir d'un nom unique (nom d'archive)
export async function searchTorrent(name: string): Promise<string> {
	let probability = {
		percent: 70,
		content: ""
	};
	try {
		await qbittorrentAPI.post('/auth/login');
		const response = await qbittorrentAPI.get('/torrents/info');
		name = cleanName(name);
		response.data.forEach((torrent: { name: string, hash: string }) => {
			const torrentName = cleanName(torrent.name);
			const similarityPercentage = calculateWordSimilarity2(name, torrentName);
			if (similarityPercentage > probability.percent) {
				probability.percent = similarityPercentage;
				probability.content = torrent.hash;
			}
		});
		console.log(`\x1b[32mThe most comparable torrent is : "${probability.content}" with ${probability.percent}% of similarity.\x1b[0m`);
	} catch (error) {
		console.error(`\x1b[31mError during torrent search : ${error}\x1b[0m`);
	}
	return probability.content;
}

/////////////////////////////////////////////////////////////////////////////////
// lit le contenu d'un ls -l
function parseLsOutput(lsOutput: string): FileSystemItem[] {
	const lines = lsOutput.split('\n').filter(line => line.trim() !== '');
	const parsedItems: FileSystemItem[] = [];

	lines.forEach(line => {
		const parts = line.split(/\s+/);
		const type: 'file' | 'directory' = parts[0].startsWith('d') ? 'directory' : 'file';
		const name = parts.slice(8).join(' ');
		parsedItems.push({ name, type });
	});
	return parsedItems;
}

const execAsync = util.promisify(exec);

/////////////////////////////////////////////////////////////////////////////////
// recherche un contenu à partir de son nom d'archive dans le serveur
export async function searchContent(name: string, movie: boolean): Promise<string> {
	let probability = { percent: 0, content: "", type: "" };
	let contentPath = process.env.CONTENT_FOLDER ?? ".";

	while (true) {
		const { stdout: lsOutput } = await execAsync(`ls -l "${contentPath}"`);
		const items = parseLsOutput(lsOutput);
		items.forEach(item => {
			const similarity = calculateWordSimilarity2(cleanName(name), extractInfo(cleanName(item.name)));
			if (similarity > probability.percent && isMovie(item.name) === movie) {
				probability = { percent: similarity, content: item.name, type: item.type };
			}
		});
		if (probability.type === "directory") {
			contentPath = path.join(contentPath, probability.content);
			probability = { percent: 0, content: "", type: "" };
		} else if (probability.type === "file" || !items.some(item => item.type === "directory")) {
			break;
		}
	}
	return `${contentPath}/${probability.content}`;
}

/////////////////////////////////////////////////////////////////////////////////
// Fonction utilitaire pour détecter le type MIME via l'extension
export function getMimeType(filePath:string) {
	const extension: string = filePath.toLowerCase().split('.')[-1];
	const mimeTypes:Record<string, string> = {
		mp4: 'video/mp4',
		mkv: 'video/x-matroska',
		avi: 'video/x-msvideo',
		mov: 'video/quicktime',
		webm: 'video/webm',
		flv: 'video/x-flv',
	};

	return mimeTypes[extension] || 'application/octet-stream';
}