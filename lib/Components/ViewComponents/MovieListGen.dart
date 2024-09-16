import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homeflix/Components/ViewComponents/LitleComponent.dart';

///////////////////////////////////////////////////////////////
/// composant générant une listView de films
class MovieListGen extends StatefulWidget {
	final List<Widget> imgList;
	final List<Map<String, dynamic>> datas;
	final bool movie;
	final String leftWord;
	const MovieListGen({
		super.key,
		required this.imgList,
		required this.datas,
		required this.movie,
		required this.leftWord
	});

	@override
	State<MovieListGen> createState() => _MovieListGenState();
}

class _MovieListGenState extends State<MovieListGen> {
	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 10),
			child: SizedBox(
				width: MediaQuery.sizeOf(context).width,
				height: 150 * 1.5,
				child: ListView.separated(
					separatorBuilder:(context, index) => const Gap(15),
					scrollDirection: Axis.horizontal,
					itemCount: widget.imgList.length,
					itemBuilder: (context, index) => ClipRRect(
						borderRadius: BorderRadius.circular(7.5),
						child: imgButton(widget.imgList[index], index),
					),
				),
			),
		);
	}

  ///////////////////////////////////////////////////////////////
  /// Ui du bouton image 
	Widget imgButton(Widget img, int index) {
		return SizedBox(
			height: double.infinity,
			child: ElevatedButton(
				style: ElevatedButton.styleFrom(
					padding: EdgeInsets.zero
				),
				onPressed: () => toContentView(context, widget.datas[index], img, widget.movie, widget.leftWord),
				child: img,
			),
		);
	}
}