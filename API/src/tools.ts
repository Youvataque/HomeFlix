import axios from "axios";
import fs from 'fs';
import path from 'path';
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
// calclue la probabilité que le nom corresponde au torrent en cours
function calculateWordSimilarity(name: string, torrentName: string): number {
	const splitedName = name.split(' ');
	const splitedTorrentName = torrentName.split(' ');
	let commonWordsCount = 0;

	for (let i = 0; i < splitedName.length; i++) {
		for (let j = 0; j < splitedTorrentName.length; j++) {
			if (splitedName[i] === splitedTorrentName[j]) {
				commonWordsCount++;
				break;
			}
		}
	}

	const similarity = (commonWordsCount / splitedTorrentName.length) * 100;
	return similarity;
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
			const similarityPercentage = calculateWordSimilarity(name, torrentName);
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
