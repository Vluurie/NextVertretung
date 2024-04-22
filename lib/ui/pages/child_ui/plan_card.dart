import 'package:flutter/material.dart';
import 'package:next_cloud_plans/model/substitution_plan.dart';

class PlanCard extends StatelessWidget {
  final SubstitutionPlanItem item;

  const PlanCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          color: Colors.white.withOpacity(0.9),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          elevation: 5,
          shadowColor: Colors.blueGrey.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.action,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 20, color: Colors.teal),
                    const SizedBox(width: 5),
                    Text(
                      'Stunde: ${item.hour}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 20, color: Colors.teal),
                    const SizedBox(width: 5),
                    Text(
                      'Lehrer: ${item.teacher}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
