import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:homeflix/Components/FondamentalAppCompo/SecondTop.dart';
import 'package:homeflix/Components/Tools/CheckTool/searchScript.dart';
import 'package:homeflix/Components/ViewComponents/MenueItem.dart';
import 'package:homeflix/Components/ViewComponents/SecondTitle.dart';
import 'package:homeflix/Data/NightServices.dart';
import 'package:homeflix/Data/TmdbServices.dart';
import 'package:homeflix/main.dart';

class Dataview extends StatefulWidget {
	final String secTitle;
	final String where;
	const Dataview({
		super.key,
		required this.secTitle,
		required this.where,
	});

	@override
	State<Dataview> createState() => _DataviewState();
}

class _DataviewState extends State<Dataview> {
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
	Widget imgButton(Widget img, Map<String, dynamic> selectData, String id) {
		return GestureDetector(
			onTap: () {
				print(selectData["name"]);
			},
			onLongPressStart: (LongPressStartDetails details) {
				HapticFeedback.heavyImpact();
				final Offset tapPosition = details.globalPosition;
				showMenu(
					context: context,
					color: Theme.of(context).primaryColor,
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(7.5)
					),
					position: RelativeRect.fromLTRB(
						tapPosition.dx,
						tapPosition.dy,
						tapPosition.dx + 1,
						tapPosition.dy + 1,
					),
					items: [
						Menueitem(
							title: "Supprimer",
							icon: CupertinoIcons.trash,
							color: Theme.of(context).colorScheme.tertiary,
							func: () async {
								await NIGHTServices().deleteData({
									"id": id,
									'title': selectData['title'].toString(),
									'originalTitle': selectData['originalTitle'].toString(),
									"where": widget.where
								});
							}
						)
					],
				);
			},
			child: img
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
										child: ValueListenableBuilder<Map<String, dynamic>>(
											valueListenable: mainKey.currentState!.dataStatusNotifier,
											builder: (context, dataStatus, child) {
												print(dataStatus);
												return contentBody(dataStatus);
											},
										)
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
	Wrap contentBody(Map<String, dynamic> datas) {
		List<MapEntry> filteredEntries = datas[widget.where].entries.where((entry) {
			return cleanString(entry.value["title"].toString()).contains(cleanString(queryController.text));
		}).toList();

		if (filteredEntries.isNotEmpty) {
			filteredEntries.sort((a, b) {
				return a.value["title"].toString().compareTo(b.value["title"].toString());
			});
		}

		return Wrap(
			key: ValueKey(datas),
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
							entry.value,
							entry.key
						),
					)
				);
			}).toList()
		);
	}
}