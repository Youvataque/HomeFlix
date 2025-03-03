import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class LogMainBod extends StatelessWidget {
  final Widget child;
  const LogMainBod({
    super.key,
    required this.child
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Gap(MediaQuery.sizeOf(context).height * 0.17),
                Image.asset(
                  "src/images/logo.png",
                  width: MediaQuery.sizeOf(context).width * 0.4,
                  height: MediaQuery.sizeOf(context).width * 0.4,
                ),
                Gap(MediaQuery.sizeOf(context).height * 0.10),
                child
              ],
            ),
          ),
        )
    );
  }
}
