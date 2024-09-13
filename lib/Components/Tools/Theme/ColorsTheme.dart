import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
	brightness: Brightness.light,
	splashColor:  Colors.transparent,
	focusColor: const Color.fromARGB(255, 27, 44, 191),
	primaryColor: const Color.fromRGBO(25, 25, 25, 1),
	colorScheme: const ColorScheme.light(
		secondary: Color.fromRGBO(238, 238, 238, 1),
		tertiary: Color.fromRGBO(229, 72, 77, 1)
	),
	textSelectionTheme: const TextSelectionThemeData(
		cursorColor: Color.fromARGB(255, 89, 157, 230),
		selectionColor: Color.fromARGB(255, 89, 157, 230),
		selectionHandleColor: Color.fromARGB(255, 89, 157, 230),
	),
	textTheme: const TextTheme(
		labelLarge: TextStyle(
			color: Color.fromRGBO(180, 180, 180, 1),
		)
	),
	scaffoldBackgroundColor: const Color.fromRGBO(17, 17, 17, 1),
	dividerColor: const Color.fromARGB(255, 68, 67, 67),
	shadowColor: Colors.grey
);
