import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


class YGGService {

	///////////////////////////////////////////////////////////////
	/// Fonction pour récupérer une page choisie depuis yggTorrent
	Future<List<Map<String, dynamic>>> fetchQueryTorrent(int page, String query) async {
		final List<Map<String, dynamic>> movies = [];

		final response = await http.get(
			Uri.parse("https://yggapi.eu/torrents?page=$page&q=$query&order_by=seeders&per_page=25"),
		);
		if (response.statusCode == 200) {
			final data = json.decode(response.body);
			final List<dynamic> results = data;
			movies.addAll(results.map((e) => e as Map<String, dynamic>));
		} else {
			print("error ${response.reasonPhrase}");
		}
		return movies;
	}

	///////////////////////////////////////////////////////////////
	/// fonction pour envoyer la requète de téléchargement au serveur et la lui faire éxécuter
	Future<void> sendDownloadRequest(String fileUrl, String filename) async {
		final apiUrl = 'http://84.4.230.45:4000/api/contentDl?api_key=${dotenv.get('NIGHTCENTER_KEY')}';

		try {
			final response = await http.post(
				Uri.parse(apiUrl),
				headers: {
					'Content-Type': 'application/json',
				},
				body: jsonEncode({
					'fileUrl': fileUrl,
					'filename': filename
				}),
			);

			if (response.statusCode == 200) {
			print('Fichier téléchargé avec succès');
			} else {
			print('Erreur lors du téléchargement : ${response.body}');
			}
		} catch (e) {
			print('Erreur lors de la requête : $e');
		}
		}
}