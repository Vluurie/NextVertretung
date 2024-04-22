class SubstitutionPlanItem {
  final String hour;
  final String action;
  final String teacher;
  final String? date;

  SubstitutionPlanItem({
    required this.hour,
    required this.action,
    required this.teacher,
    this.date,
  });

  factory SubstitutionPlanItem.fromJson(Map<String, dynamic> json) {
    return SubstitutionPlanItem(
      hour: json['hour'] as String,
      action: json['action'] as String,
      teacher: json['teacher'] as String,
      date: json['date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    var json = {
      'hour': hour,
      'action': action,
      'teacher': teacher,
      'date': date,
      'hash': generateHash()
    };
    return json;
  }

  String generateHash() {
    return Object.hash(hour, action, teacher, date).toString();
  }

  @override
  String toString() {
    return 'SubstitutionPlanItem{hour: $hour, action: $action, teacher: $teacher, date: $date, hash: ${generateHash()}}';
  }
}
