import 'package:flutter/material.dart';

Widget classTitle(String currentClass, BuildContext context) {
  var theme = Theme.of(context);
  var isDarkMode = theme.brightness == Brightness.dark;

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school, color: isDarkMode ? Colors.white : Colors.black54),
          const SizedBox(width: 10),
          Text('Klasse: $currentClass',
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: isDarkMode ? Colors.white : Colors.black)),
        ],
      ),
    ),
  );
}

Widget title(String title, BuildContext context) {
  var theme = Theme.of(context);
  var isDarkMode = theme.brightness == Brightness.dark;

  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_month,
              color: isDarkMode ? Colors.white : Colors.black54),
          const SizedBox(width: 8),
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: isDarkMode ? Colors.white : Colors.black)),
        ],
      ),
    ),
  );
}
