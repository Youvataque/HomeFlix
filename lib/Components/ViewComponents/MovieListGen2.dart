import 'package:flutter/material.dart';
import 'package:homeflix/Components/ViewComponents/LitleComponent.dart';

class MovieListGen2 extends StatefulWidget {
	final List<Widget> imgList;
	final List<Map<String, dynamic>> datas;
	final bool movie;
	final String leftWord;
	final double imgWidth;
	const MovieListGen2({
		super.key,
		required this.imgList,
		required this.datas,
		required this.movie,
		required this.leftWord,
		required this.imgWidth
	});

	@override
	State<MovieListGen2> createState() => _MovieListGen2State();
}

class _MovieListGen2State extends State<MovieListGen2> {
  @override
  Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 10),
			child: Wrap(
				alignment: WrapAlignment.spaceBetween,
				runSpacing: 30,
				spacing: 10,
				children: List.generate(
					widget.imgList.length,
					(index) => ClipRRect(
						borderRadius: BorderRadius.circular(7.5),
						child: SizedBox(
							height: 1.5 * widget.imgWidth,
							child: imgButton(widget.imgList[index], widget.datas[index]),
						),
					),
				),
			)
		);
	}

  ///////////////////////////////////////////////////////////////
  /// Ui du bouton image 
	Widget imgButton(Widget img, Map<String, dynamic> selectData) {
		return SizedBox(
			height: double.infinity,
			child: ElevatedButton(
				style: ElevatedButton.styleFrom(
					padding: EdgeInsets.zero
				),
				onPressed: () => toContentView(context, selectData, img, widget.movie, widget.leftWord),
				child: img,
			),
		);
	}
}