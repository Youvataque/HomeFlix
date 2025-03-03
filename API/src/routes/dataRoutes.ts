import { Router, Request, Response, NextFunction } from 'express';
import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';
import { deleteAllTorrent, deleteOneTorrent, removeFromJson, searchContent, searchTorrent } from '../actions';
import { getMimeType, isValidJson } from "../tools";
import authMiddleware from './authMiddleware';

dotenv.config();
const router: Router = Router();

/////////////////////////////////////////////////////////////////////////////////
// Route pour récupérer des données de contenu
router.get('/contentStatus', authMiddleware,(req: Request, res: Response) => {
	const filePath = path.join(__dirname, '../../contentData.json');
	fs.readFile(filePath, 'utf8', (err, data) => {
		if (err) {
			res.status(500).json({ error: 'Erreur lors de la lecture du fichier JSON' });
			return;
		}
		res.json(JSON.parse(data));
	});
});

/////////////////////////////////////////////////////////////////////////////////
// Route pour récupérer des données de spec
router.get('/specStatus', authMiddleware,(req: Request, res: Response) => {
	const filePath = path.join(__dirname, '../../specData.json');
	fs.readFile(filePath, 'utf8', (err, data) => {
		if (err) {
			res.status(500).json({ error: 'Erreur lors de la lecture du fichier JSON 2' });
			return;
		}
		res.json(JSON.parse(data));
	});
});

/////////////////////////////////////////////////////////////////////////////////
// Route pour ajouter des données
router.post('/contentStatus', authMiddleware, (req: Request, res: Response) => {
	const filePath = path.join(__dirname, '../../contentData.json');
	const {newData, where} = req.body;
	let countDelay: number = 0;

	fs.readFile(filePath, 'utf8', (err, data) => {
		if (err) {
			res.status(500).json({ error: 'Erreur lors de la lecture du fichier JSON' });
			return;
		}
		while (!isValidJson(data) && countDelay < 10) {
			console.error('\x1b[31mJSON invalide nouvelle tentative dans 2s !\x1b[0m');
			setTimeout(() => {}, 2000);
			countDelay++;
		}
		const jsonData = JSON.parse(data);
		jsonData[where][newData['id']] = {
			"title": newData["title"],
			"originalTitle": newData['originalTitle'],
			"name": newData['name'],
			"media": newData['media'],
			"percent": newData['percent'],
			"seasons": newData['seasons']
		}

		fs.writeFile(filePath, JSON.stringify(jsonData, null, 2), 'utf8', (err) => {
			if (err) {
				res.status(500).json({ error: 'Erreur lors de l\'écriture du fichier JSON' });
				return;
			}
			res.status(201).json({ message: 'Données ajoutées avec succès' });
		});
	});
});

/////////////////////////////////////////////////////////////////////////////////
// Route pour supprimer une oeuvre
router.post('/contentErase', authMiddleware, async (req: Request, res: Response) => {
	const {newData} = req.body;
	let del = false;
	if (newData['media']) {
		const torrentHash = await searchTorrent(newData["name"]);
		del = await deleteOneTorrent(torrentHash);
	} else {
		del = await deleteAllTorrent(newData);
	}
	if (del) await removeFromJson(newData["media"] ? "movie" : "tv", newData["id"]);
    
});

/////////////////////////////////////////////////////////////////////////////////
// Route pour rechercher la localisation d'un contenu
router.post('/contentSearch', authMiddleware, async (req: Request, res: Response) => {
	const { name, fileName, type } = req.body;

	if (!name || typeof name !== 'string') {
		return res.status(400).json({error: 'Le nom et le type de contenu sont requis.'});
	}
	try {
		const contentPath = await searchContent(name, fileName, type);
		res.status(200).json({ path: contentPath });
	} catch (error) {
		console.error('\x1b[31mErreur lors de la recherche du contenu :\x1b[0m', error);
		res.status(500).json({error: 'Une erreur est survenue lors de la recherche du contenu.'});
	}
});

/////////////////////////////////////////////////////////////////////////////////
// Route pour lire une vidéo en streaming
router.get('/streamVideo', authMiddleware, (req, res) => {
	const videoPath = req.query.path;

	if (!videoPath || typeof videoPath !== 'string') {
		return res.status(400).json({ message: 'Le chemin du fichier vidéo est requis.' });
	}

	fs.stat(videoPath, (err, stats) => {
		if (err) {
			console.error(`Erreur lors de l'accès au fichier : ${err.message}`);
			return res.status(404).json({ message: 'Fichier non trouvé.' });
		}
		const fileSize = stats.size;
		const range = req.headers.range;
		if (!range) {
			const contentType = getMimeType(videoPath);
			res.writeHead(200, {
				'Content-Length': fileSize,
				'Content-Type': contentType,
			});
			fs.createReadStream(videoPath).pipe(res);
			return;
		}
		const parts = range.replace(/bytes=/, '').split('-');
		const start = parseInt(parts[0], 10);
		const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
		if (start >= fileSize || end >= fileSize) {
			res.status(416).header({
				'Content-Range': `bytes */${fileSize}`,
			});
			return res.end();
		}

		const contentLength = end - start + 1;
		const contentType = getMimeType(videoPath);
		const headers = {
			'Content-Range': `bytes ${start}-${end}/${fileSize}`,
			'Accept-Ranges': 'bytes',
			'Content-Length': contentLength,
			'Content-Type': contentType,
		};
		res.writeHead(206, headers);
		const videoStream = fs.createReadStream(videoPath, { start, end });
		videoStream.pipe(res);
	});
});

export default router;