import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:next_cloud_plans/bloc/api/api_service.dart';
import 'package:next_cloud_plans/bloc/notification/notification_service.dart';
import 'package:next_cloud_plans/database/database.dart';
import 'package:next_cloud_plans/model/substitution_plan.dart';
import 'package:next_cloud_plans/repository/user_repository.dart';
import 'package:next_cloud_plans/ui/pages/child_ui/all_classes_selection.dart';
import 'package:next_cloud_plans/ui/pages/child_ui/class_title.dart';
import 'package:next_cloud_plans/ui/pages/child_ui/custom_button.dart';
import 'package:next_cloud_plans/ui/pages/child_ui/date_dropdown.dart';
import 'package:next_cloud_plans/ui/pages/child_ui/logout_button.dart';
import 'package:next_cloud_plans/ui/pages/child_ui/plan_by_date.dart';
import 'package:next_cloud_plans/ui/pages/login_page.dart';

import 'package:next_cloud_plans/ui/pages/search_page.dart';
import 'package:next_cloud_plans/utils/storage.dart';

class SubstitutionPlan extends StatefulWidget {
  final Map<String, List<SubstitutionPlanItem>> singlePlanData;
  final Map<String, List<SubstitutionPlanItem>> allPlanData;
  final String currentClass;
  final ApiService apiService;

  const SubstitutionPlan({
    super.key,
    required this.singlePlanData,
    required this.allPlanData,
    required this.currentClass,
    required this.apiService,
  });

  @override
  SubstitutionPlanState createState() => SubstitutionPlanState();
}

class SubstitutionPlanState extends State<SubstitutionPlan> {
  bool? isNotificationOn;
  List<SubstitutionPlanItem> pastPlans = [];
  List<String> uniqueDates = [];
  String? selectedDate;

  final UserRepository userRepository = UserRepository();
  StorageItems storage = StorageItems();

  @override
  void initState() {
    super.initState();
    _loadInitialState();
    _fetchUniqueDates();
  }

  Future<void> _loadInitialState() async {
    bool? notificationState = await storage.getNotificationBool();
    setState(() {
      isNotificationOn = notificationState ?? false;
    });
  }

  Future<void> _fetchUniqueDates() async {
    List<String> allDates = await DatabaseHelper.instance.fetchUniqueDates();
    DateTime today = DateTime.now();
    DateFormat format = DateFormat('yyyy-MM-dd');

    // Filter to retain only past and present dates (excluding today)
    List<String> pastDates = allDates.where((dateString) {
      DateTime date = format.parse(dateString);
      return date.isBefore(DateTime(today.year, today.month, today.day));
    }).toList();

    if (pastDates.isNotEmpty) {
      setState(() {
        uniqueDates = pastDates;
        selectedDate = uniqueDates.first;
        _loadPastPlans(selectedDate!);
      });
    } else {
      setState(() {
        uniqueDates = [];
        selectedDate = null;
        pastPlans = [];
      });
    }
  }

  Future<void> _handlePlanClear() async {
    await DatabaseHelper.instance.clearAllPlans();
    if (mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

  Future<void> _handleRefresh() async {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  Future<void> _loadPastPlans(String date) async {
    pastPlans = await DatabaseHelper.instance.fetchPlansByDate(date);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 36, 38, 39),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SearchPage())),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: Icon(isNotificationOn == true
                  ? Icons.notifications_on
                  : Icons.notifications_off),
              onPressed: () async {
                await NotificationService().toggleNotificationStatus(context);
                bool? newStatus = await StorageItems().getNotificationBool();
                if (newStatus != null) {
                  setState(() {
                    isNotificationOn = newStatus;
                  });
                }
              },
              color: isNotificationOn == true ? Colors.green : Colors.red,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
                icon: const Icon(Icons.refresh), onPressed: _handleRefresh),
          ),
          ConfirmLogoutButton(userRepository: userRepository)
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              stops: [0.42, 1],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color.fromARGB(255, 0, 64, 255), Color(0xFF00F5FF)]),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.5,
                child: Lottie.asset(
                  'assets/animations/background-animation.json',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: classTitle(widget.currentClass, context)),
                  for (var entry in widget.singlePlanData.entries)
                    planByDate(entry, context, widget.apiService),
                  Center(
                    child: allClassesSection(
                        widget.allPlanData, widget.apiService, context),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: title("Alte Vertretungspläne", context),
                      ),
                      DeletablePlansButton(
                        onDeleteConfirmed: () {
                          _handlePlanClear();
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: DateDropdown(
                      apiService: widget.apiService,
                      uniqueDates: uniqueDates,
                      onDateChanged: (newValue) {
                        _loadPastPlans(newValue);
                      },
                      pastPlans: pastPlans,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
