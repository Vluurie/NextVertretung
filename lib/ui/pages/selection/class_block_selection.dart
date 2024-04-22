import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:next_cloud_plans/bloc/api/api_service.dart';
import 'package:next_cloud_plans/bloc/api/network_service.dart';
import 'package:next_cloud_plans/ui/pages/child_ui/custom_button.dart';
import 'package:next_cloud_plans/ui/pages/hints/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClassBlockSelection extends StatefulWidget {
  final void Function(String?, List<String>) onContinue;
  final Function(bool) toggleLoading;
  const ClassBlockSelection({
    super.key,
    required this.onContinue,
    required this.toggleLoading,
    required List availableClasses,
  });

  @override
  ClassBlockSelectionState createState() => ClassBlockSelectionState();
}

class ClassBlockSelectionState extends State<ClassBlockSelection> {
  String? _selectedBlock;
  List<String> availableClasses = [];
  String noConnection =
      "No internet connection. Please check your network settings.";

  @override
  void initState() {
    super.initState();
    _loadSelectedBlock();
  }

  Future<void> _loadSelectedBlock() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedBlock = prefs.getString('selectedBlock');
    });
  }

  Future<void> _saveSelectedBlock(String block) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedBlock', block);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20.0),
          child: Text(
            "Select your class block.",
            style: TextStyle(fontSize: 20),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(3, (int index) {
            String block = String.fromCharCode('A'.codeUnitAt(0) + index);
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ChoiceChip(
                label: Text(block),
                selected: _selectedBlock == block,
                onSelected: (bool selected) {
                  setState(() {
                    _selectedBlock = selected ? block : null;
                  });
                  if (selected) {
                    _saveSelectedBlock(block);
                  }
                },
              ),
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: CustomElevatedButton(
            label: 'Continue',
            onPressed: () async {
              await _loadAvailableClasses();
              if (availableClasses.isNotEmpty) {
                widget.onContinue(_selectedBlock, availableClasses);
              } else {
                if (context.mounted) {
                  Snackbars.showErrorSnackbar(
                      context, 'No available classes to proceed.');
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _loadAvailableClasses() async {
    widget.toggleLoading(true);
    ApiService apiService = ApiService(storage: const FlutterSecureStorage());
    bool isConnected = await NetworkService.checkInternetConnection();
    if (!isConnected) {
      if (mounted) {
        Snackbars.showErrorSnackbar(context, noConnection);
        widget.toggleLoading(false);
      }
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? block = prefs.getString('selectedBlock');
    var classes = await apiService.availableClasses(block);
    if (classes != null) {
      setState(() {
        availableClasses = classes;
      });
    }
    widget.toggleLoading(false);
  }
}
