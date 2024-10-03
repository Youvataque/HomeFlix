import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homeflix/Components/FondamentalAppCompo/SecondTop.dart';
import 'package:homeflix/Components/Tools/CheckTool/searchScript.dart';
import 'package:homeflix/Components/ViewComponents/SecondTitle.dart';
import 'package:homeflix/Data/NightServices.dart';
import 'package:homeflix/Data/TmdbServices.dart';

class Dataview extends StatefulWidget {
	final String secTitle;
	final String where;
	const Dataview({
		super.key,
		required this.secTitle,
		required this.where
	});

	@override
	State<Dataview> createState() => _DataviewState();
}

class _DataviewState extends State<Dataview> {
	Map<String, dynamic> datas = NIGHTServices.dataStatus;
	TextEditingController queryController = TextEditingController();

	void _updateContent() {
		setState(() {});
	}

	@override
	void initState() {
		super.initState();
		queryController.addListener(_updateContent);
	}

	@override
	void dispose() {
		queryController.removeListener(_updateContent);
		queryController.dispose();
		super.dispose();
	}

	///////////////////////////////////////////////////////////////
	/// Ui du bouton image 
	Widget imgButton(Widget img, Map<String, dynamic> selectData) {
		return SizedBox(
			height: double.infinity,
			child: ElevatedButton(
				style: ElevatedButton.styleFrom(
					padding: EdgeInsets.zero,
					backgroundColor: Colors.transparent,
					surfaceTintColor: Colors.transparent,
					disabledBackgroundColor: Colors.transparent
				),
				onPressed: () {
					print(selectData["name"]);
				},
				child: img,
			),
		);
	}

	///////////////////////////////////////////////////////////////
	/// corp du code
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
								const Secondtitle(title: "En direct de votre serveur ;)"),
								const Gap(10),
								Padding(
									padding: const EdgeInsets.symmetric(horizontal: 10),
									child: SizedBox(
										width: MediaQuery.sizeOf(context).width,
										child: contentBody(),
									),
								),
								const Gap(50)
							],
						),
					),
					Secondtop(
						title: widget.secTitle,
						leftWord: "Serveur",
						color: Theme.of(context).primaryColor.withOpacity(0.5),
						icon: CupertinoIcons.search,
						dataMode: true,
						query: queryController,
					),
				],
			)
		);
	}

	///////////////////////////////////////////////////////////////
	/// contenu de la page
	Wrap contentBody() {
		List<MapEntry> filteredEntries = datas[widget.where].entries.where((entry) {
			return cleanString(entry.value["title"].toString()).contains(cleanString(queryController.text));
		}).toList();

		if (filteredEntries.isNotEmpty) {
			filteredEntries.sort((a, b) {
				return a.value["title"].toString().compareTo(b.value["title"].toString());
			});
		}

		return Wrap(
			spacing: 10,
			runSpacing: 20,
			alignment: WrapAlignment.start,
			children: filteredEntries.map<Widget>((entry) {
				return ClipRRect(
					borderRadius: BorderRadius.circular(7.5),
					child: SizedBox(
						height: 1.5 * (MediaQuery.of(context).size.width / 2 - 15),
						child: imgButton(
							TMDBService().createImg(
								entry.key,
								(MediaQuery.of(context).size.width / 2 - 15),
								widget.where == "movie" ? true : false
							),
							entry.value
						),
					)
				);
			}).toList()
		);
	}
}