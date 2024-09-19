import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final fourMonthsAgo = DateTime.now().subtract(const Duration(days: 120)).toIso8601String();

///////////////////////////////////////////////////////////////
/// gestionnaire de téléchargement TMDB API
class TMDBService {
	final String apiKey = '2e890027d6ed883dccce4fc5dc8f9007';
	static List<Map<String, dynamic>> the10movieTren = [];
	static List<Map<String, dynamic>> the20movieRecent = [];
	static List<Map<String, dynamic>> the20moviePop = [];
	static List<Map<String, dynamic>> movieCateg = [];

	static List<Map<String, dynamic>> the10serieTren = [];
	static List<Map<String, dynamic>> the20seriePop = [];
	static List<Map<String, dynamic>> the20serieTop = [];
	static List<Map<String, dynamic>> serieCateg = [];

	///////////////////////////////////////////////////////////////
	/// Fonction pour récupérer les têtes d'affiche (films aléatoires)
	Future<List<Map<String, dynamic>>> fetchRandom(int count, String link, int randomNb) async {
		final List<Map<String, dynamic>> movies = [];
		final random = Random();

		while (movies.length < count) {
			final int randomPage = randomNb == -1 ? random.nextInt(15) + 1 : randomNb;
			final response = await http.get(
				Uri.parse("$link${count != 1 ? "&page=$randomPage" : ""}"),
			);
			if (response.statusCode == 200) {
				final data = json.decode(response.body);
				final List<dynamic> results = count != 1 ? data['results'] : [data];
				movies.addAll(results.map((e) => e as Map<String, dynamic>));
				if (randomNb != -1) break;
			} else {
			}
		}
		return movies;
	}

	///////////////////////////////////////////////////////////////
	/// Fonction pour update une liste d'élément et y ajouter une nouvelle page
	Future<List<Map<String, dynamic>>> addMore(String link, List<Map<String, dynamic>> data) async {
		int newPage = (data.length ~/ 20) + 1; // Assurez-vous que la pagination est correcte
		final newData = await fetchRandom(20, link, newPage); // Récupérez 20 éléments par page
		data.addAll(newData);
		return data;
	}
	
	///////////////////////////////////////////////////////////////
	/// Télécharge les images des films
	Future<File?> downloadMovieImageTemp(String imageUrl, String movieId) async {
		try {
			final response = await http.get(Uri.parse(imageUrl));

			if (response.statusCode == 200) {
				final bytes = response.bodyBytes;
				final tempDir = Directory.systemTemp;
				final file = File('${tempDir.path}/$movieId.jpg');
				await file.writeAsBytes(bytes);
				return file;
			} else {
				print('Failed to download image from: $imageUrl');
				return null;
			}
		} catch (e) {
			print('Error downloading image from: $imageUrl, Error: $e');
			return null;
		}
	}

	///////////////////////////////////////////////////////////////
	/// crée une image à partir de la DB ou des fichiers interne vie futureBuilder
	Widget createImg(String imgPath, String movieId, double width) {
		return FutureBuilder<File?>(
			future: _getLocalImageOrDownload(imgPath, movieId),
			builder: (context, snapshot) {
				if (snapshot.connectionState == ConnectionState.done) {
					if (snapshot.hasError) {
						return const Text('Erreur de téléchargement de l\'image');
					} else if (snapshot.hasData && snapshot.data != null) {
						final file = snapshot.data!;
						return SizedBox(
							width: width,
							child: AspectRatio(
								aspectRatio: 2 / 3,
								child: Image.file(file, fit: BoxFit.cover),
							),
						);
					} else {
						return const Text('Image non disponible');
					}
				} else {
					return Container(
						width: width,
						decoration: BoxDecoration(
							borderRadius: BorderRadius.circular(10),
							color: Theme.of(context).primaryColor
						),
						child: AspectRatio(
							aspectRatio: 2 / 3,
							child: CupertinoActivityIndicator(
								radius: 10,
								color: Theme.of(context).colorScheme.secondary,
							),
						),
					);
				}
			},
		);
	}

	///////////////////////////////////////////////////////////////
	/// recupère l'image dans la db si elle n'est pas déjà présente en mémoire
	Future<File?> _getLocalImageOrDownload(String imgPath, String movieId) async {
		final tempDir = Directory.systemTemp;
		final file = File('${tempDir.path}/$movieId.jpg');

		if (await file.exists()) {
			return file;
		} else {
			return await TMDBService().downloadMovieImageTemp(
				'https://image.tmdb.org/t/p/w500$imgPath',
				movieId,
			);
		}
	}

	///////////////////////////////////////////////////////////////
	/// récupère les catégories des films / series
	Future<List<Map<String, dynamic>>> fetchCateg(bool movie) async {
		final List<Map<String, dynamic>> temp = [];
		final response = await http.get(
			Uri.parse('https://api.themoviedb.org/3/genre/${movie ? 'movie' : 'tv'}/list?api_key=$apiKey&language=fr'),
		);

		if (response.statusCode == 200) {
			final data = json.decode(response.body);
			final List<dynamic> results = data['genres'];

			temp.addAll(results.take(results.length).map((e) => e as Map<String, dynamic>));
		} else {
			throw Exception('Failed to load movies');
		}
		return temp;
	}

	///////////////////////////////////////////////////////////////
	/// télécharge des films à partir d'une recherche
	Future<List<dynamic>> searchMovies(String query) async {
       final url = 'https://api.themoviedb.org/3/search/multi?query=$query&include_adult=true&api_key=$apiKey&language=fr-FR';
       final response = await http.get(Uri.parse(url));

       if (response.statusCode == 200) {
         final data = json.decode(response.body);
         return data['results'];
       } else {
         throw Exception('Erreur lors du chargement des données');
       }
     }
}