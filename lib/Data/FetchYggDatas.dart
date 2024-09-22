import 'dart:convert';
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
}