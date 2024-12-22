import { exec } from 'child_process';
import { randomInt } from 'crypto';
import dotenv from 'dotenv';

dotenv.config();

interface nameVpn {
	running: String,
	selected: String
}

/////////////////////////////////////////////////////////////////////////////////
// cherche le server vpn actuellement connecté et tous ceux disponible
function searchServer(): Promise<nameVpn> {
	let result: nameVpn = {
		running: "", 
		selected: "",
	};
	let possibilities: Array<String> = [];

	return new Promise((resolve) => {
		exec("nmcli connection", (error, stdout) => {
			if (error) {
				console.error("\x1b[31mError with nmcli command.\x1b[0m");
				resolve(result);
				return;
			}
			const lines = stdout.split("\n");
			for (const line of lines) {
				const splitLine = line.trim().split(/\s+/);
				if (splitLine[2] == "vpn" && splitLine[3] != "--")
					result.running = splitLine[0];
				else if (splitLine[2] == "vpn" && splitLine[3] == "--")
					possibilities.push(splitLine[0]);
			}
			result.selected = possibilities[randomInt(possibilities.length)];
			if (!result.selected) {
				console.error("\x1b[31mNo available VPN to connect.\x1b[0m");
				resolve(result);
				return;
			}
			resolve(result);
		});
	});
}

/////////////////////////////////////////////////////////////////////////////////
// vérifie que le vpn est fonctionnel est en connecté
function checkIfRunning(): Promise<boolean> {
	return new Promise(
		(resolve) => {
			exec("ping -I tun0 google.com", (errror, stdout) => {
				if (errror) {
					console.error("\x1b[31mError with VPN. Reboot needed\x1b[0m");
					resolve(false);
				} 
				resolve(stdout.includes('octets de'));
			})
		}
	)
}

/////////////////////////////////////////////////////////////////////////////////
// fonction principale vérifiant l'état du vpn et le métant à jour au besoin
async function controlUpdateVpn() {
	let isRunning: boolean = await checkIfRunning();
	if (!isRunning)
	{
		const names: nameVpn = await searchServer();
		exec(`nmcli connection down ${names.running}`);
		console.log(`\x1b[33mTrying to connect to : ${names.selected}\x1b[0m`);
		exec(`echo ${process.env.VPN_PASS} | nmcli connection up ${names.selected} --ask`, (error, stdout) => {
			if (stdout.includes('Connexion activée')) {
				console.log(`\x1b[32mConnexion to ${names.selected} established !\x1b[0m`);
			}
		})
	} 
}

/////////////////////////////////////////////////////////////////////////////////
// lance le listener
export function startVpnWatcher(): void {
	setInterval(controlUpdateVpn, 20000);
	console.log(`Surveillance de l'état du vpn en cours !`);
}