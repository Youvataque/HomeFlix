import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homeflix/Components/FondamentalAppCompo/SecondTop.dart';
import 'package:homeflix/Components/ViewComponents/SecondTitle.dart';

class SeriesPages extends StatefulWidget {
  final Map<String, dynamic> datas;

  const SeriesPages({super.key, required this.datas});

  @override
  State<SeriesPages> createState() => _SeriesPagesState();
}

class _SeriesPagesState extends State<SeriesPages> {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Theme.of(context).scaffoldBackgroundColor,
			body: Stack(
				children: [
					SingleChildScrollView(
						child: Column(
						children: [
							const Gap(105),
							const Secondtitle(title: "Sélectionnez votre saison :"),
						],
						),
					),
					Secondtop(
						title: widget.datas['title'],
						leftWord: "Series",
						color: Theme.of(context).primaryColor.withOpacity(0.5),
						icon: CupertinoIcons.refresh,
						dataMode: false,
						func: () => print("y'a rien"),
					),
				],
			),
		);
	}
}
