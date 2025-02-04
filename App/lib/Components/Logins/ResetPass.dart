import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homeflix/Components/Logins/LogMainBod.dart';
import '../Tools/ErrorTools/LoginsError.dart';
import '../ViewComponents/Buttons/MainButton.dart';
import '../ViewComponents/Buttons/MyTextButton.dart';
import '../ViewComponents/Buttons/MyTextField.dart';
import '../ViewComponents/ErrorView.dart';

class ResetPass extends StatefulWidget {
  const ResetPass({super.key});

  @override
  State<ResetPass> createState() => _ResetPassState();
}

class _ResetPassState extends State<ResetPass> {
  TextEditingController email = TextEditingController();
  String theError = "";
  @override
  Widget build(BuildContext context) {
    return LogMainBod(
      child: Column(
        children: [
          ErrorView(
              key: UniqueKey(),
              error: theError
          ),
          const Gap(5),
          loginComponent()
        ]
      ),
    );
  }

///////////////////////////////////////////////////////////////
/// textfields et boutons lié à la connexion
  Column loginComponent() {
    return Column(
      children: [
        MyTextField(
            controller: email,
            hintText: "Votre email"
        ),
        const Gap(5),
        toPassButton(),
        const Gap(30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: MainButton(
              func: () => resetPass(),
              color: Theme.of(context).colorScheme.tertiary,
              titleColor: Theme.of(context).primaryColor,
              title: "Réinitialiser"
          ),
        )
      ],
    );
  }

///////////////////////////////////////////////////////////////
/// bouton vers reset pass
  Widget toPassButton() {
    return Padding(
        padding: const EdgeInsets.only(right: 15),
        child: Align(
          alignment: Alignment.centerRight,
          child: MyTextButton(
              func: () => Navigator.pop(context),
              title: "Vous avez un compte ?"
          ),
        )
    );
  }

///////////////////////////////////////////////////////////////
/// logique de récupération
  void resetPass() async {
    String selectedEmail = email.text.trim();
    try {
      if (selectedEmail == "") {
        setState(() {
          theError = "Il est nécéssaire de renseigner un email !";
        });
      } else {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: selectedEmail);
        setState(() {
          theError = "Si un compte est reconnu vous recevrez un email prochainement.";
        });
      }
    } catch(error) {
      setState(() {
        theError = loginsError(error.toString());
      });
    }
  }
}