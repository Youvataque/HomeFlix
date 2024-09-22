import 'package:flutter/material.dart';

class PopUpTemplate extends StatelessWidget {
  final Widget child;
  final double heigth;
  final double padding;
  const PopUpTemplate({
    super.key,
    required this.child,
    required this.heigth,
    this.padding = 60
  });

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: EdgeInsets.only(top: padding),
			child: Align(
				alignment: Alignment.topCenter,
				child: ClipRRect(
					borderRadius: BorderRadius.circular(20),
					child: Container(
						height: heigth,
						width: 350,
						decoration: BoxDecoration(
							color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
							borderRadius: BorderRadius.circular(20)
						),
						child: Scaffold(
							resizeToAvoidBottomInset: false,
							body: GestureDetector(
								onTap: () => FocusScope.of(context).unfocus(),
								behavior: HitTestBehavior.opaque,
								child: child
							)
						)
					),
				),
			),
		);
	}
}