/////////////////////////////////////////////////////////////////////////////////
// Définition de l'interface servant à la lecture du contenu d'un dossier (ls -l)
interface FileSystemItem {
    name: string;
    type: 'file' | 'directory';
}

/////////////////////////////////////////////////////////////////////////////////
// mots à retirer des noms de fichiers
const trashWord: (string | RegExp)[] = [
    'multi', 'vff', 'vfi', 'vfq', 'vf2', 'vo', 'vostfr', 'truefrench', 'french', 'en', 'fr', 'vof',
    'bluray', 'web', 'webrip', 'web-dl', 'bdrip', 'hdrip', 'dvdrip', 'nf', 'amazon', 'amzn', 'hdtv', 'rip', 'hddvd',
    '1080p', '720p', '2160p', '4k', '2k', '10bit', 'hdr', 'hdr10', 'hdr10plus', 'dolby vision', 'dv', 'hdlight', 'fullhd', 'imax',
    'x264', 'x265', 'h264', 'h265', 'hevc', 'aac', 'dts', 'ddp', 'ac3', 'eac3', 'mp4', 'mkv', 'av1',
    'fw', 'pophd', 'neostark', 'serqph', 'bonbon', 'qtz', 'slay3r', 'idys', 'r3mix', 'asko', 'btt', 'tox', 'gwen', 'hdgz', 'mhgz', 'preums', 'papaya',
    /\b(19|20)\d{2}\b/g,
    'extended', 'remastered', 'final', 'complete', 'repack', 'custom', 'unrated', 'super duper cut', 'integrale', 'collection', 'edition', 'part', 'vol', 'volume', 'chapter',
    'saison', 'season', 'episode', 'ep', 's', 'e'
];

/////////////////////////////////////////////////////////////////////////////////
// fonction pour retirer les accents des titres avant comparaison
export function removeAccents(str: string): string {
    return str.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
}

/////////////////////////////////////////////////////////////////////////////////
// normalise une str
export function cleanName(name: string, movie: boolean): string {
    const numberWords: Record<string, string> = {
        zero: '0', one: '1', two: '2', three: '3', four: '4',
        five: '5', six: '6', seven: '7', eight: '8', nine: '9',
        un: '1', deux: '2', trois: '3', quatre: '4', cinq: '5',
        sept: '7', huit: '8', neuf: '9', dix: '10'
    };
    let result: string = name
        .toLowerCase()
        .replace('&', "and")
        .replace(/r(\d{1,2})/gi, (match, p1) => `s${p1.padStart(2, '0')}`)
        .replace(/\b(saison|season)\s?(\d{1,2})\b/gi, (match, p1, p2) => `s${p2.padStart(2, '0')}`)
        .replace(/[\s._\-:(),]+/g, ' ')
        .trim();
    return removeAccents(
        movie ? result : result.replace(/\b(zero|one|two|three|four|five|six|seven|eight|nine|ten|un|deux|trois|quatre|cinq|six|sept|huit|neuf|dix)\b/gi, (match) => numberWords[match.toLowerCase()] || match)
    );

}

/////////////////////////////////////////////////////////////////////////////////
// lit le contenu d'un ls -l
export function parseLsOutput(lsOutput: string): FileSystemItem[] {
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

/////////////////////////////////////////////////////////////////////////////////
// extrait le titre d'un nom de fichier
export function extractTitle(name: string): string {
    return name.replace(/s\d{1,2}e\d{1,2}/gi, "")
        .replace(/s\d{1,2}/gi, "")
        .replace(/e\d{1,2}/gi, "")
        .trim();
}

/////////////////////////////////////////////////////////////////////////////////
// extrait les informations d'un nom de fichier
export function extractInfo(name: string): string {
    trashWord.forEach(keyword => {
        const regex = keyword instanceof RegExp ? keyword : new RegExp(`\\b${keyword}\\b`, 'gi');
        name = name.replace(regex, '');
    });
    const match = name.match(/s(\d{1,2})[.\-_ ]?e(\d{1,2})|s(\d{1,2})/i);
    let season = "";
    let episode = "";
    let title = "";

    if (match) {
        if (match[1] && match[2]) {
            season = `s${match[1].padStart(2, '0')}`;
            episode = `e${match[2].padStart(2, '0')}`;
        } else if (match[3]) {
            season = `s${match[3].padStart(2, '0')}`;
        }
        const matchStartIndex = name.indexOf(match[0]);
        title = name.substring(0, matchStartIndex).trim();
    } else {
        title = name.trim();
    }
    const temp = [title, season, episode].filter(Boolean).join(' ').trim();
    return temp;
}

/////////////////////////////////////////////////////////////////////////////////
// vérifie qu'un fichier json est valide avant d'écrire dessus
export function isValidJson(jsonString: string): boolean {
    try {
        JSON.parse(jsonString);
        return true;
    } catch (e) {
        return false;
    }
}

/////////////////////////////////////////////////////////////////////////////////
// vérifie si le titre est un film
export function isMovie(title: string): boolean {
    const seasonPattern = /S\d{2}/i;
    const episodePattern = /E\d{2}/i;
    if (seasonPattern.test(title) || episodePattern.test(title)) {
        return false;
    }
    return true;
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