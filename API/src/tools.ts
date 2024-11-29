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
export async function deleteTorrent(torrentName: string, originalName: string): Promise<boolean> {
	try {
		await qbittorrentAPI.post('/auth/login');
		const response = await qbittorrentAPI.get('/torrents/info');
		const searchTerms = removeAccents(torrentName.toLowerCase().replace('&', "et")).split(/[\s._\-:(),]+/).filter(Boolean);
		const originalSearchTerms = removeAccents(originalName.toLowerCase().replace("&", "and")).split(/[\s._\-:(),]+/).filter(Boolean);

		const torrent = response.data.find((t: any) => 
			searchTerms.every(term => removeAccents(t.name.toLowerCase()).split(/[\s._\-:(),]+/).includes(term)) ||
			originalSearchTerms.every(term => removeAccents(t.name.toLowerCase()).split(/[\s._\-:(),]+/).includes(term))
		);
		if (torrent) {
			console.log(`Tentative de suppression du torrent avec le hash : ${torrent.hash}`);
			await qbittorrentAPI.post('/torrents/delete', 
				new URLSearchParams({
				  hashes: torrent.hash,
				  deleteFiles: "true"
				}), 
				{
				  headers: {
					'Content-Type': 'application/x-www-form-urlencoded'
				  }
				}
			  );
			console.log(`Torrent ${torrent.name} supprimé avec succès.`);
			return true;
		} else {
			console.log('Aucun torrent correspondant trouvé.');
			return false;
		}
	} catch (error) {
		console.error('Erreur lors de la recherche du torrent', error);
		return false;
	} 
}

/////////////////////////////////////////////////////////////////////////////////
// supprimer les données d'une oeuvre de l'api
export async function removeFromJson(where:string, id:string):Promise<boolean> {
	const filePath = path.join(__dirname, '../contentData.json');
	fs.readFile(
		filePath, 'utf8', (err, data) => {
			if (err) console.error("impossible de lire le json : " + err);
			const jsonData = JSON.parse(data);
			if (jsonData[where] && jsonData[where][id]) {
				delete jsonData[where][id];
				fs.writeFile(filePath, JSON.stringify(jsonData, null, 2), 'utf8', (err) => {
					if (err) {
						console.error("Erreur lors de l'écriture du fichier JSON : " + err);
						return false;
					} else {
						console.log(`Élément ${id} supprimé avec succès de ${where}.`);
						return true;
					}
				});
			} else {
				console.log(`Élément ${id} non trouvé dans ${where}.`);
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
    let totalWords = new Set();

    for (let i = 0; i < splitedName.length; i++) {
        for (let j = 0; j < splitedTorrentName.length; j++) {
            if (splitedName[i] === splitedTorrentName[j]) {
                commonWordsCount++;
                break;
            }
        }
    }

    for (let i = 0; i < splitedName.length; i++) {
        totalWords.add(splitedName[i]);
    }
    for (let j = 0; j < splitedTorrentName.length; j++) {
        totalWords.add(splitedTorrentName[j]);
    }
    const similarity = (commonWordsCount / totalWords.size) * 100;
    return similarity;
}

/////////////////////////////////////////////////////////////////////////////////
// recherche un torrent dans qbittorrent à partir d'un nom unique (nom d'archive)
export async function searchTorrent(name: string): Promise<string> {
	let probability = {
		percent: 60,
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
		console.log(`Le torrent le plus similaire est "${probability.content}" avec ${probability.percent}% de similarité.`);
	} catch (error) {
		console.error("Erreur lors de la recherche des torrents : ", error);
	}

	return probability.content;
}
