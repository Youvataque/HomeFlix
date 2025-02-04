import 'package:flutter/material.dart';

///////////////////////////////////////////////////////////////
/// textButton sans splash (style ios)
class MyTextButton extends StatefulWidget {
  final VoidCallback func;
  final String title;
  const MyTextButton({
    super.key,
    required this.func,
    required this.title
  });

  @override
  State<MyTextButton> createState() => _MyTextButtonState();
}

///////////////////////////////////////////////////////////////
/// Code principale
class _MyTextButtonState extends State<MyTextButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.func(),
      borderRadius: BorderRadius.circular(5),
      child: Text(
        widget.title,
        style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.secondary
        ),
      ),
    );
  }
}