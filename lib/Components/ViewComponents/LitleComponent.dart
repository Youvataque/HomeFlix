import 'package:flutter/material.dart';
import 'package:homeflix/Components/ViewComponents/CategView.dart';
import 'package:homeflix/Components/ViewComponents/ContentView.dart';
import 'package:homeflix/Data/FetchDatas.dart';

///////////////////////////////////////////////////////////////
/// ombre de l'app
BoxShadow myShadow(BuildContext context) {
	return BoxShadow(
    	color: Theme.of(context).shadowColor.withOpacity(0.3),
		blurRadius: 5
	);
}

void toContentView(BuildContext context, Map<String, dynamic> datas, Widget img, bool movie, String leftWord) async {
	List<Map<String, dynamic>> bigData = await TMDBService().fetchRandom(1, "https://api.themoviedb.org/3/${movie ? "movie" : "tv"}/${datas['id']}?api_key=2e890027d6ed883dccce4fc5dc8f9007&language=fr-FR", 1);
	Navigator.push(
		context,
		MaterialPageRoute(builder: (context) => Contentview(
			datas: bigData[0],
			img: img,
			movie: movie,
			leftWord: leftWord,
		))
	);
}

void toCategView(BuildContext context, Map<String, dynamic> data, String leftWord) async {
	Navigator.push(
		context,
		MaterialPageRoute(builder: (context) => Categview(
			data: data,
			leftWord: leftWord,
		))
	);
}