import 'package:flutter/material.dart';

///////////////////////////////////////////////////////////////
/// Textfield unifié de l'application
class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<String>? autofillHints;
  final String hintText;
  final bool hintType;
  final bool noPadding;
  final double padding;
  final int maxLength;
  final bool autoFocus;
  final double fontSize;
  const MyTextField({
    super.key,
    required this.controller,
    this.keyboardType,
    this.autofillHints,
    required this.hintText,
    this.hintType = false,
    this.noPadding = false,
    this.padding = 15,
    this.maxLength = 300000,
    this.autoFocus = false,
    this.fontSize = 16
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}
///////////////////////////////////////////////////////////////
/// code principale
class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.noPadding? 0 : 15),
      child: SizedBox(
        height: 50,
        child: TextField(
            autofocus: widget.autoFocus,
            maxLength: widget.maxLength == 300000? null : widget.maxLength,
            cursorColor: Theme.of(context).primaryColor,
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            autofillHints: widget.autofillHints,
            obscureText: widget.hintType,
            style: textStyle(),
            decoration: fieldStyle()
        ),
      )
    );
  }

///////////////////////////////////////////////////////////////
  /// style du text tapé par l'utilisateur
  TextStyle textStyle() {
    return TextStyle(
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w500
    );
  }

///////////////////////////////////////////////////////////////
/// style du textField
  InputDecoration fieldStyle() {
    return InputDecoration(
        hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.tertiary,
            fontSize: widget.fontSize
        ),
        hintText: widget.hintText,
        contentPadding: EdgeInsets.symmetric(vertical: widget.padding, horizontal: widget.padding),
        enabledBorder: notFocus(),
        focusedBorder: focus(),
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        filled: true,
        focusColor: Theme.of(context).colorScheme.tertiary
    );
  }

///////////////////////////////////////////////////////////////
/// style du textField non focus
  OutlineInputBorder notFocus() {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          width: 0.5,
          color: Theme.of(context).colorScheme.secondary,
        )
    );
  }

///////////////////////////////////////////////////////////////
/// style du textField focus
  OutlineInputBorder focus() {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          width: 1,
          color: Theme.of(context).colorScheme.tertiary,
        )
    );
  }
}