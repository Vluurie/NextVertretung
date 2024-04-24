import 'package:flutter/material.dart';
import 'package:next_cloud_plans/bloc/api/api_service.dart';
import 'package:next_cloud_plans/model/substitution_plan.dart';
import 'package:next_cloud_plans/ui/pages/child_ui/plan_card.dart';

class DateDropdown extends StatefulWidget {
  final List<String> uniqueDates;
  final Function(String) onDateChanged;
  final List<SubstitutionPlanItem> pastPlans;
  final ApiService apiService;

  const DateDropdown({
    super.key,
    required this.uniqueDates,
    required this.onDateChanged,
    required this.pastPlans,
    required this.apiService,
  });

  @override
  State<DateDropdown> createState() => _DateDropdownState();
}

class _DateDropdownState extends State<DateDropdown> {
  String? selectedDate;

  @override
  void initState() {
    super.initState();
  }

  void _showBottomSheet(BuildContext context) {
    if (widget.uniqueDates.isEmpty) {
      Navigator.pop(context);
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.black54,
          child: ListView.builder(
            itemCount: widget.uniqueDates.length,
            itemBuilder: (BuildContext context, int index) {
              String date = widget.uniqueDates[index];
              String? dayName = widget.apiService.getDayName(date);
              String? formattedDate = widget.apiService.formatDate(date);
              String displayDate = "$formattedDate (${dayName ?? 'Unknown'})";

              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  if (selectedDate != date) {
                    setState(() {
                      selectedDate = date;
                      widget.onDateChanged(selectedDate!);
                    });
                  }
                },
                child: Card(
                  color: Colors.white.withOpacity(0.9),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 5,
                  shadowColor: Colors.blueGrey.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      displayDate,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => updateDateSelection());
    var textStyle = TextStyle(
        color: Colors.white,
        fontSize: MediaQuery.of(context).size.width * 0.04);
    return SingleChildScrollView(
      child: Column(
        children: [
          GestureDetector(
            onTap: widget.uniqueDates.isNotEmpty && widget.pastPlans.isNotEmpty
                ? () => _showBottomSheet(context)
                : null,
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      selectedDate != null
                          ? widget.apiService.formatDate(selectedDate!) ??
                              "Wähle ein Datum"
                          : "Keine lokalen Pläne gefunden",
                      style: textStyle),
                  if (widget
                      .uniqueDates.isNotEmpty) //  display icon only ifNotEmpty
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.pastPlans.length,
            itemBuilder: (context, index) {
              var plan = widget.pastPlans[index];
              return PlanCard(item: plan);
            },
          )
        ],
      ),
    );
  }

// fix method for instead of on init, select after rebuild of the widget the last plan
  void updateDateSelection() {
    if (widget.uniqueDates.isNotEmpty && selectedDate == null) {
      setState(() {
        selectedDate = widget.uniqueDates.last;
        widget.onDateChanged(selectedDate!);
      });
    }
  }
}
