import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:homeflix/Components/ViewComponents/EpTemplate.dart';
import 'package:homeflix/Components/ViewComponents/PlayerPages/VideoPlayer.dart';
import 'package:homeflix/Data/NightServices.dart';

///////////////////////////////////////////////////////////////
/// Template des pages de séries
class SeriesPages extends StatefulWidget {
	final Map<String, dynamic> serveurData;
	final Map<String, dynamic> bigData;
	final List<Map<String, dynamic>> seasContent;
	final bool movie;
	const SeriesPages({
		super.key,
		required this.serveurData,
		required this.bigData,
		required this.seasContent,
		required this.movie
	});

	@override
	State<SeriesPages> createState() => _SeriesPagesState();
}

class _SeriesPagesState extends State<SeriesPages> {
	int season = 1;
	List<int> seasons = [];

	@override
	void initState() {
		super.initState();
		for (int x = 0; x < widget.bigData['seasons'].length; x++) {
			final seriesNb = widget.bigData['seasons'][x]['season_number'];
			if ( seriesNb > 0 && widget.serveurData['seasons']['S$seriesNb']['complete']) {
				seasons.add(widget.bigData['seasons'][x]['season_number']);
			}
		}
	}

	///////////////////////////////////////////////////////////////
	/// corp du code
	@override
	Widget build(BuildContext context) {
		return SizedBox(
			width: MediaQuery.sizeOf(context).width - 16,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					seasonSelector(),
					const Gap(20),
					printEp(),
					const Gap(35),
				],
			),
		);
	}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////// zone des composants

	///////////////////////////////////////////////////////////////
	/// bouton de sélection de saison
	Widget seasonSelector() {
		if (seasons.isEmpty) {
			return SizedBox.shrink();
		}
		if (!seasons.contains(season)) {
			season = seasons.first;
		}
		return Container(
			height: 32,
			width: 110,
			decoration: BoxDecoration(
				color: Theme.of(context).primaryColor.withOpacity(0.7),
				border: Border.all(
					color: Theme.of(context).colorScheme.secondary,
					width: 0.5,
				),
				borderRadius: BorderRadius.circular(7),
			),
			child: Center(
				child: DropdownButton<int>(
					value: season,
					items: seasons.map((int season) {
						return DropdownMenuItem<int>(
							value: season,
							child: Text(
								"Saison $season",
								style: TextStyle(
									color: Theme.of(context).colorScheme.secondary,
									fontSize: 16,
								),
							),
						);
					}).toList(),
					onChanged: (int? newValue) {
						if (newValue != null) {
							setState(() {
								season = newValue;
							});
						}
					},
					dropdownColor: Theme.of(context).primaryColor,
					icon: Icon(
						Icons.arrow_drop_down,
						color: Theme.of(context).colorScheme.secondary,
						size: 24,
					),
					underline: const SizedBox(),
					borderRadius: BorderRadius.circular(10),
				),
			),
		);
	}

	///////////////////////////////////////////////////////////////
	/// affichage des épisodes
	Widget printEp() {
		return Column(
			children: List.generate(
				widget.seasContent[season - 1]['episodes'].length,
				(index) {
					final tempS = widget.seasContent[season - 1]['episodes'];
					return Padding(
						padding: EdgeInsets.only(
							bottom: index == tempS.length - 1 ? 0 : 20,
						),
						child: Eptemplate(
							index: index,
							time: tempS[index]['runtime'] ?? 0,
							title: tempS[index]['name'] ?? "inconue",
							imgPath: "https://image.tmdb.org/t/p/w300/${tempS[index]['still_path']}?api_key=${dotenv.get('TMDB_KEY')}",
							overview: tempS[index]['overview'],
							id: "${widget.bigData['id']}_${widget.seasContent[season - 1]['_id']}_${tempS[index]['id']}",
							onTap: () async {
								String name = widget.serveurData['title'];
								name += " S${season.toString().padLeft(2, '0')} E${(index + 1).toString().padLeft(2, '0')}";
								final path = await NIGHTServices().searchContent(
									name,
									widget.serveurData['name'],
									widget.movie
								) ?? "null";
								final encodedPath = Uri.encodeComponent(path);
								final videoUrl = "http://${dotenv.get('NIGHTCENTER_IP')}:4000/api/streamVideo?api_key=${dotenv.get('NIGHTCENTER_KEY')}&path=$encodedPath";
								print(path);
								if (mounted) {
									Navigator.push(
											context,
											MaterialPageRoute(builder: (context) => VlcVideoPlayer(videoUrl: videoUrl))
									);
								}
							},
						),
					);
				},
			),
		);
	}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////// zone des fonctions

	
}