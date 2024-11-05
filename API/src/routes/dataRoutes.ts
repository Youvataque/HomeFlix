import axios from 'axios';
import { Router, Request, Response, NextFunction } from 'express';
import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';
import { deleteTorrent, removeFromJson } from '../tools';

dotenv.config();
const API_KEY = process.env.API_KEY;
const router: Router = Router();

/////////////////////////////////////////////////////////////////////////////////
// Middleware pour vérifier la clé API dans l'URL
const apiKeyMiddleware = (req: Request, res: Response, next: NextFunction) => {
    const apiKey = req.query.api_key;
    if (apiKey !== API_KEY) {
        return res.status(403).json({ message: 'Clé API invalide' });
    }
    next();
};

/////////////////////////////////////////////////////////////////////////////////
// Route pour récupérer des données de contenu
router.get('/contentStatus', apiKeyMiddleware,(req: Request, res: Response) => {
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
router.get('/specStatus', apiKeyMiddleware,(req: Request, res: Response) => {
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
router.post('/contentStatus', apiKeyMiddleware, (req: Request, res: Response) => {
    const filePath = path.join(__dirname, '../../contentData.json');
    const {newData, where} = req.body;

    fs.readFile(filePath, 'utf8', (err, data) => {
        if (err) {
            res.status(500).json({ error: 'Erreur lors de la lecture du fichier JSON' });
            return;
        }

        const jsonData = JSON.parse(data);
        jsonData[where][newData['id']] = {
			"title": newData["title"],
			"originalTitle": newData['originalTitle'],
			"name": newData['name'],
			"media": newData['media'],
			"percent": newData['percent']
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
// Route pour récupérer le requète de téléchargement du content
router.post('/contentDl', apiKeyMiddleware, async (req, res) => {
    const { fileUrl, filename } = req.body; 

    if (!fileUrl) {
        return res.status(400).json({ message: 'L\'URL du fichier est requise.' });
    }

    try {
        const response = await axios({
            method: 'GET',
            url: fileUrl,
            responseType: 'stream'
        });

		let finalFilename = filename || 'downloaded_file';
        if (!filename) {
            const contentDisposition = response.headers['content-disposition'];
            if (contentDisposition) {
                const match = contentDisposition.match(/filename="(.+)"/);
                if (match) {
                    finalFilename = match[1];
                }
            }
        }
        const filePath = path.resolve(__dirname, process.env.TORRENT_FOLDER ?? "", finalFilename);
        const writer = fs.createWriteStream(filePath);

        response.data.pipe(writer);
        writer.on('finish', () => {
            return res.status(200).json({ message: 'Fichier téléchargé avec succès.' });
        });

        writer.on('error', () => {
            return res.status(500).json({ message: 'Erreur lors du téléchargement du fichier.' });
        });

    } catch (error) {
        return res.status(500).json({ message: 'Erreur lors de la requête HTTP.' });
    }
});

/////////////////////////////////////////////////////////////////////////////////
// Route pour supprimer une oeuvre
router.post('/contentErase', apiKeyMiddleware, async (req: Request, res: Response) => {
    const {newData} = req.body;
	const del = await deleteTorrent(newData['title'], newData['originalTitle']);
	if (del) await removeFromJson(newData["where"], newData["id"]);
    
});

export default router;