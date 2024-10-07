import { exec } from 'child_process';
import axios from 'axios';
import fs from 'fs';
import path from 'path';

const JSON_FILE_PATH = path.join(__dirname, '../../specData.json');

/////////////////////////////////////////////////////////////////////////////////
// interface pour la lisibilité du code
interface infoSpec {
	cpu: string, 
	fan: string,
	ram: string,
	storage: string
}

interface MediaItem {
	cpu:string,
	fan:string,
	ram: string,
	storage: string
	dlSpeed:string,
	vpnActive: boolean
}

interface DataStructure {
	spec:  MediaItem;
}

/////////////////////////////////////////////////////////////////////////////////
// récupère les informations système de l'ordinateur pour les afficher dans l'app
function getSystemInfo(): Promise<infoSpec> {
	return new Promise((resolve, reject) => {
		exec('sensors', (error, stdout, stderr) => {
			if (error) {
				console.error(`Erreur: ${error.message}`);
				reject(error);
				return;
			}
			if (stderr) {
				console.error(`Erreur: ${stderr}`);
				reject(stderr);
				return;
			}
			const cpuMatch = stdout.match(/Package id 0:\s+\+([\d.]+)°C/);
			const cpu = cpuMatch ? `${cpuMatch[1]} °C` : 'Aucune information sur la température du CPU trouvée.';
			const fanMatch = stdout.match(/Exhaust\s+:\s+(\d+)\sRPM/);
			const fanSpeed = fanMatch ? `${fanMatch[1]} RPM` : 'Aucune information sur les ventilateurs trouvée.';
			exec('free -m', (error, stdout) => {
				const ramMatch = stdout.match(/Mem:\s+(\d+)\s+(\d+)/);
				const ramUsage = ramMatch ? `${((parseInt(ramMatch[2]) / parseInt(ramMatch[1])) * 100).toFixed(2)}%` : 'Aucune information sur la RAM trouvée.';

				exec('df -h /dev/sdb1', (error, stdout, stderr) => {
					if (error) {
						console.error(`Erreur df: ${error.message}`);
						resolve({ cpu, fan: fanSpeed, ram: ramUsage, storage: 'Erreur on stockage' });
						return;
					}
					if (stderr) {
						console.error(`Erreur df: ${stderr}`);
						resolve({ cpu, fan: fanSpeed, ram: ramUsage, storage: 'Erreur on stockage' });
						return;
					}
					const lines = stdout.split('\n');
					const diskInfo = lines[1].split(/\s+/);
					const used = diskInfo[2]; 
					const total = diskInfo[1]; 
					const storage = `${used} / ${total}`;

					resolve({ cpu, fan: fanSpeed, ram: ramUsage, storage: storage });
				});
			});
		});
	});
}

/////////////////////////////////////////////////////////////////////////////////
// vérifie la présence d'une interface réseau vpn (tun0)
function checkVpnStatus(): Promise<boolean> {
	return new Promise((resolve) => {
		exec('ip link show', (error:any, stdout:string) => {
			if (error) {
				console.error(`Erreur: ${error.message}`);
				resolve(false);
				return;
			}
			resolve(stdout.includes('tun0'));
		});
	});
}

/////////////////////////////////////////////////////////////////////////////////
// récupère le débit actuel de dl sur qbittorrent
async function getQbittorrentStats(): Promise<string> {
	try {
		const response = await axios.get('http://localhost:8080/api/v2/transfer/info');
		const data = response.data;
		return `${(data.dl_info_speed / (1024 * 1024)).toFixed(2)}`
	} catch (error:any) {
		console.error(`Erreur qBittorrent: ${error.message}`);
		return "no value";
	}
}

/////////////////////////////////////////////////////////////////////////////////
// lances toutes les fonctions précédente et enregistre leurs résultats dans une section du json
async function runAllChecks() {
	const data = await fs.promises.readFile(JSON_FILE_PATH, 'utf8');
	const jsonData: DataStructure = JSON.parse(data);
	const systemInfo = await getSystemInfo();
	jsonData.spec.cpu = systemInfo.cpu;
	jsonData.spec.fan = systemInfo.fan;
	jsonData.spec.ram = systemInfo.ram;
	jsonData.spec.storage = systemInfo.storage;
	jsonData.spec.vpnActive = await checkVpnStatus();
	jsonData.spec.dlSpeed = await getQbittorrentStats();
	try {
		await fs.promises.writeFile(JSON_FILE_PATH, JSON.stringify(jsonData, null, 2), 'utf8');
		console.log('Specs ajoutés avec succés au json');
	} catch (err) {
		console.error('Erreur lors de l\'écriture du fichier JSON:', err);
	}
}

/////////////////////////////////////////////////////////////////////////////////
// lance le listener
export function startSpecWatcher(): void {
	setInterval(runAllChecks, 6000);
	console.log(`Surveillance du dossier des performances en cours`);
}
  