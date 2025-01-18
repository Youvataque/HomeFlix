import axios from "axios";
import { exec } from "child_process";
import fs from 'fs';
import Levenshtein from "levenshtein";
import path from 'path';
import util from "util";
import dotenv from "dotenv";
import {cleanName, extractInfo, isMovie, parseLsOutput} from "./tools";

dotenv.config();

/////////////////////////////////////////////////////////////////////////////////
// déclaration de l'api qbittorrent
export const qbittorrentAPI = axios.create({
	baseURL: 'http://localhost:8080/api/v2',
	timeout: 3700,
});

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
// calclue la probabilité que le nom corresponde au torrent en cours
function calculateWordSimilarity(str1: string, str2: string): number {
	const distance = new Levenshtein(str1, str2);
	const maxLength = Math.max(str1.length, str2.length);
	return ((maxLength - distance.distance) / maxLength) * 100;
}

/////////////////////////////////////////////////////////////////////////////////
// Calcule la similarité entre deux noms avec pondération pour titre et métadonnées serie
function calculateContentSimilarity(name: string, comparedName: string): number {
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
// Calcule la similarité entre deux noms avec pondération pour titre et métadonnées pour film
function calculateMovieSimilarity(name: string, comparedName: string): number {
    const targetInfo = extractInfo(name).split(" ");
    const comparedInfo = extractInfo(comparedName).split(" ");
    let matchScore = 0;
    let totalScore = 0;
    targetInfo.forEach((word, index) => {
        let weight = 1;
        if (index === 0) {
            weight = 15;
        }
        if (word.match(/^\d+$/)) {
            weight = 5;
        }
        totalScore += weight;
        if (comparedInfo.includes(word)) {
            matchScore += weight;
        } else {
            if (word.match(/^\d+$/)) {
                matchScore -= 12;
            }
            if (index === 0 && !comparedInfo.includes(word)) {
                matchScore -= 20;
            }
        }
    });
    comparedInfo.forEach((word) => {
        if (word.match(/^\d+$/) && !targetInfo.includes(word)) {
            matchScore -= 15;
        }
    });
    const titleSimilarity = calculateWordSimilarity(cleanName(name), cleanName(comparedName));
    const finalScore = Math.max(0, (matchScore / totalScore) * 100);
    return 0.85 * finalScore + 0.15 * titleSimilarity;
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
			const similarityPercentage = calculateContentSimilarity(name, torrentName);
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

const execAsync = util.promisify(exec);

/////////////////////////////////////////////////////////////////////////////////
// recherche un contenu à partir de son nom d'archive dans le serveur
export async function searchContent(name: string, fileName: string, movie: boolean): Promise<string> {
	let probability = { percent: 0, content: "", type: "" };
	let contentPath = process.env.CONTENT_FOLDER ?? ".";
	let count: number = 0;

	while (true) {
		const { stdout: lsOutput } = await execAsync(`ls -l "${contentPath}"`);
		const items = parseLsOutput(lsOutput);
		items.forEach(item => {
			const similarity = movie ? calculateMovieSimilarity(extractInfo(count < 2 ? fileName : name), extractInfo(item.name)) : calculateContentSimilarity(extractInfo(count < 2 ? fileName : name), extractInfo(item.name));
			if (similarity > probability.percent && isMovie(item.name) === movie) {
				probability = { percent: similarity, content: item.name, type: item.type };
				count++;
				console.log(`name : ${extractInfo(count < 2 ? fileName : name)} onServeur : ${extractInfo(item.name)}`);
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
