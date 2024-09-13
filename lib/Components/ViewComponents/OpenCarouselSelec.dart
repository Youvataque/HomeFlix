import 'package:flutter/material.dart';

///////////////////////////////////////////////////////////////
/// composant générant le bouton de sélection d'un élément du carousel
class Opencarouselselec extends StatelessWidget {
  final VoidCallback func;
  const Opencarouselselec({
    super.key,
    required this.func
  });

  @override
  Widget build(BuildContext context) {
    return Align(
			alignment: Alignment.bottomCenter,
			child: SizedBox(
				width: 250,
				height: 45,
				child: ElevatedButton(
					onPressed: () => func(),
					style: ElevatedButton.styleFrom(
						backgroundColor: Theme.of(context).colorScheme.tertiary,
						foregroundColor: Theme.of(context).primaryColor,
						shape: RoundedRectangleBorder(
							borderRadius: BorderRadius.circular(5)
						)
					),
					child: Text(
						"En savoir plus",
						style: TextStyle(
							fontSize: 16,
							color: Theme.of(context).scaffoldBackgroundColor,
							fontWeight: FontWeight.w600
						),
					),
				),
			)
		);
  }
}