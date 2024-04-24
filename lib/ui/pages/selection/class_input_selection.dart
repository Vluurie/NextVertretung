import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:next_cloud_plans/bloc/api/api_service.dart';
import 'package:next_cloud_plans/database/database.dart';
import 'package:next_cloud_plans/model/substitution_plan.dart';
import 'package:next_cloud_plans/ui/pages/child_ui/custom_button.dart';
import 'package:next_cloud_plans/ui/pages/hints/snackbar.dart';
import 'package:next_cloud_plans/ui/pages/substitution_plan_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClassInputPage extends StatefulWidget {
  final Function(bool) toggleLoading;
  final VoidCallback onGoBack;
  final List<String> availableClasses;
  const ClassInputPage({
    super.key,
    required this.toggleLoading,
    required this.onGoBack,
    required this.availableClasses,
  });

  @override
  ClassInputPageState createState() => ClassInputPageState();
}

class ClassInputPageState extends State<ClassInputPage> {
  final ApiService _apiService =
      ApiService(storage: const FlutterSecureStorage());
  String? _selectedClass;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.surface
        : Colors.white;
    final textColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface;
    final borderColor = theme.focusColor;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: borderColor, width: 5),
                color: backgroundColor,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedClass,
                  hint: Text('Select your class',
                      style: TextStyle(color: textColor)),
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: borderColor),
                  dropdownColor: backgroundColor,
                  items: widget.availableClasses.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? Colors.grey[850]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.adjust,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              value,
                              style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color ??
                                    Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedClass = newValue;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            CustomElevatedButton(
              label: 'Submit',
              onPressed: _submit,
            ),
            const SizedBox(height: 20),
            CustomElevatedButton(
              label: 'Go back',
              onPressed: widget.onGoBack,
              color: Colors.blueAccent,
            )
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_selectedClass == null) {
      Snackbars.showHintsSnackbar(context, "Please select a class.");
      return;
    }

    widget.toggleLoading(true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('className', _selectedClass!);

    try {
      Map<String, List<SubstitutionPlanItem>> resultSingle =
          await _apiService.fetchPlansForAllDates(
              _selectedClass!, prefs.getString('selectedBlock'));

      Map<String, List<SubstitutionPlanItem>> resultAll =
          await _apiService.fetchForAllPlans();

      for (var entry in resultSingle.entries) {
        await DatabaseHelper.instance
            .insertOrUpdatePlan(entry.key, entry.value, _selectedClass!);
      }
      for (var entry in resultAll.entries) {
        await DatabaseHelper.instance
            .insertOrUpdatePlan(entry.key, entry.value, _selectedClass!);
      }

      if (resultSingle.isNotEmpty || resultAll.isNotEmpty) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubstitutionPlan(
                singlePlanData: resultSingle,
                allPlanData: resultAll,
                currentClass: _selectedClass!,
                apiService: _apiService,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          Snackbars.showHintsSnackbar(context, "No plans found.");
        }
      }
    } catch (e) {
      if (mounted) {
        Snackbars.showHintsSnackbar(
            context, "Failed to fetch or save data: ${e.toString()}");
      }
    } finally {
      widget.toggleLoading(false);
    }
  }
}
