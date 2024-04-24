import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const CustomElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonTextColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onPrimary;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: buttonTextColor,
        backgroundColor: color ?? theme.colorScheme.primary,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      ),
      child: Text(label),
    );
  }
}

class DeletablePlansButton extends StatelessWidget {
  final VoidCallback onDeleteConfirmed;

  const DeletablePlansButton({super.key, required this.onDeleteConfirmed});

  void _showDeleteConfirmation(BuildContext context) async {
    bool confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Bestätige'),
              content: const Text(
                  'Bist du sicher das du alle alten Pläne löschen möchtest?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Nein'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Ja'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmed) {
      onDeleteConfirmed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(2),
        child: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteConfirmation(context),
        ),
      ),
    );
  }
}
