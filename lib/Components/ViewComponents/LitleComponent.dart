import 'package:flutter/material.dart';

///////////////////////////////////////////////////////////////
/// ombre de l'app
BoxShadow myShadow(BuildContext context) {
	return BoxShadow(
    	color: Theme.of(context).shadowColor.withOpacity(0.3),
		blurRadius: 5
	);
}