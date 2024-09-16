import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homeflix/Components/FondamentalAppCompo/SecondTop.dart';

class Categview extends StatefulWidget {
	final Map<String, dynamic> data;
	final String leftWord;
	const Categview({
		super.key,
		required this.data,
		required this.leftWord
	});

  @override
  State<Categview> createState() => _CategviewState();
}

class _CategviewState extends State<Categview> {
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
						],
					),
				),
				Secondtop(
					title: widget.data['name'],
					leftWord: widget.leftWord,
				),
			],
		)
	);
  }
}