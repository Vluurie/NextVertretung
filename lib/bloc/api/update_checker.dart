import 'package:flutter/material.dart';
import 'package:next_cloud_plans/bloc/api/api_service.dart';
import 'package:next_cloud_plans/bloc/api/network_service.dart';
import 'package:next_cloud_plans/bloc/notification/notification_service.dart';
import 'package:next_cloud_plans/database/database.dart';
import 'package:next_cloud_plans/model/substitution_plan.dart';
import 'package:next_cloud_plans/repository/user_repository.dart';
import 'package:next_cloud_plans/utils/storage.dart';

class UpdateChecker {
  final ApiService _apiService;
  final DatabaseHelper _databaseHelper;
  final UserRepository _userRepository;
  final StorageItems _storageItems;

  UpdateChecker(this._apiService, this._databaseHelper, this._userRepository,
      this._storageItems);

  Future<void> initcheckUpdate() async {
    debugPrint("Checking internet connectivity for update process...");
    bool hasInternet = await NetworkService.checkInternetConnection();

    if (!hasInternet) {
      debugPrint("No internet connection available.");
      return;
    }

    debugPrint("Checking user credentials and class details...");
    bool hasCredentials = await _userRepository.hasCredentials();
    String? hasClass = await _storageItems.getClassNameFromStorage();
    String? hasBlock = await _storageItems.getClassBlockFromStorage();

    if (!hasCredentials || hasClass == null || hasBlock == null) {
      debugPrint("Missing credentials or class details. Update check aborted.");
      return;
    }

    debugPrint("Initiating update checks for single class...");
    bool hasUpdateSingle = await checkUpdatesForSingleClass(hasClass, hasBlock);

    if (hasUpdateSingle) {
      debugPrint("Updates detected. Triggering notification...");
      await NotificationService().showNotificationWithDefaultSound();
    } else {
      debugPrint("No updates found.");
    }
  }

  Future<bool> checkUpdatesForSingleClass(
      String searchText, String? block) async {
    try {
      debugPrint("Fetching updates for single class...");
      Map<String, List<SubstitutionPlanItem>> fetchedSingleClass =
          await _apiService.fetchPlansForAllDates(searchText, block);

      bool hasChanges = false;
      for (var entry in fetchedSingleClass.entries) {
        String date = entry.key;
        List<SubstitutionPlanItem> fetchedPlans = entry.value;
        List<SubstitutionPlanItem> existingPlans =
            await _databaseHelper.fetchPlansByDate(date, searchText);

        for (var fetchedPlan in fetchedPlans) {
          var fetchedHash = fetchedPlan.generateHash();
          var existingPlan = existingPlans.firstWhere(
              (plan) =>
                  plan.hour == fetchedPlan.hour &&
                  plan.action == fetchedPlan.action &&
                  plan.teacher == fetchedPlan.teacher,
              orElse: () => SubstitutionPlanItem(
                  hour: '',
                  action: '',
                  teacher: '',
                  date: '')); // Return an empty plan as default.

          // If existingPlan is the default empty plan (indicating no match was found) or the hashes don't match, we have changes
          if (existingPlan.hour == '' ||
              existingPlan.generateHash() != fetchedHash) {
            debugPrint(
                "Change detected for date $date in single class. Updating database...");
            await _databaseHelper.insertOrUpdatePlan(
                date, fetchedPlans, searchText);
            hasChanges = true;
            break; // Exit the loop after finding the first change
          }
        }
      }
      return hasChanges;
    } catch (e) {
      debugPrint('Error checking updates for single class: $e');
      return false;
    }
  }
}
