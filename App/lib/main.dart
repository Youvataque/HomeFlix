import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:homeflix/Components/FondamentalAppCompo/MyTabbar.dart';
import 'package:homeflix/Components/Tools/Theme/ColorsTheme.dart';
import 'package:homeflix/Data/NightServices.dart';
import 'package:homeflix/Data/TmdbServices.dart';

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
 	await dotenv.load(fileName: ".env");
	SystemChrome.setPreferredOrientations([
		DeviceOrientation.portraitUp,
		DeviceOrientation.portraitDown,
	]);
	runApp(Main(key: GlobalKey<MainState>()));
}

class Main extends StatefulWidget {
	const Main({super.key});

  @override
  State<Main> createState() => MainState();
}

class MainState extends State<Main> {
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			theme: darkTheme,
			darkTheme: darkTheme,
			home: FutureBuilder(
				future: downloadData(),
				builder: (context, snapshot) {
					if (snapshot.connectionState == ConnectionState.waiting) {
						return CupertinoActivityIndicator(
							radius: 20,
							color: Theme.of(context).colorScheme.secondary,	
						);
					} else if (snapshot.connectionState == ConnectionState.done) {
						return const MyTabbar();
					} else {
						return const Text("error");
					}
				}
			)
		);
	}

	///////////////////////////////////////////////////////////////
	/// Télécharge les données de l'api TMDB en utilisant le gestionnaire custom TMDBService
	Future<bool> downloadData() async {
		NIGHTServices.dataStatus = await NIGHTServices().fetchDataStatus();
		NIGHTServices.specStatus = await NIGHTServices().fetchSpecStatus();
		TMDBService.the10movieTren = await TMDBService().fetchRandom(10, "https://api.themoviedb.org/3/discover/movie?api_key=${dotenv.get('TMDB_KEY')}&include_adult=true&include_video=false&language=fr-FR&primary_release_date.gte=2024-01-01&sort_by=popularity.desc", 1);
		TMDBService.the20moviePop = await TMDBService().fetchRandom(20, "https://api.themoviedb.org/3/discover/movie?api_key=${dotenv.get('TMDB_KEY')}&include_adult=true&include_video=false&language=fr-FR&sort_by=popularity.desc", -1);
		TMDBService.the20movieRecent = await TMDBService().fetchRandom(20, "https://api.themoviedb.org/3/discover/movie?api_key=${dotenv.get('TMDB_KEY')}&include_adult=true&include_video=false&language=fr-FR&primary_release_date.gte=2024-01-01&sort_by=popularity.desc", 2);
		TMDBService.movieCateg = await TMDBService().fetchCateg(true);
		TMDBService.the10serieTren = await TMDBService().fetchRandom(10, "https://api.themoviedb.org/3/tv/on_the_air?api_key=${dotenv.get('TMDB_KEY')}&language=fr-FR", -1);		
		TMDBService.the20seriePop = await TMDBService().fetchRandom(20, "https://api.themoviedb.org/3/trending/tv/day?api_key=${dotenv.get('TMDB_KEY')}&language=fr-FR&vote_average.gte=8&vote_count.gte=100", -1);
		TMDBService.the20serieTop = await TMDBService().fetchRandom(20, "https://api.themoviedb.org/3/tv/top_rated?api_key=${dotenv.get('TMDB_KEY')}&language=fr-FR", 1);
		TMDBService.serieCateg = await TMDBService().fetchCateg(false);
		return true;
	}

	void rebuildMain() {
		setState(() {});
	}
}
