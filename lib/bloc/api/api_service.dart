import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:next_cloud_plans/model/substitution_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = dotenv.env['API_ENDPOINT']!;
  final String subUrl = dotenv.env['SUB_ENDPOINT_ONE']!;
  final String _subUrl = dotenv.env['SUB_ENDPOINT_TWO']!;

  final DateTime now = DateTime.now();
  final FlutterSecureStorage storage;

  ApiService({required this.storage});

  Future<Map<String, List<SubstitutionPlanItem>>> fetchForAllPlans() async {
    final prefs = await SharedPreferences.getInstance();
    String? block = prefs.getString('selectedBlock');
    Map<String, List<SubstitutionPlanItem>> allPlans = {};

    try {
      allPlans = await fetchPlansForAllDates("ALLE", block);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch plans for all dates: $e');
      }
    }

    return allPlans;
  }

  Future<Map<String, List<SubstitutionPlanItem>>> fetchPlansForAllDates(
      String searchText, String? block) async {
    String? webdavUsername = await storage.read(key: 'username');
    String? webdavPassword = await storage.read(key: 'password');
    Map<String, List<SubstitutionPlanItem>> plansByDate = {};
    if (webdavUsername == null || webdavPassword == null) {
      if (kDebugMode) {
        print('No credentials stored.');
      }
      return {};
    }

    // Fetch available dates
    List<String>? availableDates =
        await availablePlans(webdavUsername, webdavPassword);

    if (availableDates == null || availableDates.isEmpty) {
      if (kDebugMode) {
        print("No available dates.");
      }
      return {};
    }

    availableDates = availableDates
        .where((date) => DateFormat("yyyy-MM-dd")
            .parse(date)
            .isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();

    for (String dateWithBlock in availableDates) {
      String date = dateWithBlock.split('_').first;

      var uri = Uri.parse(
          '$baseUrl/$_subUrl?date=$date&searchText=$searchText&block=$block');
      try {
        var response = await http.get(uri, headers: {
          "WebDAV-Username": webdavUsername,
          "WebDAV-Password": webdavPassword,
          "Accept": "application/json",
        });

        if (response.statusCode == 200) {
          List<dynamic> decoded = json.decode(response.body);
          List<SubstitutionPlanItem> plans = decoded
              .map((item) =>
                  SubstitutionPlanItem.fromJson(item as Map<String, dynamic>))
              .toList();
          plansByDate[date] = plans;
        } else {
          if (kDebugMode) {
            print('Request failed with status: ${response.statusCode}.');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Caught exception: $e');
        }
      }
    }
    return plansByDate;
  }

  Future<List<String>?> availablePlans(
      String webdavUsername, String webdavPassword) async {
    var uri = Uri.parse('$baseUrl/$subUrl');
    try {
      var response = await http.get(uri, headers: {
        "WebDAV-Username": webdavUsername,
        "WebDAV-Password": webdavPassword,
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        List<dynamic> decoded = json.decode(response.body);
        List<String> dates =
            decoded.map<String>((dynamic date) => date.toString()).toList();
        return dates;
      } else {
        if (kDebugMode) {
          print('Request failed with status: ${response.statusCode}.');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Caught exception: $e');
      }
      return null;
    }
  }

  Future<List<String>?> availableClasses(String? block) async {
    String? webdavUsername = await storage.read(key: 'username');
    String? webdavPassword = await storage.read(key: 'password');
    var uri = Uri.parse('$baseUrl/classes?block=$block');
    try {
      var response = await http.get(uri, headers: {
        "WebDAV-Username": webdavUsername!,
        "WebDAV-Password": webdavPassword!,
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        List<dynamic> decoded = json.decode(response.body);
        List<String> data =
            decoded.map<String>((dynamic date) => date.toString()).toList();
        print(data);
        return data;
      } else {
        if (kDebugMode) {
          print('Request failed with status: ${response.statusCode}.');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Caught exception: $e');
      }
      return null;
    }
  }

  String? getDayName(String dateString) {
    try {
      initializeDateFormatting('de_DE', null);
      DateTime date = DateFormat("yyyy-MM-dd").parse(dateString);
      String dayName = DateFormat('EEEE', 'de_DE').format(date);
      return dayName;
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing date: $e');
      }
      return null;
    }
  }

  String? formatDate(String dateString) {
    try {
      DateTime date = DateFormat("yyyy-MM-dd").parse(dateString);
      String formattedDate = DateFormat('dd.MM.yyyy', 'de_DE').format(date);
      return formattedDate;
    } catch (e) {
      if (kDebugMode) {
        print('Error formatting date: $e');
      }
      return null;
    }
  }
}
