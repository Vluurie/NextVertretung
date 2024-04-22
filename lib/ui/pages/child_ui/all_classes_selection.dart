import 'package:flutter/material.dart';
import 'package:next_cloud_plans/bloc/api/api_service.dart';
import 'package:next_cloud_plans/model/substitution_plan.dart';
import 'package:next_cloud_plans/ui/pages/child_ui/plan_card.dart';

Widget allClassesSection(Map<String, List<SubstitutionPlanItem>> data,
    ApiService apiService, BuildContext context) {
  bool hasPlans = data.values.any((list) => list.isNotEmpty);
  List<Widget> children = [
    Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        margin: const EdgeInsets.only(left: 8.0, top: 8.0),
        decoration: BoxDecoration(
          color: Colors.grey[850],
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
            const Icon(Icons.school, color: Color.fromARGB(255, 255, 255, 255)),
            const SizedBox(width: 8),
            Text("Alle Klassen",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color.fromARGB(255, 255, 255, 255))),
          ],
        ),
      ),
    )
  ];
  if (!hasPlans) {
    children.add(Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "Keine Informationen",
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white),
          ),
        ),
      ),
    ));
  } else {
    data.forEach((date, plans) {
      if (plans.isNotEmpty) {
        String? formattedDate = apiService.formatDate(date);
        String? dayName = apiService.getDayName(date);
        children.add(
            buildDateSection(formattedDate ?? date, dayName, plans, context));
      }
    });
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  );
}

Widget buildDateSection(String formattedDate, String? dayName,
    List<SubstitutionPlanItem> plans, BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
        child: Text(
          "$formattedDate - $dayName",
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Colors.white),
        ),
      ),
      ...plans.map((plan) => PlanCard(item: plan)),
    ],
  );
}
