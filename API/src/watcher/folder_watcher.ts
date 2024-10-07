import fs from 'fs';
import path from 'path';
import { execFile } from 'child_process';

const DIRECTORY_TO_WATCH = '/home/youvataque/data_disk/cloud_data/temp_torrent';

/////////////////////////////////////////////////////////////////////////////////
// Fonction pour ouvrir le fichier après l'écriture complète
function openFileWhenComplete(filepath: string): void {
    let lastSize = -1;

    const checkFileComplete = setInterval(() => {
        const currentSize = fs.statSync(filepath).size;

        if (currentSize === lastSize) {
            clearInterval(checkFileComplete);
            console.log(`Fichier complet : ${filepath}`);

            const command = `xdg-open "${filepath}"`;

            execFile('sh', ['-c', command], (error) => {
                if (error) {
                    console.error(`Erreur lors de l'ouverture du fichier : ${error.message}`);
                    return;
                }
                console.log(`Fichier ouvert : ${filepath}`);
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