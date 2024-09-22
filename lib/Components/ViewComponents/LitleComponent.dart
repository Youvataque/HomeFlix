import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:homeflix/Components/ViewComponents/CategView.dart';
import 'package:homeflix/Components/ViewComponents/ContentPages/ContentView.dart';
import 'package:homeflix/Data/FetchTmdbDatas.dart';

///////////////////////////////////////////////////////////////
/// ombre de l'app
BoxShadow myShadow(BuildContext context) {
	return BoxShadow(
    	color: Theme.of(context).shadowColor.withOpacity(0.3),
		blurRadius: 5
	);
}

void toContentView(BuildContext context, Map<String, dynamic> datas, Widget img, bool movie, String leftWord) async {
	List<Map<String, dynamic>> bigData = await TMDBService().fetchRandom(1, "https://api.themoviedb.org/3/${movie ? "movie" : "tv"}/${datas['id']}?api_key=${dotenv.get('TMDB_KEY')}&language=fr-FR", 1);
	Navigator.push(
		context,
		MaterialPageRoute(builder: (context) => Contentview(
			datas: bigData.first,
			img: img,
			movie: movie,
			leftWord: leftWord,
		))
	);
}

void toCategView(BuildContext context, Map<String, dynamic> details, String leftWord, bool movie) async {
	List<Map<String, dynamic>> favData = await TMDBService().fetchRandom(20, 'https://api.themoviedb.org/3/discover/${movie ? 'movie' : 'tv'}?api_key=${dotenv.get('TMDB_KEY')}&with_genres=${details['id']}&vote_count.gte=100&sort_by=vote_average.desc&language=fr-FR', -1);
	List<Map<String, dynamic>> allData = await TMDBService().fetchRandom(20, 'https://api.themoviedb.org/3/discover/${movie ? 'movie' : 'tv'}?api_key=${dotenv.get('TMDB_KEY')}&with_genres=${details['id']}include_adult=false&include_null_first_air_dates=false&language=fr-FR&page=1&sort_by=first_air_date.desc&vote_count.gte=100', 1);
	Navigator.push(
		context,
		MaterialPageRoute(builder: (context) => Categview(
			details: details,
			leftWord: leftWord,
			allData: allData,
			favData: favData,
			movie: movie
		))
	);
}