import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Snackbars {
  static void showErrorSnackbar(BuildContext context, String hint) {
    final snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Lottie.asset(
              'assets/animations/error.json',
              width: 50,
              fit: BoxFit.cover,
              repeat: false,
            ),
            Expanded(
              child: Text(
                hint,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showHintsSnackbar(BuildContext context, String hint) {
    final snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 174, 255),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Lottie.asset(
              'assets/animations/information.json',
              width: 50,
              fit: BoxFit.cover,
              repeat: false,
            ),
            Expanded(
              child: Text(
                hint,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
