import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homeflix/Components/FondamentalAppCompo/SecondTop.dart';
import 'package:homeflix/Components/Tools/FormatTool/MinToHour.dart';
import 'package:homeflix/Components/Tools/FormatTool/NumberWithCom.dart';
import 'package:homeflix/Components/ViewComponents/ContentPages/YggGestionnary.dart';

///////////////////////////////////////////////////////////////
/// Affiche le contenu d'un film ou d'une série et permet son téléchargement
class Contentview extends StatefulWidget {
	final Map<String, dynamic> datas;
	final bool movie;
	final Widget img;
	final String leftWord;
	const Contentview({
		super.key,
		required this.datas,
		required this.img,
		required this.movie,
		required this.leftWord
	});

	@override
	State<Contentview> createState() => _ContentviewState();
}

class _ContentviewState extends State<Contentview> {

	///////////////////////////////////////////////////////////////
	/// UI des sous texts
	TextStyle sousText() {
		return TextStyle(
			fontSize: 14,
			fontWeight: FontWeight.w400,
			color: Theme.of(context).colorScheme.secondary
		);
	}

	///////////////////////////////////////////////////////////////
	/// ui du titre de l'oeuvre
	Text titleText() {
		return Text(
			widget.datas[widget.movie ? 'title' : 'name'],
			style: TextStyle(
				fontSize: 17,
				fontWeight: FontWeight.w700,
				color: Theme.of(context).colorScheme.secondary
			),
		);
	}

	@override
		Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Theme.of(context).scaffoldBackgroundColor,
			body: Stack(
				children: [
					Positioned.fill(
						child: Transform.scale(
								scale: 1,
								child: Image.asset(
									"src/images/contentBack.png",
									fit: BoxFit.cover,
								),
							),
					),
					
					SizedBox(
						height: MediaQuery.sizeOf(context).height,
						child: SingleChildScrollView(
							child: Column(
								children: [
									const Gap(105),
									detailsPart(),
									const Gap(5),
									descripZone(),
									const Gap(10),
									Padding(
										padding: const EdgeInsets.symmetric(horizontal: 10),
										child: Ygggestionnary(
											name: widget.datas['origin_country'][0] == "US" ? 
													widget.datas[widget.movie ? 'original_title' : 'original_name']
												:
													widget.datas[widget.movie ? 'title' : 'name']
											),
									)
								],
							),
						),
					),
					Secondtop(
						title: widget.datas[widget.movie ? 'title' : 'name'],
						leftWord: widget.leftWord,
						color: Theme.of(context).primaryColor.withOpacity(0.5),
						func: () => print("test"),
					),
				],
			)
		);
	}

	///////////////////////////////////////////////////////////////
	/// zone note utilisateur
	Widget popularityZone() {
		return Row(
			crossAxisAlignment: CrossAxisAlignment.center,
			children: [
				Icon(
					CupertinoIcons.heart_fill,
					color: Theme.of(context).colorScheme.tertiary,
					size: 18,
				),
				const Gap(5),
				Text(
					widget.datas['vote_average'].toString(),
					style: sousText()
				)
			],
		);
	}

	///////////////////////////////////////////////////////////////
	/// partie droite de la présentation avec toutes les infos importante
	Widget rightDetailsPart() {
		return SizedBox(
			height: MediaQuery.sizeOf(context).width * 0.38 * 1.5,
			width: MediaQuery.sizeOf(context).width * 0.47,
			child: Column(
				mainAxisAlignment: MainAxisAlignment.end,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					titleText(),
					const Gap(5),
					Text(
						widget.movie ? 
								"${widget.datas['release_date'].toString().split('-').sublist(0, 2).join('/')} - ${minToHour(widget.datas['runtime'])} - ${widget.datas['origin_country'][0]}"
							:
								"${widget.datas['first_air_date'].toString().split('-')[0]} - ${widget.datas['seasons'].length}saisons - ${widget.datas['origin_country'][0]}",
						style: sousText(),
					),
					const Gap(3),
					if (widget.movie)
					Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(
								numberWithCom(widget.datas['budget']),
								style: sousText(),
							),
							const Gap(3),
						],
					),
					popularityZone(),
					
				],
			),
		);
	}

	///////////////////////////////////////////////////////////////
	/// première partie de page présentant l'oeuvre
	Widget detailsPart() {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 10),
			child: Row(
				children: [
					SizedBox(
						width: MediaQuery.sizeOf(context).width * 0.38,
						child: Container(
							decoration: BoxDecoration(
								borderRadius: BorderRadius.circular(8),
								border: Border.all(
									color: Theme.of(context).dividerColor,
									width: 0.5
								)
							),
							child: ClipRRect(
								borderRadius: BorderRadius.circular(8), 
								child: widget.img
							),
						),
					),
					const Gap(10),
					rightDetailsPart()
				],
			),
		);
	}

	///////////////////////////////////////////////////////////////
	/// partie affichant la description
	Widget descripZone() {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 10),
			child: Text(
				widget.datas['overview'],
				style: TextStyle(
					color: Theme.of(context).colorScheme.secondary,
					fontSize: 13,
					fontWeight: FontWeight.w500
				),
			),
		);
	}
}