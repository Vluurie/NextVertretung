import 'package:flutter/material.dart';
import 'package:next_cloud_plans/bloc/api/api_service.dart';
import 'package:next_cloud_plans/model/substitution_plan.dart';
import 'package:next_cloud_plans/ui/pages/child_ui/plan_card.dart';

Widget planByDate(MapEntry<String, List<SubstitutionPlanItem>> entry,
    BuildContext context, ApiService apiService) {
  String? dayName = apiService.getDayName(entry.key);
  String? formattedDate = apiService.formatDate(entry.key);
  bool hasPlans = entry.value.isNotEmpty;

  TextStyle dateStyle =
      Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white);
  TextStyle messageStyle = Theme.of(context)
      .textTheme
      .bodyMedium!
      .copyWith(color: const Color.fromARGB(255, 255, 255, 255));

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child:
            Text("${formattedDate ?? entry.key} - $dayName", style: dateStyle),
      ),
      if (hasPlans)
        ...entry.value.map((planItem) => PlanCard(item: planItem))
      else
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(53, 1, 1, 1),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                "Keine Vertretung",
                style: messageStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        )
    ],
  );
}
