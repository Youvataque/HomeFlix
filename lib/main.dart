import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homeflix/Components/FondamentalAppCompo/MyTabbar.dart';
import 'package:homeflix/Components/Tools/Theme/ColorsTheme.dart';
import 'package:homeflix/Data/FetchDatas.dart';

void main() {
	runApp(const Main());
}

class Main extends StatelessWidget {
	const Main({super.key});

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
						return Text("error");
					}
				}
			)
		);
	}

	Future<bool> downloadData() async {
		TMDBService.the10movieTren = await TMDBService().fetchRandom(10, "https://api.themoviedb.org/3/discover/movie?api_key=${TMDBService().apiKey}&include_adult=true&include_video=false&language=en-US&primary_release_date.gte=2024-01-01&sort_by=popularity.desc", 1);
		TMDBService.the20moviePop = await TMDBService().fetchRandom(20, "https://api.themoviedb.org/3/discover/movie?api_key=${TMDBService().apiKey}&include_adult=true&include_video=false&language=en-US&sort_by=popularity.desc", -1);
		TMDBService.the20movieRecent = await TMDBService().fetchRandom(20, "https://api.themoviedb.org/3/discover/movie?api_key=${TMDBService().apiKey}&include_adult=true&include_video=false&language=en-US&primary_release_date.gte=2024-01-01&sort_by=popularity.desc", 2);
		TMDBService.the10serieTren = await TMDBService().fetchRandom(10, "https://api.themoviedb.org/3/discover/tv?api_key=${TMDBService().apiKey}&include_adult=true&include_video=false&language=en-US&sort_by=popularity.desc", 1);
		TMDBService.the20seriePop = await TMDBService().fetchRandom(20, "https://api.themoviedb.org/3/trending/tv/day?api_key=${TMDBService().apiKey}&language=en-US", -1);
		TMDBService.the20serieRecent = await TMDBService().fetchRandom(20, "https://api.themoviedb.org/3/discover/tv?api_key=${TMDBService().apiKey}&first_air_date.gte=2024-01-01&first_air_date.lte=2024-12-25&include_adult=false&include_null_first_air_dates=false&language=en-US&sort_by=first_air_date.desc", -1);		return true;
	}
}
