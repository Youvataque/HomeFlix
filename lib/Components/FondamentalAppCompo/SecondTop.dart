import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

///////////////////////////////////////////////////////////////
/// Composant topOfView des sous pages avec bouton de retour
class Secondtop extends StatefulWidget implements PreferredSizeWidget {
	final String title;
	final String leftWord;
	final Color color;
	final bool searchMode;
	final List<Widget> searchZone;
	const Secondtop({
		super.key,
		required this.title,
		required this.leftWord,
		required this.color,
		this.searchZone = const [],
		this.searchMode = false
	});

	@override
	State<Secondtop> createState() => _SecondtopState();

	@override
  	Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SecondtopState extends State<Secondtop> {
	@override
	Widget build(BuildContext context) {
		return ClipRect(
			child: BackdropFilter(
				filter: ImageFilter.blur(
					sigmaX: 10,
					sigmaY: 10
				),
				child: Container(
					width: MediaQuery.sizeOf(context).width,
					height: 95,
					color: widget.color,
					child: Center(
						child: Padding(
							padding: const EdgeInsets.only(top: 45),
							child: Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: widget.searchMode ?
										widget.searchZone
									:
										[
											leftZone(),
											titleWidget(),
											rightZone()
										],
							),
						)
					),
				),
			),
		);
	}

	///////////////////////////////////////////////////////////////
	/// zone de de rtetour des details pages
	Widget leftZone() {
		return SizedBox(
			width: 100,
			child: Align(
				alignment: Alignment.centerLeft,
				child: Padding(
					padding: const EdgeInsets.only(left: 5),
					child: InkWell(
						onTap: () => Navigator.pop(context),
						splashColor: Colors.transparent,
						highlightColor: Colors.transparent,
						child: Row(
							children: [
								const Gap(5),
								Icon(
									Icons.navigate_before,
									size: 22,
									color: Theme.of(context).colorScheme.secondary,
								),
								SizedBox(
									width: 68,
									height: 40,
									child: Align(
										alignment: Alignment.centerLeft,
										child: Text(
											widget.leftWord,
											overflow: TextOverflow.ellipsis,
											style: TextStyle(
												color: Theme.of(context).colorScheme.secondary,
												fontSize: 14,
												fontWeight: FontWeight.w500
											),
										),
									)
								)
							],
						),
					)
				),
			),
		);
	}

	///////////////////////////////////////////////////////////////
	/// zone de refresh des details pages
	Widget rightZone() {
		return SizedBox(
			width: 100,
			child: Align(
				alignment: Alignment.centerRight,
				child: Padding(
					padding: const EdgeInsets.only(right: 12),
					child: InkWell(
						onTap: () {},
						splashColor: Colors.transparent,
						highlightColor: Colors.transparent,
						child: Icon(
							Icons.refresh,
							size: 22,
							color: Theme.of(context).colorScheme.secondary,
						),
					)
				),
			)
		);
	}

	///////////////////////////////////////////////////////////////
	/// zone de titre des details pages (titre centré)
	Expanded titleWidget() {
		return Expanded(
			child: Text(
				widget.title,
				textAlign: TextAlign.center,
				style: TextStyle(
					color: Theme.of(context).colorScheme.secondary,
					fontSize: 17,
					fontWeight: FontWeight.w600
				),
			),
		);
	}
}