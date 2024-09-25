import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homeflix/Components/FondamentalAppCompo/SecondTop.dart';
import 'package:homeflix/Components/ViewComponents/SecondTitle.dart';
import 'package:homeflix/Data/NightServices.dart';
import 'package:homeflix/Data/TmdbServices.dart';

class Downloadpages extends StatefulWidget {
	final String secTitle;
	const Downloadpages({
		super.key,
		required this.secTitle
	});

	@override
	State<Downloadpages> createState() => _DownloadpagesState();
}

class _DownloadpagesState extends State<Downloadpages> {
	Map<String, dynamic> datas = NIGHTServices.dataStatus["queue"];


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
								const Secondtitle(title: "État d'avancement"),
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
						icon: Icons.download,
						func: () {},
					),
				],
			)
		);
	}

	Widget contentBody() {
		return Column(
			children: datas.entries.map<Widget>((entry) {
				print(entry.value);
				return Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						ClipRRect(
							borderRadius: BorderRadius.circular(7.5),
							child: SizedBox(
								height: 1.5 * 100,
								child: imgButton(
									TMDBService().createImg(
										entry.key,
										100,
										entry.value['media']
									),
									entry.value
								),
							)
						),
						Text(
							entry.value['percent'].toString(),
							style: TextStyle(
								color: Theme.of(context).colorScheme.secondary
							),
						)
					],
				);
			}).toList()
		);
	}
}