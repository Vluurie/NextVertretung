import 'package:flutter/material.dart';
import 'package:next_cloud_plans/repository/user_repository.dart';
import 'package:next_cloud_plans/ui/pages/login_page.dart';
import 'package:next_cloud_plans/utils/storage.dart';

class ConfirmLogoutButton extends StatelessWidget {
  final UserRepository userRepository;

  const ConfirmLogoutButton({
    super.key,
    required this.userRepository,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () async {
        final shouldLogOut = await _showConfirmationDialog(context);
        if (shouldLogOut) {
          await StorageItems().deleteClassBlockFromStorage();
          await StorageItems().deleteClassNameFromStorage();
          await StorageItems().deleteNotificationBool();
          await userRepository.clearCredentials();
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
        }
      },
    );
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Logout'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
