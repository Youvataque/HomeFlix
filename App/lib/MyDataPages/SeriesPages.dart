import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

///////////////////////////////////////////////////////////////
/// Template de 
class SeriesPages extends StatefulWidget {
	final Map<String, dynamic> serveurData;
	final Map<String, dynamic> bigData;
	const SeriesPages({
		super.key,
		required this.serveurData,
		required this.bigData
	});

	@override
	State<SeriesPages> createState() => _SeriesPagesState();
}

class _SeriesPagesState extends State<SeriesPages> {
	int season = 1;
	List<int> seasons = [];

	void initState() {
		super.initState();
		for (int x = 0; x < widget.bigData['seasons'].length; x++) {
			if (widget.bigData['seasons'][x]['season_number'] > 0) seasons.add(widget.bigData['seasons'][x]['season_number']);
		}
	}

	@override
	Widget build(BuildContext context) {
		return SizedBox(
			width: MediaQuery.sizeOf(context).width - 16,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					seasonSelector(),
					const Gap(10),
				],
			),
		);
	}

	///////////////////////////////////////////////////////////////
	/// bouton de sélection de saison
	Widget seasonSelector() {
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
				child: DropdownButton<String>(
					enableFeedback: true,
					value: "Saison $season",
					items: seasons.map((int season) {
						return DropdownMenuItem<String>(
							value: "Saison $season",
							child: Text(
								"Saison $season",
								style: TextStyle(
									color: Theme.of(context).colorScheme.secondary,
									fontSize: 16,
								),
							),
						);
					}).toList(),
					onChanged: (String? newValue) {
						if (newValue != null) {
							setState(() {
								season = int.parse(newValue.split(' ')[1]);
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
			)
		);
	}
}