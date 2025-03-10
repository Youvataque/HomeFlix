import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NIGHTServices {
	static Map<String, dynamic> dataStatus = {};
	static Map<String, dynamic> specStatus = {};

	///////////////////////////////////////////////////////////////
	/// méthode pour récupérer les données des contenues téléchargés sur le server
	Future<Map<String, dynamic>> fetchDataStatus() async {
		Map<String, dynamic> results = {};
		final response = await http.get(
			Uri.parse("http://${dotenv.get('NIGHTCENTER_IP')}:4000/api/contentStatus?api_key=${dotenv.get('NIGHTCENTER_KEY')}"),
		);
		if (response.statusCode == 200) {
			final data = json.decode(response.body);
			results = data;
		} else {
			print("error on the status -> ${response.reasonPhrase}");
		}
		return results;
	}

	///////////////////////////////////////////////////////////////
	/// méthode pour récupérer les données des contenues téléchargés sur le server
	Future<Map<String, dynamic>> fetchSpecStatus() async {
		Map<String, dynamic> results = {};
		final response = await http.get(
			Uri.parse("http://${dotenv.get('NIGHTCENTER_IP')}:4000/api/specStatus?api_key=${dotenv.get('NIGHTCENTER_KEY')}"),
		);
		if (response.statusCode == 200) {
			final data = json.decode(response.body);
			results = data;
		} else {
			print("error on the status -> ${response.reasonPhrase}");
		}
		return results;
	}

	///////////////////////////////////////////////////////////////
	/// Fonction pour récupérer le contenu d'une page choisie  
	/// depuis la source (C)
	Future<List<Map<String, dynamic>>> fetchQueryTorrent(int page, String name) async {
		List<Map<String, dynamic>> results = [];

		final response = await http.get(
			Uri.parse("http://${dotenv.get('NIGHTCENTER_IP')}:4000/api/fetchTorrentContent?api_key=${dotenv.get('NIGHTCENTER_KEY')}&page=$page&name=$name"),		
		);

		if (response.statusCode == 200) {
			final data = json.decode(response.body);
			results = (data as List).map((item) => item as Map<String, dynamic>).toList();
		} else {
			print("Erreur sur la source -> ${response.reasonPhrase}");
		}
		return results;
	}

	//////////////////////////////////////////////////////////////////
	/// fonction pour envoyer la requête de téléchargement au serveur
	Future<void> sendDownloadRequest(String id, String filename) async {
		final apiUrl = 'http://${dotenv.get('NIGHTCENTER_IP')}:4000/api/contentDl';

		try {
			
			final response = await http.post(
				Uri.parse(apiUrl),
				headers: {
					'Content-Type': 'application/json',
				},
				body: jsonEncode({
					'id': id,
					'filename': filename
				}),
			);
			if (response.statusCode == 200) {
				print('✅ Fichier téléchargé avec succès');
			} else {
				print('❌ Erreur lors du téléchargement : ${response.body}');
			}
		} catch (e) {
			print('❌ Erreur lors de la requête : $e');
		}
	}

	
	///////////////////////////////////////////////////////////////
	/// Méthode pour envoyer un contenu dans le queue de téléchargement du serveur
	Future<void> postDataStatus(Map<String, dynamic> newData, String where) async {
		final url = Uri.parse("http://${dotenv.get('NIGHTCENTER_IP')}:4000/api/contentStatus?api_key=${dotenv.get('NIGHTCENTER_KEY')}");
		final headers = {'Content-Type': 'application/json'};
		final body = jsonEncode({'newData': newData, 'where': where});

		final response = await http.post(url, headers: headers, body: body);

		if (response.statusCode == 201) {
			print('Données ajoutées avec succès');
		} else {
			print('Erreur: ${response.statusCode}');
			print('Message: ${response.body}');
		}
	}

	///////////////////////////////////////////////////////////////
	/// Méthode pour envoyer un contenu dans le queue de téléchargement du serveur
	Future<void> deleteData(Map<String, dynamic> newData) async {
		final url = Uri.parse("http://${dotenv.get('NIGHTCENTER_IP')}:4000/api/contentErase?api_key=${dotenv.get('NIGHTCENTER_KEY')}");
		final headers = {'Content-Type': 'application/json'};
		final body = jsonEncode({'newData': newData});

		final response = await http.post(url, headers: headers, body: body);

		if (response.statusCode == 201) {
			print('Données ajoutées avec succès');
		} else {
			print('Erreur: ${response.statusCode}');
			print('Message: ${response.body}');
		}
  	}

	///////////////////////////////////////////////////////////////
	/// Fonction pour appeler la route `contentSearch`
	Future<String?> searchContent(String name, String fileName, bool type) async {
		final apiUrl = 'http://${dotenv.get('NIGHTCENTER_IP')}:4000/api/contentSearch?api_key=${dotenv.get('NIGHTCENTER_KEY')}';

		try {
			final response = await http.post(
				Uri.parse(apiUrl),
				headers: {
				'Content-Type': 'application/json',
				},
				body: jsonEncode({
					'name': name,
					'fileName': fileName,
					'type': type,
				}),
			);

			if (response.statusCode == 200) {
				final data = json.decode(response.body);
				return data['path'] as String?;
			} else {
				print('Erreur lors de la recherche du contenu : ${response.body}');
				return null;
			}
		} catch (e) {
		print('Erreur lors de la requête : $e');
		return null;
		}
	}

	///////////////////////////////////////////////////////////////
	/// retourne une liste de saisons  au moins partiellement dl
	bool checkDlSeason(Map<String, dynamic> season) {
		if (season['complete']) {
			return true;
		} else {
			List<dynamic> eps = season['episode'];
			if (eps.length > 1) {
				return true;
			} else {
				if (eps.length == 1 && eps.first != -1) {
					return true;
				}
			}
			return false;
		}
	}
}