import 'package:flutter/material.dart';
import 'package:homeflix/Data/NightServices.dart';

///////////////////////////////////////////////////////////////
/// widget affichant l'état en direct du serveur (température, couverture vpn etc)
class SpecWidget extends StatefulWidget {
  const SpecWidget({super.key});

  @override
  State<SpecWidget> createState() => _SpecWidgetState();
}

class _SpecWidgetState extends State<SpecWidget> {
	@override
	void initState() {
		super.initState();
		_startFetchingData();
	}

	///////////////////////////////////////////////////////////////
	/// mise à jour des données
	void _startFetchingData() {
		Future.delayed(const Duration(seconds: 6), () async {
			NIGHTServices.dataStatus = await NIGHTServices().fetchDataStatus();
			setState(() {
			});
			_startFetchingData(); 
		});
	}

	///////////////////////////////////////////////////////////////
	/// cadre des infos
	Widget vignette(String data, String title) {
		return Container(
			width: MediaQuery.sizeOf(context).width / 2 - 15,
			height: 70,
			decoration: BoxDecoration(
				color: Theme.of(context).primaryColor,
				borderRadius: BorderRadius.circular(7.5),
				border: Border.all(
					color: Theme.of(context).colorScheme.secondary,
					width: 0.5
				)
			),
			child: Center(
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.center,
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Text(
							title,
							style: TextStyle(
								color: Theme.of(context).colorScheme.secondary,
								fontSize: 14,
								fontWeight: FontWeight.w600
							),
						),
						Text(
							data,
							style: TextStyle(
								color: Theme.of(context).colorScheme.tertiary,
								fontSize: 14,
								fontWeight: FontWeight.w400
							),
						),
					],
				)
			)
		);
	}

	///////////////////////////////////////////////////////////////
	/// corp du code
	@override
	Widget build(BuildContext context) {
		return Wrap(
			runSpacing: 10,
			spacing: 10,
			children: [
				vignette(NIGHTServices.dataStatus['spec']['cpu'], "Température CPU :"),
				vignette(NIGHTServices.dataStatus['spec']['ram'], "Utilisation RAM :"),
				vignette(NIGHTServices.dataStatus['spec']['fan'], "Vitesse ventilateur :"),
				vignette(NIGHTServices.dataStatus['spec']['storage'], "Espace utilisé :"),
				vignette("${NIGHTServices.dataStatus['spec']['dlSpeed']} Mo/s", "Débit actuel :"),
				vignette(NIGHTServices.dataStatus['spec']['vpnActive'] ? "Online" : "Offline", "VPN :")
			],
		);
	}
}